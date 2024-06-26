----- Main

function MAIN()

    require("imapfilterlib")

    ----- Options
    options.info = os.getenv('SERVER_INFO')
    debug = getenv_bool('DEBUG')
    reload_senders = getenv_bool('RELOAD_SENDERS')
    delete_all = getenv_bool('DELETE_ALL')
    dryrun = getenv_bool('DRYRUN')
    require("config")

    if not ACCOUNT or not FILTER_INBOX or not FILTER_DAILY then
        print("Error: config.lua must initialize ACCOUNT and define FILTER_INBOX() and FILTER_DAILY().")
        return 1
    end


    MAILBOXES = get_all_mailboxes()

    if delete_all then
        print("Delete all mailboxes...")
        for _, mailbox in ipairs(MAILBOXES) do
            ACCOUNT:delete_mailbox(mailbox)    
        end
        MAILBOXES = {}
        return 0
    end

    if debug then
        while true do
            print("DEBUG: restarting daemon loop...")
            DAEMON_LOOP()
            os.execute("sleep 60")
        end
    else
        DEBUGLOGFILE = os.getenv('DEBUGLOGFILE')
        if DEBUGLOGFILE then
            debug = true
            logfile = io.open (DEBUGLOGFILE, 'w')
            real_print = print
            print = function(...)
                for n, v in pairs( {...} ) do
                    if n > 1 then logfile:write("\t") end
                    logfile:write(tostring(v))
                end
                logfile:write("\n")
                logfile:flush()
            end
        end

        become_daemon(600, DAEMON_LOOP)
    end

end


function DAEMON_LOOP()

    date_last = ""  -- trigger execution in the first iteration
    if FILTER_INIT then
        FILTER_INIT()
    end
    while true do
        print("Running FILTER_INBOX()...")
        FILTER_INBOX()

        date_now = os.date("%Y-%m-%d")
        if date_now ~= date_last then
            print("Running FILTER_DAILY()...")
            MAILBOXES = get_all_mailboxes()
            FILTER_DAILY()
            date_last = date_now
        end

        print("waiting for IMAP event...")
        local call_ok, idle_ok, event = pcall( function () return ACCOUNT.INBOX:enter_idle() end )
        if call_ok and idle_ok then
            print(string.format("IMAP event: %s",event))
        else
            print("IMAP IDLE failed, delaying...")
            os.execute("sleep 600")
        end

    end
end

MAIN()
