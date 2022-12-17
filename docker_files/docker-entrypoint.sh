#!/bin/bash

rm /var/run/redis/redis-server.pid
/etc/init.d/redis-server start

set -e

/opt/superset_gunicorn/run_server.sh
tail -f /dev/null
