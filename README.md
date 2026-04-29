# imapfilter-config
IMAPFilter config to archive old mails to folders based on sender addresses

Install [imapfilter](https://github.com/lefcha/imapfilter) e.g. via `apt install imapfilter`.  
Copy `config.lua.example` to `config.lua` and adapt it to your needs.  
Run `imapfilter.sh`.

Set the following environment variables for debugging:
- `DEBUG=y`
- `DEBUG_TRACE=y`
- `DEBUGLOGFILE=debug.log`
- `NO_INITIAL_DAILY=y`
- `DRYRUN=y`

Configure your IMAP server with these environment variables:
- `IMAP_SERVER='imap.server.net'`
- `IMAP_USERNAME='your@name.net'`
- `IMAP_PASSWORD='xxx'`


## LICENSES

Imported:
- lua/base64.lua from https://github.com/iskolbin/lbase64/blob/master/base64.lua: Unknown license
- lua/match_utf8_field.lua from https://paste.sr.ht/~cybolic/902986c795599f558165c63bcb65a3d4ae15881e, referenced in https://github.com/lefcha/imapfilter/issues/127: Unknown license

All remaining files: Apache License 2.0
