local _M = {}
local str_fmt  = string.format
local tbl_cat  = table.concat
local tbl_ins = table.insert
local str_find = string.find
local str_sub = string.sub

local log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG

function _M.string_split(s, delimeter, step)
  local index = 0
  local res = {}
  local count = 0
  repeat
    local i = str_find(s, delimeter, 1, false)
    if i then
       i = tonumber(i)
       tbl_ins(res, str_sub(s,0, i - 1))
       index = i + string.len(delimeter)
       s = str_sub(s, index)
       count = count + 1
    else
       break
    end
  until not step or count == step
  tbl_ins(res, s)
  return res
end

function _M.unique_table_string(tt)
  -- not support nested table
  local tmp = {}
  for k, v in pairs(tt) do
    if k ~= "value" or k ~= "ts" then
      tbl_ins(tmp, k)
      if "table" == type( v ) then
         tbl_ins(tmp,_M.unique_table_string(v))
      else
         tbl_ins(tmp, tostring(v))
      end
    end
  end
  return tbl_cat(tmp)
end

function _M.table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      tbl_ins(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done[value] then
        done [value] = true
        tbl_ins(sb, "{\n");
        tbl_ins(sb, _M.table_print (value, indent + 2, done))
        tbl_ins(sb, string.rep (" ", indent)) -- indent it
        tbl_ins(sb, "}\n");
      elseif "number" == type(key) then
        tbl_ins(sb, str_fmt("\"%s\"\n", tostring(value)))
      else
        tbl_ins(sb, str_fmt(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return tbl_cat(sb)
  else
    return tt .. "\n"
  end
end

-- table.__tostring = table_print
-- print({host=1, port=8086, a={1,2,3})
function _M.to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return _M.table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

function _M.url_encode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w %-%_%.%~])",
                         function (c) return str_fmt ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str	
end

function _M.generate_query_string(...)
   local metrics_name, aggregation_type, time_start, time_end, time_interval, filter_tags, group_tags = ...
   
   -- filter clause
   local filter_segs = {}
   if filter_tags then
      tbl_ins(filter_segs, "and (")
      local key_t = {}
      for key, value_list in pairs(filter_tags) do      
         local segs = {}
         for _, v in pairs(value_list) do
            tbl_ins(segs, str_fmt('[["%s" = \'%s\']]', key, v))
         end
         log(DEBUG, "key: ", key, "=== segs table ===: ", _M.to_string(segs))
         tbl_ins(key_t, tbl_cat(segs, " or "))
         
      end
      log(DEBUG, "key: ", key, "=== key table ===: ", _M.to_string(key_t))
      tbl_ins(filter_segs, tbl_cat(key_t, ") and ("))
      tbl_ins(filter_segs,")")
   end
   log(DEBUG, "=== filter segs table ===: ", _M.to_string(filter_segs))
   local filter_q = tbl_cat(filter_segs)
   log(DEBUG, "=== filter sentence ===: ", filter_q)
   
   -- group clause
   local group_q = ""
   if group_tags then
      group_q = str_fmt("group by %s,", tbl_cat(group_tags, ','))
   end
      
   log(DEBUG, "=== group sentence ===: ", group_q)
   --  @todo where clause out . make simple select * from foo limit 10 is possible
   
   -- interval clause
   local interval_q = ""
   if time_interval then
--      log(ERR, "=== time_interval=== ", time_interval, type(time_interval))
      interval_q = str_fmt("time(%ss)", time_interval)
   end
   
   local q = str_fmt([[select %s(value) from "%s" where time > %sms and time <%sms %s %s %s]],
      aggregation_type, metrics_name, time_start-1, time_end, filter_q, group_q, interval_q)
   
   log(DEBUG, "=== whole sentence ===: ", q)
   return q
end

return _M
