local metrics = require "metrics"
local utils = require "metrics_util"
local settings = require "metrics_setting"
local math = require "math"

local nvar = ngx.var
local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG

local m = metrics:new(settings)

-- local upstream_addr=nvar.upstream_addr
-- local remote_addr = nvar.remote_addr
-- local host = nvar.host
local uri = nvar.uri
-- local request_method = nvar.request_method
local status = nvar.status
-- local upstream_status = nvar.upstream_status
local body_bytes_sent = nvar.body_bytes_sent
-- local http_referer =nvar.http_referer;
local nrequest_time_ms = math.floor(tonumber(ngx.var.request_time) * 1000)
local request_time_ms= nrequest_time_ms
local nupstream_response_time_ms=0
if ngx.var.upstream_response_time == nil then
   nupstream_response_time_ms = 0
else
   local toNumberTime=tonumber(ngx.var.upstream_response_time)
   if toNumberTime == nil then
      nupstream_response_time_ms = 0
   else
      nupstream_response_time_ms=math.floor(toNumberTime* 1000)
   end
end
 local upstream_response_time_ms=nupstream_response_time_ms
--  local http_user_agent=nvar.http_user_agent
--  local http_x_forwarded_for=nvar.http_x_forwarded_for
 local req_len=0
 local req_len=0


if nvar.request_length == nil then
   req_len = 0
else
   req_len = nvar.request_length
end
if nvar.body_bytes_sent == nil then
   rsp_len = 0
else
   rsp_len = nvar.body_bytes_sent
end
if nvar.request_time == nil then
   request_time_ms = 0
end
if nvar.upstream_response_time == nil then
   upstream_response_time_ms = 0
end

function get_latency_range(la)
   -- la is number of millisseconds
   if la == nil then
      return "nil"
   end
   la = tonumber(la)
   if la < 5 then
      return '<5ms'
   elseif la <= 20 then
      return '5~20ms'
   elseif la <= 50 then
      return '20~50ms'
   elseif la <= 100 then
      return '50~100ms'
   elseif la <= 1000 then
      return '100~1000ms'
   else
      return '>1s'
   end
end

-- one service ,one serie,columns, values
--nebula.service.status.path.success
local success= 0
if(tonumber(status)<400) then
   success =1 
end
local service_path_count_metrics = "nebula.service.path.count"
local service_path_count_tags = {
   status = status,
   path = uri,
   latency = get_latency_range(request_time_ms),
   success = success
}
m:add_metrics(service_path_count_metrics, service_path_count_tags, 1)

if request_time_ms==nil then request_time_ms=0 end

local path_latency_tags= {
    uri=uri	
}

--各路径最大延时分布
local path_latency_max_metrics="nebula.path.latency.max.measure"
     m:add_metrics(path_latency_max_metrics, path_latency_tags, request_time_ms, nil, "max")
--各路径最小延时分布
local path_latency_min_metrics="nebula.path.latency.min.measure"
     m:add_metrics(path_latency_min_metrics, path_latency_tags, request_time_ms, nil, "min")
--各路径平均延时分布
local path_latency_mean_metrics="nebula.path.latency.mean.measure"
     m:add_metrics(path_latency_mean_metrics, path_latency_tags, request_time_ms, nil, "mean")

--总访问返回字节长度
local   return_measure_metrics="nebula.path.return.size"
local   return_measure_serie_tags ={
	uri=uri
}
m:add_metrics(return_measure_metrics, return_measure_serie_tags, rsp_len)








