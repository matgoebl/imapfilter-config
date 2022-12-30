#!/bin/bash
export LUA_PATH="$PWD/lua/?.lua;$PWD/?.lua"
pkill --uid `id -un` --exact --echo imapfilter
imapfilter -c lua/imapfilter.lua -l out.log -n "$@"
