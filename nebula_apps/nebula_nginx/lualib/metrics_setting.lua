local str_fmt = string.format

local host = "127.0.0.1"
local port = 9001
local db = "monitor"
local mode = "redis"
local flush_interval = 60
local precision = "ms"
local password = "CHANGE_ME_INFLUXDB_PASSWORD"
local user = "CHANGE_ME_INFLUXDB_USER"

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
