-- Copyright (C) Yichun Zhang (agentzh)


local ffi = require 'ffi'
local base = require "resty.core.base"


local C = ffi.C


ffi.cdef[[
int ngx_http_lua_ffi_worker_pid(void);
int ngx_http_lua_ffi_worker_exiting(void);
int ngx_http_lua_ffi_worker_id(void);
int ngx_http_lua_ffi_worker_count(void);
]]


function ngx.worker.exiting()
    return C.ngx_http_lua_ffi_worker_exiting() ~= 0 and true or false
end


function ngx.worker.pid()
    return C.ngx_http_lua_ffi_worker_pid()
end


function ngx.worker.id()
    local id = C.ngx_http_lua_ffi_worker_id()
    if id < 0 then
        return nil
    end

    return id
end


function ngx.worker.count()
    return C.ngx_http_lua_ffi_worker_count()
end


return {
    _VERSION = base.version
}
