local metrics = require "metrics"
local utils = require "metrics_util"
local settings = require "metrics_setting"

local nvar = ngx.var
local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG

local m = metrics:new(settings)

-- back gateway
-- status, upstream_status, request_time, upstream_connect_time, upstream_header_time, upstream_response_time

local api_addr = nvar.remote_addr
local thirdpart_addr = nvar.upstream_addr
local status = nvar.status
local upstream_status = nvar.upstream_status
local is_sucess = false
if upstream_status == "200" then
   is_sucess = true
end
local latency = nvar.request_time * 1000
local connection_latency = nvar.upstream_connect_time * 1000
local header_latency = nvar.upstream_header_time * 1000

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

local latency_range = get_latency_range(latency)
local connection_latency_range = get_latency_range(connection_latency)
local header_latency_range = get_latency_range(header_latency)

log(DEBUG, "=== generate args === :", "\napi_addr: ",api_addr, "\nthirdpart_addr:",thirdpart_addr, "\nstatus: ", status, "\nupstream_status: ", upstream_status, "\nis_sucess: ", is_sucess, "\nlatency: ", latency, "\nconnection_latency: ", connection_latency, "\nheader_latency: ", header_latency_range, "\nlatency_range: ", latency_range, "\nconnection_latency_range: ", connection_latency_range, "\nheader_latency_range: ", header_latency_range)

-- 第三方服务请求量
local vc_metrics = "redq.gw.v3.thirdpart.visit.count"
local vc_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess
}
m:add_metrics(vc_metrics, vc_tags, 1)

-- 第三方服务请求总延迟分布
local vlc_metrics = "redq.gw.v3.thirdpart.visit.latency.count"
local vlc_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess,
   latency = latency_range,
}
m:add_metrics(vlc_metrics, vlc_tags, 1)


-- 第三方服务最大延迟
local vlmax_metrics = "redq.gw.thirdpart.visit.latency.max"
local vlmax_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess
}
m:add_metrics(vlmax_metrics, vlmax_tags, latency)

-- 第三方服务最小延迟
local vlmin_metrics = "redq.gw.v3.thirdpart.visit.latency.min"
local vlmin_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess
}
m:add_metrics(vlmin_metrics, vlmin_tags, latency)

-- 第三方服务平均延迟
local vla_metrics = "redq.gw.v3.thirdpart.visit.latency.avg"
local vla_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess
}
m:add_metrics(vla_metrics, vla_tags, latency)

-- thirdpart连接延迟分布
local clc_metrics = "redq.gw.v3.thirdpart.connection.latency.count"
local clc_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess,
   latency = connection_latency_range,
}
m:add_metrics(clc_metrics, clc_tags, 1)

-- thirdpart平均连接延迟
local cla_metrics = "redq.gw.v3.thirdpart.connection.latency.avg"
local cla_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(cla_metrics, cla_tags, connection_latency)

-- thirdpart最大连接延迟
local clmax_metrics = "redq.gw.v3.thirdpart.connection.latency.max"
local clmax_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(clmax_metrics, clmax_tags, connection_latency)

-- thirdpart最小连接延迟
local clmin_metrics = "redq.gw.v3.thirdpart.connection.latency.min"
local clmin_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(clmin_metrics, clmin_tags, connection_latency)

-- thirdpart接收延迟分布
local hlc_metrics = "redq.gw.v3.thirdpart.header.latency.count"
local hlc_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   status = status,
   is_sucess = is_sucess,
   latency = header_latency_range,
}
m:add_metrics(hlc_metrics, hlc_tags, 1)

-- thirdpart平均接收延迟
local hla_metrics = "redq.gw.v3.thirdpart.header.latency.avg"
local hla_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(hla_metrics, hla_tags, header_latency)

-- thirdpart最大接收延迟
local hlmax_metrics = "redq.gw.v3.thirdpart.header.latency.max"
local hlmax_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(hlmax_metrics, hlmax_tags, header_latency)

-- thirdpart最小接收延迟
local hlmin_metrics = "redq.gw.v3.thirdpart.header.latency.min"
local hlmin_tags = {
   api_addr = api_addr,
   thirdpart_addr = thirdpart_addr,
   is_sucess = is_sucess
}
m:add_metrics(hlmin_metrics, hlmin_tags, header_latency)

-- 第三方访问错误量
if not is_sucess then
   log(ERR, "=== into error ===")
   local vec_metrics = "redq.gw.v3.thirdpart.visit.error.count"
   local vec_tags = {
      api_addr = api_addr,
      thirdpart_addr = thirdpart_addr,
      error_type = upstream_status,
   }
   m:add_metrics(vec_metrics, vec_tags, 1)
end
