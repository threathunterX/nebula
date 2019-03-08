local str_fmt = string.format

local host = "127.0.0.1"
local port = 9001
local db = "monitor"
local mode = "redis"
local flush_interval = 60
local precision = "ms"
local password = "influxdb"
local user = "root"

if mode == "redis" then
   server_url = str_fmt("metricsproxy/db/%s/series", db)
elseif mode == "influxdb" then
   server_url = str_fmt("db/%s/series", db)
end

return {
   host = host,
   port = port,
   db = db,
   server_url = server_url,
   user = user,
   password = password,
   precision = precision,
   flush_interval = flush_interval,
}
