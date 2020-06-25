#!/bin/sh

sh /usr/local/bin/entrypoint.sh >/dev/null 2>/dev/null &

while true;do
    ps axhc -o command,%cpu -r | head
    sleep 3
done
