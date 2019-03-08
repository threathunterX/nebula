-- Copyright (C) Yichun Zhang (agentzh)
--
-- This library is an enhanced Lua port of the standard ngx_limit_conn
-- module.


local math = require "math"


local setmetatable = setmetatable
local floor = math.floor
local ngx_shared = ngx.shared
local assert = assert


local _M = {
    _VERSION = '0.03'
}


local mt = {
    __index = _M
}


function _M.new(dict_name, max, burst, default_conn_delay)
    local dict = ngx_shared[dict_name]
    if not dict then
        return nil, "shared dict not found"
    end

    assert(max > 0 and burst >= 0 and default_conn_delay > 0)

    local self = {
        dict = dict,
        max = max + 0,    -- just to ensure the param is good
        burst = burst,
        unit_delay = default_conn_delay,
    }

    return setmetatable(self, mt)
end


function _M.incoming(self, key, commit)
    local dict = self.dict
    local max = self.max

    self.committed = false

    local conn = dict:get(key)
    if conn then
        if conn >= max then
            if conn >= max + self.burst then
                return nil, "rejected"
            end

            if commit then
                local err
                conn, err = dict:incr(key, 1, 0)
                if not conn then
                    return nil, err
                end

                self.committed = true
            else
                conn = conn + 1
            end

            -- make the exessive connections wait
            return self.unit_delay * floor((conn - 1) / max), conn
        end

        if commit then
            -- FIXME: we should use incr_or_init here.
            local new_conn, err = dict:incr(key, 1)
            if not new_conn then
                return nil, err
            end

            self.committed = true
            return 0, new_conn
        end

        return 0, conn + 1

    else
        if commit then
            local err
            conn, err = dict:incr(key, 1, 0)
            if not conn then
                return nil, err
            end

            self.committed = true
        else
            conn = 1
        end
    end

    return 0, conn  -- we return a 0 delay by default
end


function _M.is_committed(self)
    return self.committed
end


function _M.leaving(self, key, req_latency)
    assert(key)
    local dict = self.dict

    local conn, err = dict:incr(key, -1)
    if not conn then
        return nil, err
    end

    if req_latency then
        local unit_delay = self.unit_delay
        self.unit_delay = (req_latency + unit_delay) / 2
    end

    return conn
end


function _M.uncommit(self, key)
    assert(key)
    local dict = self.dict

    return dict:incr(key, -1)
end


function _M.set_conn(self, conn)
    self.conn = conn
end


function _M.set_burst(self, burst)
    self.burst = burst
end


return _M
