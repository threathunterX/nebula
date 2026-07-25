local _M = {}

local http = require "resty.http"
local json = require "cjson"
local utils = require "metrics_util"

local str_fmt = string.format
local str_find = string.find
local str_sub = string.sub
local tbl_cat = table.concat
local tbl_ins = table.insert
local tbl_unp = table.unpack

local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG
local queue = ngx.shared.metrics

local HTTP_NO_CONTENT = ngx.HTTP_NO_CONTENT

local mt = {
		__index = _M,
		__tostring = function(self)
			return str_fmt(
				"%s,%s,%s,%s,%s",
				tostring(self.host),
				tostring(self.port),
				tostring(self.db),
				tostring(self.user),
				tostring(self.precision)) end
}

function _M.request(self, params)
	local client = http.new()

	local scheme     = 'http'
	local ssl_verify = false

	if params.ssl then
		scheme     = 'https'
		ssl_verify = true
	end

	local path    = str_fmt('%s://%s:%s/%s', scheme, self.host, self.port, params.url)
	local method  = params.method
	local headers = {
		["Host"]  = params.hostname
	}

--    log(ERR, "request path: ", path, " method ", method, " data ", utils.to_string(params.data), " ", type(params.data))

	return client:request_uri(
		path,
		{
			query      = params.query,
			method     = method,
			headers    = headers,
			body       = params.data,
			ssl_verify = ssl_verify,
		}
	)

	-- if not res then
	-- 	return false, err
	-- end

	-- if res.status == HTTP_NO_CONTENT then
	-- 	return true
	-- else
	-- 	return false, res.body
	-- end   
end
      
function _M.flush_expired(self)
   log(DEBUG, "=== metrics send error count: ", self.send_error_count)
   if self.send_error_count > 3 then
      queue:flush_all()
      self.send_error_count = 0
   end
end
function _M.flush(self)
   local points = self:get_points()
   local res = self:write_points(points)
   if res then
      self.add_error_count = 0
   else
      log(ERR, "=== this flush interval can't add metrics number: ", self.add_error_count, ", if it's a lot check the tags for aggregate or add queue size.")
      self.send_error_count = self.send_error_count + 1
   end
   self:flush_expired()
   log(DEBUG, "=== send metrics suceess? === ", res)
   return res
end

function _M.get_points(self)
   -- get cached metrics from shared_dict, do the aggregate
   local points = {}
   local aggr_points = {} -- "metrics_name||table_unique_string" : {value, tags_json}
   local input_number = 0
   local output_number = 0
   while true do
      local val, err = queue:rpop("metrics")
      if not val then
         log(DEBUG, "=== fail to get_points === ", err)
         break
      else
         input_number = input_number + 1
         value, tags_str, aggr_type, metrics_key = tbl_unp(utils.string_split(val, "||", 3))
         local vv = tonumber(value)
         if aggr_points[metrics_key] then
            if aggr_type == "sum" then
               aggr_points[metrics_key][1] = aggr_points[metrics_key][1] + vv
            elseif aggr_type == "count" then
               aggr_points[metrics_key][1] = aggr_points[metrics_key][1] + 1
            elseif aggr_type == "max" then
               if vv > aggr_points[metrics_key][1] then
                  aggr_points[metrics_key][1] = vv
               end
            elseif aggr_type == "min" then
               if vv < aggr_points[metrics_key][1] then
                  aggr_points[metrics_key][1] = vv
               end
            elseif aggr_type == "latest" then
               aggr_points[metrics_key][1] = vv
            elseif aggr_type == "mean" then
               aggr_points[metrics_key][1] = aggr_points[metrics_key][1] + vv
               aggr_points[metrics_key][3] = aggr_points[metrics_key][3] + 1
            else
               log(ERR, "=== unknown aggregate type: ", aggr_type)
            end
         else
            if aggr_type == "mean" then
               aggr_points[metrics_key] = {vv, tags_str, 1}
            elseif aggr_type == "count" then
               aggr_points[metrics_key] = {1, tags_str}
            else
               aggr_points[metrics_key] = {vv, tags_str}
            end
         end
         --log(ERR, "=== invalid inner metrics format([value]||[metrics_name]||[tags]), can't find || delimeter", val)
      end
   end
   
   -- format metrics point
   for k,v in pairs(aggr_points) do
      output_number = output_number + 1
      metrics_name, _ = table.unpack(utils.string_split(k, "||", 1))
      if metrics_name then
         tags = json.decode(v[2])
         if tags then
            local keys = {}
            local values = {}
            if #v == 3 then
               tags["value"] = v[1] / v[3]
            else
               tags["value"] = v[1]
            end
            for tag_k,tag_v in pairs(tags) do
               tbl_ins(keys, tag_k)
               tbl_ins(values, tag_v)
            end
            local point = {name=metrics_name, columns=keys, points={values}}
            log(DEBUG, "=== point to send ===", utils.to_string(point))
            tbl_ins(points, point)
         end
      else
         log(ERR, "=== invalid aggregate metrics key([metrics_name]||[tags' string]), can't find || delimeter", k)
      end
   end
   log(DEBUG, "=== origin metrics number: ", input_number)
   log(DEBUG, "=== after aggregate metrics number: ", output_number)
   return points
