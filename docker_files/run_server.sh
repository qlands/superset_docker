#! /bin/bash

/wait

mysql -h $MYSQL_HOST_NAME -u $MYSQL_USER_NAME --ssl-mode=DISABLED --password=$MYSQL_USER_PASSWORD --execute='CREATE SCHEMA IF NOT EXISTS superset'

if [ ! -f /opt/superset_env/src/superset/superset_config.py ]; then
    ln -s /opt/superset_config/superset_config.py /opt/superset_env/src/superset
fi
source /opt/superset_env/bin/activate
superset db upgrade
if [ ! -f /opt/superset_config/super_user_created.txt ]; then
    superset fab create-admin --username $SUPERSET_ADMIN_USERNAME --firstname $SUPERSET_ADMIN_FIRSTNAME --lastname $SUPERSET_ADMIN_LASTNAME --email $SUPERSET_ADMIN_EMAIL --password $SUPERSET_ADMIN_PASSWORD
    touch /opt/superset_config/super_user_created.txt
fi

if [ ! -f /opt/superset_config/db_initialized.txt ]; then
    superset init
    touch /opt/superset_config/db_initialized.txt
fi
rm /opt/superset_gunicorn/superset.pid
gunicorn -D -p /opt/superset_gunicorn/superset.pid -w 10 -k gevent --timeout 120 -b $SUPERSET_HOST:$SUPERSET_PORT --limit-request-line 0 --limit-request-field_size 0 --log-file /opt/superset_gunicorn/superset.log --proxy-protocol --proxy-allow-from [*] "superset.app:create_app()"
