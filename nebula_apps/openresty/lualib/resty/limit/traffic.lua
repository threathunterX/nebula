-- Copyright (C) Yichun Zhang (agentzh)
--
-- This is an aggregator for various concrete traffic limiter instances
-- (like instances of the resty.limit.req and resty.limit.conn classes).


local max = math.max


local _M = {
    _VERSION = '0.03'
}


-- the states table is user supplied. each element stores the 2nd return value
-- of each limiter if there is no error returned. for resty.limit.req, the state
-- is the "excess" value (i.e., the number of excessive requests each second),
-- and for resty.limit.conn, the state is the current concurrency level
-- (including the current new connection).
function _M.combine(limiters, keys, states)
    local n = #limiters
    local max_delay = 0
    for i = 1, n do
        local lim = limiters[i]
        local delay, err = lim:incoming(keys[i], i == n)
        if not delay then
            return nil, err
        end
        if i == n then
            if states then
                states[i] = err
            end
            max_delay = delay
        end
    end
    for i = 1, n - 1 do
        local lim = limiters[i]
        local delay, err = lim:incoming(keys[i], true)
        if not delay then
            for j = 1, i - 1 do
                -- we intentionally ignore any errors returned below.
                lim:uncommit(keys[j])
            end
            return nil, err
        end
        if states then
            states[i] = err
        end

        max_delay = max(max_delay, delay)
    end
    return max_delay
end


return _M
