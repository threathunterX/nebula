-- I hereby assign copyright in this code to the lua-resty-core project,
-- to be licensed under the same terms as the rest of the code.


local ffi = require 'ffi'
local bit = require "bit"
local base = require "resty.core.base"
local core_regex = require "resty.core.regex"


local C = ffi.C
local sub = string.sub
local type = type
local band = bit.band
local new_tab = base.new_tab
local tostring = tostring
local math_max = math.max
local math_min = math.min
local re_match_compile = core_regex.re_match_compile
local destroy_compiled_regex = core_regex.destroy_compiled_regex


local FLAG_DFA               = 0x02
local PCRE_ERROR_NOMATCH     = -1
local DEFAULT_SPLIT_RES_SIZE = 4


local split_ctx = new_tab(0, 1)


local _M = { version = base.version }


local function re_split_helper(subj, compiled, compile_once, flags, ctx)
    local rc
    do
        local pos = math_max(ctx.pos - 1, 0)

        rc = C.ngx_http_lua_ffi_exec_regex(compiled, flags, subj, #subj, pos)
    end

    if rc == PCRE_ERROR_NOMATCH then
        if not compile_once then
            destroy_compiled_regex(compiled)
        end
        return nil, nil, nil
    end

    if rc < 0 then
        if not compile_once then
            destroy_compiled_regex(compiled)
        end
        return nil, nil, nil, "pcre_exec() failed: " .. rc
    end

    if rc == 0 then
        if band(flags, FLAG_DFA) == 0 then
            return nil, nil, nil, "capture size too small"
        end

        rc = 1
    end

    local caps = compiled.captures
    local ncaps = compiled.ncaptures

    local from = caps[0] + 1
    local to = caps[1]

    if from < 0 or to < 0 then
        return nil, nil, nil
    end

    ctx.pos = to + 1

    -- retrieve the first sub-match capture if any

    if ncaps > 0 and rc > 1 then
        return from, to, sub(subj, caps[2] + 1, caps[3])
    end

    return from, to
end


function _M.split(subj, regex, opts, ctx, max, res)
    -- we need to cast this to strings to avoid exceptions when they are
    -- something else.
    -- needed because of further calls to string.sub in this function.
    subj = tostring(subj)

    if not ctx then
        ctx = split_ctx
        ctx.pos = 1 -- set or reset upvalue field

    elseif not ctx.pos then
        -- ctx provided by user but missing pos field
        ctx.pos = 1
    end

    max = max or 0

    if not res then
        -- limit the initial arr_n size of res to a reasonable value
        -- 0 < narr <= DEFAULT_SPLIT_RES_SIZE
        local narr = DEFAULT_SPLIT_RES_SIZE
        if max > 0 then
            -- the user specified a valid max limiter if max > 0
            narr = math_min(narr, max)
        end

        res = new_tab(narr, 0)

    elseif type(res) ~= "table" then
        return error("res is not a table", 2)
    end

    local len = #subj
    if ctx.pos > len then
        res[1] = nil
        return res
    end

    if regex == "" then
        local pos = ctx.pos
        local last = len
        if max > 0 then
            last = math_min(len, pos + max - 1)
        end

        local res_idx = 1
        while pos < last do
            res[res_idx] = sub(subj, pos, pos)
            res_idx = res_idx + 1
            pos = pos + 1
        end

        res[res_idx] = sub(subj, pos)
        res[res_idx + 1] = nil

        return res
    end

    -- compile regex

    local compiled, compile_once, flags = re_match_compile(regex, opts)
    if compiled == nil then
        -- compiled_once holds the error string
        return nil, compile_once
    end

    local sub_idx = ctx.pos
    local res_idx = 0

    -- splitting: with and without a max limiter

    if max > 0 then
        local count = 1

        while count < max do
            local from, to, capture, err = re_split_helper(subj, compiled,
                                                compile_once, flags, ctx)
            if err then
                return nil, err
            end

            if not from then
                break
            end

            count = count + 1
            res_idx = res_idx + 1
            res[res_idx] = sub(subj, sub_idx, from - 1)

            if capture then
                res_idx = res_idx + 1
                res[res_idx] = capture
            end

            sub_idx = to + 1
        end

        if count == max then
            if not compile_once then
                destroy_compiled_regex(compiled)
            end
        end

    else
        while true do
            local from, to, capture, err = re_split_helper(subj, compiled,
                                                compile_once, flags, ctx)
            if err then
                return nil, err
            end

            if not from then
                break
            end

            res_idx = res_idx + 1
            res[res_idx] = sub(subj, sub_idx, from - 1)

            if capture then
                res_idx = res_idx + 1
                res[res_idx] = capture
            end

            sub_idx = to + 1
        end
    end

    -- trailing nil for non-cleared res tables

    res[res_idx + 1] = sub(subj, sub_idx)
    res[res_idx + 2] = nil

    return res
end


return _M
