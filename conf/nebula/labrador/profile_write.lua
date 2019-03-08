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

function put_first(rec, kvs)
    if (map.size(kvs) > 0) then
        if (not (aerospike:exists(rec))) then
            aerospike:create(rec)
        end
        for key, value in map.pairs(kvs) do
            if (nil == rec[key]) then
                rec[key] = value
            end
        end
        aerospike:update(rec)
    end
end

function put(rec, kvs)
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

function batch_merge(rec, hour, kvs)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for key, value in map.pairs(kvs) do
        bin_map = rec[key]
        if(nil == bin_map) then
            bin_map = map()
        end
        bin_map[hour] = value
        rec[key] =  bin_map
    end
    aerospike:update(rec)
end

function batch_put(rec, kvs)
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



function batch_put(rec, kvs)
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

function batch_merge_map_long(rec, codes, keys, counts)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local code_map = rec[code]
        if (nil == code_map) then
            code_map = map()
        end
        for index = 1, list.size(keys[cur]), 1 do
            local key = keys[cur][index]
            local count = counts[cur][index]
            local cnt = code_map[key]
            if (nil == cnt) then
                cnt = 0
            end
            code_map[key] = cnt + count
        end
        rec[code] = code_map
    end
    aerospike:update(rec)
end


-- 增长，加1操作
function increment(rec, keys)
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


function batch_increment_long(rec, codes, counts)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local cnt = rec[code]
        if (nil == cnt) then
            cnt = counts[cur]
        else
            cnt = cnt + counts[cur]
        end
        rec[code] = cnt
    end
    aerospike:update(rec)
end



function increment_map(rec, codes, indexes)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local index = indexes[cur]
        local index_map = rec[code]
        if (nil == index_map) then
            index_map = map()
        end

        local cnt = index_map[index]
        if (nil == cnt) then
            index_map[index] = 1
        else
            index_map[index] = cnt + 1
        end
        rec[code] = index_map
    end
    aerospike:update(rec)
end

function increment_map_period(rec, ts, codes)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local code_map = rec[code]
        if (nil == code_map) then
            code_map = map()
        end
        local cnt = code_map[ts]
        if (nil == cnt) then
            cnt = 0
        end
        cnt = cnt + 1
        code_map[ts] = cnt
        rec[code] = code_map
    end
    aerospike:update(rec)
end

--有时间分区的sum，一级索引为ts，即时间，二级索继为group_keys[1]，即变量second_index
function sum_map_period_second_index(rec, ts, codes, values, second_indexes)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local value = values[cur]
        local second_index = second_indexes[cur]
        local ts_map = rec[code]
        if (nil == ts_map) then
            ts_map = map
        end
        local second_index_map = ts_map[ts]
        if (nil == second_index_map) then
            second_index_map = map()
        end

        local second_index_value = second_index_map[second_index]
        if (nil == second_index_value) then
            second_index_value = 0
        end
        second_index_value = second_index_value + value
        second_index_map[second_index] = second_index_value
        ts_map[ts] = second_index_map
        rec[code] = ts_map
    end
    aerospike:update(rec)
end

function sum_map_period(rec, ts, codes, values)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local value = values[cur]
        local ts_map = rec[code]
        if (nil == ts_map) then
            ts_map = map()
        end
        local current_value = ts_map[ts]
        if (nil == current_value) then
            current_value = 0
        end
        current_value = current_value + value
        ts_map[ts] = current_value
        rec[code] = ts_map
    end

    aerospike:update(rec)
end


function increment_map_second_index(rec, codes, indexes, second_indexes)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local index = indexes[cur]
        local second_index = second_indexes[cur]
        local index_map = rec[code]
        if (nil == index_map) then
            index_map = map()
        end
        local second_index_map = index_map[index]
        -- 不存在二级索引，则创建二级索引值为1
        if (nil == second_index_map) then
            second_index_map = map()
            second_index_map[second_index] = 1
        end
        local cnt = second_index_map[second_index]
        if (nil == cnt) then
            second_index_map[second_index] = 1
        else
            second_index_map[second_index] = cnt + 1
        end
        index_map[index] = second_index_map
        rec[code] = index_map
    end
    aerospike:update(rec)
end


function put_list_n(rec, codes, values, limits)
    if (not (aerospike:exists(rec))) then
        aerospike:create(rec)
    end
    for cur = 1, list.size(codes), 1 do
        local code = codes[cur]
        local value = values[cur]
        local cur_list = rec[code]
        local limit = limits[cur]
        if (nil == cur_list) then
            cur_list = list()
        end
        list.append(cur_list, value)

        if (list.size(cur_list) > limit) then
            cur_list = list.drop(cur_list, list.size(cur_list) - limit)
        end
        rec[code] = cur_list
    end
    aerospike:update(rec)
end

function put_list_distinct(rec, codes, values, list_default_length)
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

        if (list.size(cur_list) > list_default_length) then
            cur_list = list.drop(cur_list, list.size(cur_list) - list_default_length)
        end
        rec[code] = cur_list
    end
    aerospike:update(rec)
end

function put_map_list(rec, time_key, codes, values, periods, list_default_length)
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
            bin_map[time_key] = cur_list
        else
            local cur_list = bin_map[time_key]
            if (nil == cur_list) then
                cur_list = list()
            end
            list.append(cur_list, value)
            if (list.size(cur_list) > list_default_length) then
                cur_list = list.drop(cur_list, list.size(cur_list) - list_default_length)
            end
            bin_map[time_key] = cur_list
        end

        if (map.size(bin_map) > 24) then
            local time_key_number = tonumber(time_key)
            local period = tonumber(periods[cur])
            if period > 0 then
                for key in map.keys(bin_map) do
                    if (time_key_number - tonumber(key) > period) then
                        map.remove(bin_map, key)
                    end
                end
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end

function put_map_list_distinct(rec, time_key, codes, values, periods, list_default_length)
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
            bin_map[time_key] = cur_list
        else
            local cur_list = bin_map[time_key]
            if (nil == cur_list) then
                cur_list = list()
                list.append(cur_list, value)
            else
                local index = index_of(cur_list, value)
                if (index == 0) then
                    list.append(cur_list, value)
                end
            end
            if (list.size(cur_list) > list_default_length) then
                cur_list = list.drop(cur_list, list.size(cur_list) - list_default_length)
            end
            bin_map[time_key] = cur_list
        end

        if (map.size(bin_map) > 24) then
            local time_key_number = tonumber(time_key)
            local period = tonumber(periods[cur])
            if period > 0 then
                for key in map.keys(bin_map) do
                    if (time_key_number - tonumber(key) > period) then
                        map.remove(bin_map, key)
                    end
                end
            end
        end
        rec[code] = bin_map
    end
    aerospike:update(rec)
end