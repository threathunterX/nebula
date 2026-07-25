-- Copyright (C) Yichun Zhang (agentzh)


local ffi = require "ffi"
local base = require "resty.core.base"


local C = ffi.C
local ffi_str = ffi.string
local errmsg = base.get_errmsg_ptr()
local FFI_OK = base.FFI_OK
local FFI_ERROR = base.FFI_ERROR
local int_out = ffi.new("int[1]")
local getfenv = getfenv
local error = error
local type = type
local tonumber = tonumber


ffi.cdef[[
int ngx_http_lua_ffi_balancer_set_current_peer(ngx_http_request_t *r,
    const unsigned char *addr, size_t addr_len, int port, char **err);

int ngx_http_lua_ffi_balancer_set_more_tries(ngx_http_request_t *r,
    int count, char **err);

int ngx_http_lua_ffi_balancer_get_last_failure(ngx_http_request_t *r,
    int *status, char **err);

int ngx_http_lua_ffi_balancer_set_timeouts(ngx_http_request_t *r,
    long connect_timeout, long send_timeout,
    long read_timeout, char **err);
]]


local peer_state_names = {
    [1] = "keepalive",
    [2] = "next",
    [4] = "failed",
}


local _M = { version = base.version }


function _M.set_current_peer(addr, port)
    local r = getfenv(0).__ngx_req
    if not r then
        return error("no request found")
    end

    if not port then
        port = 0
    elseif type(port) ~= "number" then
        port = tonumber(port)
    end

    local rc = C.ngx_http_lua_ffi_balancer_set_current_peer(r, addr, #addr,
                                                            port, errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


function _M.set_more_tries(count)
    local r = getfenv(0).__ngx_req
    if not r then
        return error("no request found")
    end

    local rc = C.ngx_http_lua_ffi_balancer_set_more_tries(r, count, errmsg)
    if rc == FFI_OK then
        if errmsg[0] == nil then
            return true
        end
        return true, ffi_str(errmsg[0])  -- return the warning
    end

    return nil, ffi_str(errmsg[0])
end


function _M.get_last_failure()
    local r = getfenv(0).__ngx_req
    if not r then
        return error("no request found")
    end

    local state = C.ngx_http_lua_ffi_balancer_get_last_failure(r,
                                                               int_out,
                                                               errmsg)

    if state == 0 then
        return nil
    end

    if state == FFI_ERROR then
        return nil, nil, ffi_str(errmsg[0])
    end

    return peer_state_names[state] or "unknown", int_out[0]
end


function _M.set_timeouts(connect_timeout, send_timeout, read_timeout)
    local r = getfenv(0).__ngx_req
    if not r then
        return error("no request found")
    end

    if not connect_timeout then
        connect_timeout = 0
    elseif type(connect_timeout) ~= "number" or connect_timeout <= 0 then
        return error("bad connect timeout")
    else
        connect_timeout = connect_timeout * 1000
    end

    if not send_timeout then
        send_timeout = 0
    elseif type(send_timeout) ~= "number" or send_timeout <= 0 then
        return error("bad send timeout")
    else
        send_timeout = send_timeout * 1000
    end

    if not read_timeout then
        read_timeout = 0
    elseif type(read_timeout) ~= "number" or read_timeout <= 0 then
        return error("bad read timeout")
    else
        read_timeout = read_timeout * 1000
    end

    local rc =
        C.ngx_http_lua_ffi_balancer_set_timeouts(r, connect_timeout,
                                                 send_timeout, read_timeout,
                                                 errmsg)

    if rc == FFI_OK then
        return true
    end

    return false, ffi_str(errmsg[0])
end


return _M
