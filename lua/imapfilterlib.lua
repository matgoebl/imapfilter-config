----- Generic Helpers

function getenv_bool(key)
    local val = os.getenv(key)
    if val then
        val = string.lower(string.sub(val,1,1))
        if val == 't' or val == 'y' or val == '1' then
            return true
        end
    end
    return false
end

----- Message Helpers

function field(message, key)
    local value = message:fetch_field(key)
    value = string.gsub(value, "^[^ :]+: ", "")
    value = string.gsub(value, "\r?\n", "  ")
    return value
end

function extract_email(sender)
    local email = string.match(sender, "<([^> ]+@[^> ]+)>")
    email = string.lower(email or sender)
    email = email:gsub("%([^)]+%)", "")
    email = email:gsub("^%s+", ""):gsub("%s+$", "")
    return email
end

function contains(list, item)
    if not list or not item then
        return false
    end
    for _, val in pairs(list) do
        if val == item then return true end
    end
    return false
end

function dump_messages(msg, messages)
    if not messages then
        messages = msg
        msg = "Messages"
    end
    print(msg .. ": (" .. #messages .. ")")
    local msgs = {}
    for _, message in ipairs(messages) do
        -- dump("Message", message)
        local mailbox, uid = table.unpack(message)
        local messagecontent = mailbox[uid]
        local subject = field(messagecontent, 'subject')
        local from = field(messagecontent, 'from')
        local date = messagecontent:fetch_date()
        local email = extract_email(from)
        table.insert(msgs, "- " .. email .. "\t" .. subject .. "\t" .. date)
        -- print("- ", date, from, subject)
    end
    table.sort(msgs)
    print(table.concat(msgs, "\n"))
    print()
end



----- Mailbox Helpers

function create_mbox(name)
    if not contains(MAILBOXES, name) and not dryrun then
        ACCOUNT:create_mailbox(name)
    end
    --account:delete_mailbox(name)    
end

function move_messages(messages_to_move, mailboxname)
    if #messages_to_move > 0 then
        dump_messages("Moving to " .. mailboxname .. (dryrun and " (dryrun)" or ""), messages_to_move)
        if not dryrun then
            create_mbox(mailboxname)
            messages_to_move:move_messages(ACCOUNT[mailboxname])
        end
    end
end

function load_senders(mailboxname)
    local filename = SENDERS_PATH .. "/" .. mailboxname .. ".senders"
    local file = io.open(filename, "r")
    local senders = {}
    if file then
        for line in file:lines() do
            table.insert (senders, line);
        end
        file:close()
    end
    -- list("Loaded " .. filename, senders)
    return senders
end

function save_senders(mailboxname, senders)
    local filename = SENDERS_PATH .. "/" .. mailboxname .. ".senders"
    local file = io.open(filename, "w")
    if file then
        for _, sender in ipairs(senders) do
            file:write(sender .. "\n")
        end
        file:close()
    end
end


function senders_in_mailbox(mailboxname, senders)
    local messages = ACCOUNT[mailboxname]:select_all()
    local senders = senders or {}
    for _, message in ipairs(messages) do
        local mailbox, uid = table.unpack(message)
        local messagecontent = mailbox[uid]
        local from = extract_email(field(messagecontent, 'from'))
        if AUTOCOLLECT_EXCLUDE_SENDERS == nil or not string.match(from, AUTOCOLLECT_EXCLUDE_SENDERS) then
            if not contains(senders, from) then
                table.insert(senders, from)
            end
        end
    end
    return senders
end

function messages_from_senders(messages, senders)
    local messages_selected = Set {}
    for _, message in ipairs(messages) do
        local mailbox, uid = table.unpack(message)
        local messagecontent = mailbox[uid]
        local from = extract_email(field(messagecontent, 'from'))
        local to = extract_email(field(messagecontent, 'to'))
        local cc = extract_email(field(messagecontent, 'cc'))
        local bcc = extract_email(field(messagecontent, 'bcc'))
        local selected = contains(senders, from) or contains(senders, to) or contains(senders, cc) or contains(senders, bcc)
        if selected then
            table.insert(messages_selected, message)
        end
    end
    return messages_selected
end


function move_messages_with_previous_senders(messages, mailboxname)
    local senders = load_senders(mailboxname)
    if reload_senders or not senders or #senders == 0 then
        -- print("Collecting senders in " .. mailboxname .. "...")
        senders = senders_in_mailbox(mailboxname, senders)
        save_senders(mailboxname, senders)
        -- if debug then
            list("Collected senders in " .. mailboxname, senders)
        -- end
    end
    local messages_to_move = messages_from_senders(messages, senders)
    move_messages(messages_to_move, mailboxname)
end

function get_all_mailboxes()
    local mailboxes, folders = ACCOUNT:list_all()
    for _, folder in ipairs(folders) do
        local submailboxes, folders = ACCOUNT:list_all(folder)
        -- dump("Mailboxes in " .. folder, submailboxes)
        for _, mailbox in ipairs(submailboxes) do
            table.insert(mailboxes, mailbox)
        end
    end

    table.sort(mailboxes)
    --dump("Mailboxes", mailboxes)
    --list("Mailboxes", mailboxes)

    if debug then
        print("Mailboxes:")
        for _, mailbox in ipairs(mailboxes) do
            local total, recent, unseen, nextuid = ACCOUNT[mailbox]:check_status()
            print("- ", mailbox, total, recent, unseen)
        end
    end
    return mailboxes
end


----- Debuging Helpers

dumplib = require("dump")
function dump(msg, obj)
    if not obj then
        obj = msg
        msg = "XXX"
    end
    print(msg .. ": " .. dumplib.dumpstring(obj))
end
function list(msg, obj)
    msg = msg or ""
    print(msg .. ":")
    for _, item in ipairs(obj) do
        print("- " .. item)
    end
    print()
end
