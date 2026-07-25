local function index_of(value_list, cur_value)
    local current = 0
    local index = 0
    info("current values length" .. #value_list)
    local i = 0
    for i = 1, #value_list, 1 do
        info("current ===" .. value_list[i])
        if (cur_value == value_list[i]) then
            index = i
            break
        end
    end
    return index
end

--string split
local function string_split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

--返回：当前值的位置，待插入的位置
--当前值的位置：根据cur_value查找value_list，如果找到，当前值的位置为找到的下标，否则为0
--待插入的位置：对比ts与value_list中的ts，找到相应的插入位置,找到小于某个元素的时间，则位置即为该元素的下标
local function contrast_item(value_list, cur_value, ts)
    local cursor = 0
    local found_index = 0
    local insert_index = 1
    for value in list.iterator(value_list) do
        --当前位置
        cursor = cursor + 1
        local items = string_split(value, ":")
        local item_value = items[1]
        local item_ts = items[2]
        --查找当前值的位置
        if (found_index == 0) then
            if (item_value == cur_value) then
                found_index = cursor
            end
        end
        --查找插入的位置
        if (ts > tonumber(item_ts)) then
            insert_index = cursor + 1
        end
    end
    return found_index, insert_index
end



--基本的put kv
function put_object(rec, kvs)
    if (map.size(kvs) > 0) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for key, value in map.pairs(kvs) do
            rec[key] = value
        end
        aerospike:update(rec)
    end
end

--根据value的值进行判断，如果为
function put_boolean(rec, kvs)
    if (map.size(kvs) > 0) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for key, value in map.pairs(kvs) do
            local _boolean_value
            --如果不为nil
            if value then
                local _value = string.lower(value:match "^%s*(.*)":match "(.-)%s*$")
                if _value == "y" then
                    _boolean_value = true
                else
                    _boolean_value = false
                end
            else
                _boolean_value = false
            end
            rec[key] = _boolean_value
        end
        aerospike:update(rec)
    end
end


--如果当前时间晚于上次更新，则进行替换。如：最后一次登陆时间
function put_last_update(rec, kvs, ts)
    if (map.size(kvs) > 0) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for key, value in map.pairs(kvs) do
            if (nil == rec[key]) then
                rec[key] = tostring(value) .. ":" .. ts
            else
                local items = string_split(rec[key], ":")
                if (#items == 2) then
                    if (ts > tonumber(items[2])) then
                        rec[key] = tostring(value) .. ":" .. ts
                    end
                end
            end
        end
        aerospike:update(rec)
    end
end


--如果当前时间早于上次更新，则进行替换。如：首次下单城市
function put_first_update(rec, kvs, ts)
    if (map.size(kvs) > 0) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for key, value in map.pairs(kvs) do
            if (nil == rec[key]) then
                rec[key] = tostring(value) .. ":" .. ts
            else
                local items = string_split(rec[key], ":")
                if (#items == 2) then
                    if (ts < tonumber(items[2])) then
                        rec[key] = tostring(value) .. ":" .. ts
                    end
                end
            end
        end
        aerospike:update(rec)
    end
end

-- 增长，加1操作
function put_increment(rec, keys)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(keys), 1 do
        local key = keys[cur]
        local value = rec[key]
        if (nil == value) then
            rec[key] = 1
        else
            rec[key] = value + 1
        end
    end
    aerospike:update(rec)
end


--访问小时自增
function put_map_increment_hour(rec, keys, hour)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(keys), 1 do
        local key = keys[cur]
        local cur_map = rec[key]
        if (nil == cur_map) then
            cur_map = map()
            cur_map[hour] = 1
        else
            local cur_hour_cnt = cur_map[hour]
            if (nil == cur_hour_cnt) then
                cur_map[hour] = 1
            else
                cur_map[hour] = cur_hour_cnt + 1
            end
        end
        rec[key] = cur_map
    end
    aerospike:update(rec)
end


--访问小时自增
function put_map_increment_day_hour(rec, keys, day_hour)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(keys), 1 do
        local key = keys[cur]
        local cur_map = rec[key]
        if (nil == cur_map) then
            cur_map = map()
            cur_map[day_hour] = 1
        else
            local cur_hour_cnt = cur_map[day_hour]
            if (nil == cur_hour_cnt) then
                cur_map[day_hour] = 1
            else
                cur_map[day_hour] = cur_hour_cnt + 1
            end
        end
        rec[key] = cur_map
    end
    aerospike:update(rec)
end


function send_map_increment_visit(rec, codes, keys, values)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end

    for cur =1,list.size(keys), 1 do
        local code = codes[cur]
        local key =  keys[cur]
        local cur_map = rec[code]
        local value = values[cur]
        if(nil == cur_map) then
           cur_map = map()
        end
        cur_map[key] = value
        rec[code] = cur_map
    end
    aerospike:update(rec)
end



function put_map_increment(rec, keys, value_map)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(keys), 1 do
        local key = keys[cur]
        local cur_map = rec[key]
        if (nil == cur_map) then
            cur_map = map()
        end

        local value = value_map[key]
        local cnt = cur_map[value]

        if (nil == cnt) then
            cur_map[value] = 1
        else
            cur_map[value] = cnt + 1
        end
        rec[key] = cur_map
    end
    aerospike:update(rec)
end


--合并两个map，如历史ip,ua的数量
function put_map_count_merge(rec, keys, value_maps)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end

    for cur = 1, list.size(keys), 1 do
        local key = keys[cur]
        info("debug:" .. key)
        local value_map = value_maps[cur]

        for key, value in map.pairs(value_map) do
            info("debug> key: " .. key .. " value:" .. value)
        end

        local old_map = rec[key]
        if (nil == old_map) then
            if (not (nil == value_map)) then
                rec[key] = value_map
            end
        else
            if (not (nil == value_map)) then
                local result = map.merge(old_map, value_map, function(v1, v2)
                    return v1 + v2
                end)
                rec[key] = result
            end
        end
    end
    aerospike:update(rec)
end



-- 最近出现去重的天数n个，如最近访问的30个ip，带时间属性
function put_list_distinct_day_n(rec, bins_key, bins_value, bins_length_limit, ts)
    if (#bins_key == #bins_value) and (#bins_value == #bins_length_limit) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for cur = 1, list.size(bins_key), 1 do
            local cur_key = bins_key[cur]
            local value_list = rec[cur_key]
            if (nil == value_list) then
                value_list = list()
            end
            local found_index, insert_index = contrast_item(value_list, bins_value[cur], ts)
            info("debug  found_index:" .. found_index .. " insert_index:" .. insert_index)

            if (found_index > 0) then
                --插入位置找到的情况
                info("debugs:" .. insert_index)
                if (insert_index > 1) then
                    list.remove(value_list, found_index)
                    --由于已经移除一个，所以只要不是第1个位置都需要插入前一个位置
                    if (insert_index == 1) then
                        list.insert(value_list, insert_index, tostring(bins_value[cur]) .. ":" .. ts)
                    else
                        list.insert(value_list, insert_index - 1, tostring(bins_value[cur]) .. ":" .. ts)
                    end
                end
                --根据value找不到的情况
            else
                --如果insert_index > 1，则表示当前的时间可以插入数据
                if (insert_index > 1) then
                    if (#value_list == bins_length_limit[cur]) then
                        list.remove(value_list, 1)
                        insert_index = insert_index - 1
                        list.insert(value_list, insert_index, tostring(bins_value[cur]) .. ":" .. ts)
                    else
                        list.insert(value_list, insert_index, tostring(bins_value[cur]) .. ":" .. ts)
                    end
                else
                    --如果当前值为空，则insert_index=1可插入
                    if (#value_list == 0) then
                        list.insert(value_list, insert_index, tostring(bins_value[cur]) .. ":" .. ts)
                    else
                        local item_index_1 = string_split(value_list[1], ":")
                        if (not (item_index_1[1] == bins_value[cur])) then
                            list.insert(value_list, insert_index, tostring(bins_value[cur]) .. ":" .. ts)
                        end
                    end
                end
            end
            rec[cur_key] = value_list
        end
        aerospike:update(rec)
    else
        error("bins_keys && bins_value && bins_length_limit are not equal")
    end
end

function put_map_recent_day_hour_increment(rec, codes, current_keys, counters, expires_days)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end

    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local current_key = current_keys[cur]
        local counter = counters[cur]

        local bin_map = rec[code]
        if (nil == bin_map) then
            bin_map = map()
            bin_map[current_key] = counter
        else
            local cur_hour_cnt = bin_map[current_key]
            if (nil == cur_hour_cnt) then
                bin_map[current_key] = counter
            else
                bin_map[current_key] = cur_hour_cnt + counter
            end
        end

        if (map.size(bin_map) > expires_days * 24) then
            local expired_ts = tonumber(os.time()) - expires_days * 24 * 3600
            local expired_format = os.date("%y%m%d%H", expired_ts)
            for key in map.keys(bin_map) do
                if tonumber(key) < tonumber(expired_format) then
                    map.remove(bin_map, key)
                end
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end

function put_distinct_list(rec, codes, values)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local value = values[cur]
        local cur_list = rec[code]
        if (nil == cur_list) then
            cur_list = list()
            list.append(cur_list, value)
        else
            local index = index_of(cur_list, value)
            if (index == 0) then
                list.append(cur_list, value)
            end
        end
        rec[code] = cur_list
    end
    aerospike:update(rec)
end




function put_map_recent_day_hour_distinct_list(rec, codes, current_keys, values, expires_days)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local current_key = current_keys[cur]
        local value = values[cur]

        local bin_map = rec[code]
        if (nil == bin_map) then
            bin_map = map()
            local cur_list = list()
            for value_cur = 1, list.size(value), 1 do
                list.append(cur_list, value[value_cur])
            end
            bin_map[current_key] = cur_list
        else
            local cur_list = bin_map[current_key]
            if (nil == cur_list) then
                cur_list = list()
                for value_cur = 1, list.size(value), 1 do
                    list.append(cur_list, value[value_cur])
                end
                bin_map[current_key] = cur_list
            else
                for value_cur = 1, list.size(value), 1 do
                    local index = index_of(cur_list, value[value_cur])
                    if (index == 0) then
                        list.append(cur_list, value[value_cur])
                    end
                end
                bin_map[current_key] = cur_list
            end
        end
        if (map.size(bin_map) > expires_days * 24) then
            local expired_ts = tonumber(os.time()) - expires_days * 24 * 3600
            local expired_format = os.date("%y%m%d%H", expired_ts)
            for key in map.keys(bin_map) do
                if tonumber(key) < tonumber(expired_format) then
                    map.remove(bin_map, key)
                end
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end

function put_recent_day_increment(rec, day, codes, counters)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local current_key = day
        local counter = counters[cur]

        local bin_map = rec[code]
        if (nil == bin_map) then
            bin_map = map()
            bin_map[current_key] = counter
        else
            local cur_cnt = bin_map[current_key]
            if (nil == cur_cnt) then
                bin_map[current_key] = counter
            else
                bin_map[current_key] = cur_cnt + counter
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end


function put_map_recent_day_hour_distinct_list_rt(rec, day, codes, values, expires_days)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local value = values[cur]

        local bin_map = rec[code]
        if (nil == bin_map) then
            bin_map = map()
            local cur_list = list()
            list.append(cur_list, value)
            bin_map[day] = cur_list
        else
            local cur_list = bin_map[day]
            if (nil == cur_list) then
                cur_list = list()
                list.append(cur_list, value)
                bin_map[day] = cur_list
            else
                local index = index_of(cur_list, value)
                if (index == 0) then
                    list.append(cur_list, value)
                end
                bin_map[day] = cur_list
            end
        end

        if (map.size(bin_map) > expires_days * 24) then
            local expired_ts = tonumber(os.time()) - expires_days * 24 * 3600
            local expired_format = os.date("%y%m%d%H", expired_ts)
            for key in map.keys(bin_map) do
                if tonumber(key) < tonumber(expired_format) then
                    map.remove(bin_map, key)
                end
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end