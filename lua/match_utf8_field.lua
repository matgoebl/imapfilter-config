-- source: https://paste.sr.ht/~cybolic/902986c795599f558165c63bcb65a3d4ae15881e
-- This requires the base64 module from https://github.com/iskolbin/lbase64
-- Other base64 modules had issues working from within IMAPFilter

local methods = {}

-- Decode a field value that might be base64 encoded utf-8 (like Gmail returns)
function methods.decode_utf8_field(value, field_name)
  if value then
    local field_prefix = ''
    if field_name then
      field_prefix = ('%s: '):format(field_name)
    end
    local return_value = ''
    local value_start = value:sub(field_prefix:len(), value:len())
    print_trace("decode_utf8_field: trying",value_start)

    return_value = hdr_decode(value_start)

    -- if string.find(value_start, '^%s*=[?][Uu][Tt][Ff][-]8[?]') then
    --   value = value_start
    --   print_trace("decode_utf8_field: found",value)
    --   for part in string.gmatch(value, ' ?=[?][Uu][Tt][Ff][-]8[?]([BbQq][?].-)[?]=') do
    --     local part_type = part:sub(1, 1)
    --     local part_value = part:sub(3)
    --     if (part_type == 'B' or part_type == 'b') then
    --       part_value = base64.decode(part_value)
    --     end
    --     return_value = return_value .. part_value
    --   end
    -- else
    --   return_value = value:sub(field_prefix:len(), value:len())
    -- end

    print_trace("decode_utf8_field: result",return_value)
    print_trace()
    return return_value
  end
end

-- source: https://github.com/lefcha/imapfilter/issues/178#issuecomment-640121518
function hdr_decode(s)
	local i, j = s:lower():find("=?utf-8?q?", 1, true);
	if i then
		local k, l = s:find("?=", j, true);
		local s_ = s
			:sub(j+1, k-1)
			:gsub("_", " ")
			:gsub("=([a-fA-F0-9][a-fA-F0-9])", function(c) return string.char(tonumber(c, 16)) end);
		return hdr_decode(s:sub(1, i-1) .. s_ .. s:sub(l+1))
	end

	i, j = s:lower():find("=?utf-8?b?", 1, true);
	if i then
		local k, l = s:find("?=", j, true);
		local s_ = s:sub(j+1, k-1):gsub("[%w%+/][%w%+/][%w%+/=][%w%+/=]",
			function(w)
				local digits = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
				local a = digits:find(w:sub(1, 1), 1, true);
				local b = digits:find(w:sub(2, 2), 1, true);
				local c = digits:find(w:sub(3, 3), 1, true);
				local d = digits:find(w:sub(4, 4), 1, true);
				return string.char(
					(a-1)*4 + math.floor((b-1)/16),
					(b-1)%16*16 + math.floor(((c or 1)-1)/4),
					((c or 1)-1)%4*64 + ((d or 1)-1)
				):sub(1, d and 3 or c and 2 or 1);
			end
		);
		return hdr_decode(s:sub(1, i-1) .. s_ .. s:sub(l+1));
	end

	return s;
end

-- Return messages that match `pattern` in the `field` header field.
-- Unlike the standard `match_field`, this one works with base64 encoded UTF-8 fields
function methods.match_utf8_field(messages, field, pattern)
  local results = {}
  for m, message in ipairs(messages) do
    local mailbox, uid = table.unpack(message)
    value = mailbox[uid]:fetch_field(field)
    value = methods.decode_utf8_field(value, field)
    print_trace("match_utf8_field:",field, value, pattern, value:match(pattern) and "MATCHED")
    if (value:match(pattern)) then
      table.insert(results, { mailbox, uid })
    end
  end
  return Set(results)
end

return methods
