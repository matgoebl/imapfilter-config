#!/bin/bash
export LUA_PATH="$PWD/lua/?.lua;$PWD/?.lua"

pkill --uid `id -un` --exact --echo imapfilter
rm -f *.log

if [ "$1" = "-n" ]; then  # dry-run
 DEBUG=y DRYRUN=y imapfilter -c lua/imapfilter.lua
elif [ "$1" = "-d" ]; then  # debug
 DEBUG=y imapfilter -c lua/imapfilter.lua -l err.log 2>&1 | tee out.log
else  # normal
 DEBUGLOGFILE=debug.log imapfilter -c lua/imapfilter.lua -l err.log
 sleep 1
 tail -n +0 -f debug.log
fi
