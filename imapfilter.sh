#!/bin/bash
imapfilter -c imapfilter.lua -l log.err "$@" 2>&1 | tee log.out
