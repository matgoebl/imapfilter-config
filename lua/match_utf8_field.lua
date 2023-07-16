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
    local value_start = value:sub(1 + field_prefix:len(), 8 + field_prefix:len())
    if value_start == '=?UTF-8?' or value_start == '=?utf-8?' then
      value = value:sub(field_prefix:len(), value:len())
      for part in string.gmatch(value, ' ?=[?][Uu][Tt][Ff][-]8[?]([BbQq][?].-)[?]=') do
        local part_type = part:sub(1, 1)
        local part_value = part:sub(3)
        if (part_type == 'B' or part_type == 'b') then
          part_value = base64.decode(part_value)
        end
        return_value = return_value .. part_value
      end
    else
      return_value = value:sub(field_prefix:len(), value:len())
    end
    return return_value
  end
end

-- Return messages that match `pattern` in the `field` header field.
-- Unlike the standard `match_field`, this one works with base64 encoded UTF-8 fields
function methods.match_utf8_field(messages, field, pattern)
  local results = {}
  for m, message in ipairs(messages) do
    local mailbox, uid = table.unpack(message)
    value = mailbox[uid]:fetch_field(field)
    value = methods.decode_utf8_field(value, field)
    if (value:match(pattern)) then
      table.insert(results, { mailbox, uid })
    end
  end
  return Set(results)
end

return methods
