#!/bin/bash

set -e

/opt/superset_gunicorn/run_server.sh
tail -f /dev/null
