#!/bin/bash

if [ ! -f /var/lib/pgsql/data/base ]; then
su postgres -c "pg_ctl -D /var/lib/pgsql/data initdb"
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start"
sleep 30
psql -U postgres -c "create database sopds"
psql -U postgres -c "create user sopds with password 'sopds'"
psql -U postgres -c "grant all privileges on database sopds to sopds"
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile stop"
sleep 50
fi

su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start"

cd /sopds
python3 manage.py migrate
python3 manage.py sopds_util setconf SOPDS_ROOT_LIB '/library'
python3 manage.py sopds_util setconf SOPDS_INPX_ENABLE 'True'
python3 manage.py sopds_util setconf SOPDS_LANGUAGE ru-RU
python3 manage.py sopds_server start & python3 manage.py sopds_scanner start
