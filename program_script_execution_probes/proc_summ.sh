#!/bin/bash
# Summarizes %CPU, %MEM, VSZ and RSS for a process pvided as an arg.

ps aux | grep -i $1 | grep -v grep | awk '{cpu += $3; mem += $4; vsz += $5; rss += $6} END { print "\{\"cpu\":\""cpu,"\",\"mem\":\""mem,"\",\"vsz\":"vsz,",\"rss\":"rss "\}" }'