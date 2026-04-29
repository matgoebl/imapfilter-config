#!/bin/sh
echo "Build: `cat /buildtag`"

[ -n "$SENDERS_PATH" ] || export SENDERS_PATH=$PWD/senders/
mkdir -p "$SENDERS_PATH"

export LUA_PATH="$PWD/lua/?.lua;$PWD/?.lua"
exec tini -- imapfilter -c lua/imapfilter.lua