end

function _M.write_points(self, points)
   -- batch write and buffer later 
    local query = str_fmt("u=%s&p=%s&time_precision=%s", self.user, self.password, self.precision)
    local data = json.encode(points)
    local params = {url=self.server_url,
                    method='POST',
                    query=query,
                    data=data,
                    expected_response_code=200}
    log(DEBUG, "=== add metrics params ===", utils.to_string(params))
    local res, err = self:request(params)
    if not res then
       log(ERR, "failed to send metrics:", err)
       return false
    end
    
    if res.status == 400 then
--       log(ERR, "failed to add metrics: ", res.body)
       return false
    end
    
    return true
end

function _M.add_metrics(self, metrics_name, tags, value, timestamp, aggr_type)
   -- expire_seconds arg not used
   
   if timestamp then
      -- if have timestamp arg, there can't aggregate the metrics, be caution.
      -- if no timestamp, metrics proxy will add, but time will not accurate.
      tags["ts"] = timestamp
   end
   
   if not aggr_type then
      aggr_type = "sum"
   end
   
   local m = str_fmt("%d||%s||%s||%s||%s", value, json.encode(tags), aggr_type,
                     metrics_name, utils.unique_table_string(tags))
   local len, err = queue:lpush("metrics", m)
   if not len then
      self.add_error_count = self.add_error_count + 1
      log(ERR, "=== add metrics queue err === :", err)
   end
end
      
function _M._query(self, data)
   -- chunked todo
--   log(ERR, "==== in query ==== ", utils.to_string(self))
   local url = str_fmt("db/%s/series", self.db)
   local q = utils.url_encode(data)
   local query = str_fmt("u=%s&p=%s&time_precision=%s&q=%s", self.user, self.password, self.precision, q)
   local params = {url=self.server_url,
                   method='GET',
                   query=query,
                   expected_response_code=200}
   local res, err = self:request(params)
   log(ERR, "==== response ==== : ", utils.to_string(res))
   if not res then
      ngx.say("failed to request:", err)
      return
   end
   if res.status == 400 then
      log(ERR, "failed to query metrics: ", res.body)
      return
   end
   
   if res.has_body then
      local r = json.decode(res.body)
--      log(ERR, "==== return ==== : ", utils.to_string(r))
      return r
   end
   
   return
end

function _M.query(self, ...)
   log(ERR, "=== request args ===", ...)
   local metrics_name, aggregation_type, time_start, time_end, time_interval, filter_tags, group_tags = ...
   local q = utils.generate_query_string(...)
   log(ERR, "=== query sql === ", q)
--   q = "select sum(vals) from foo limit 10" -- debug one
   series = self:_query(q)
   local result = {}
   -- log(ERR, '=== series === : ', utils.to_string(series))
   -- log(ERR, '=== columns === : ', utils.to_string(series[1]["columns"]))
   -- log(ERR, '=== points === : ', utils.to_string(series[1]["points"]))
   if series then
      for _, s in pairs(series) do
         columns = s.columns
         for _,point in pairs(s.points) do
            local legend = {}
            local ts = nil
            local value = nil
            for i,v in ipairs(point) do
               local c = columns[i]
               if c == "time" then
                  ts = tonumber(v)
               elseif c == aggregation_type then
                  value = tonumber(v)
               else
                  tbl_ins(legend, tostring(v))
               end
            end
            log(ERR, "=== ts === : ", ts, " ",type(ts))
            log(ERR, "=== value === : ", value, " ",type(value))
            log(ERR, "=== legend === : ", utils.to_string(legend), type(legend))
            if result[ts] == nil then
               log(ERR, " in side ")
               result[ts] = {[legend]=value}
               log(ERR, " after ref result ts: ", utils.to_string(result))
            else
               result[ts][legend] = value
            end
         end
      end
   end
   -- todo return data structure
   return result
end

function _M.new(self, opts)
	-- local ok, err = util.validate_options(opts)
	-- if not ok then
	-- 	return false, err
	-- end

	local t = {
		-- user opts
		host      = opts.host,
		port      = opts.port,
		db        = opts.db,
		hostname  = opts.hostname,
        server_url = opts.server_url,
--		proto     = opts.proto,
		precision = opts.precision,
		ssl       = opts.ssl,
--		auth      = opts.auth,
        user      = opts.user,
        password  = opts.password,
        send_error_count = 0,
        add_error_count = 0
	}

	return setmetatable(t, mt)
end

return _M
