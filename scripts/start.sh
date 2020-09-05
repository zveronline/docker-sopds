#!/bin/bash

waiting_db(){
while ! pg_isready -U postgres > /dev/null
do
    echo "$(date) - waiting for database to start"
    sleep 10
done
}

if ! [ -d /run/postgresql ]
then
mkdir -p /run/postgresql
chown -R postgres:postgres /run/postgresql
fi

if [[ $EXT_DB == False && ! -f /var/lib/pgsql/data/PG_VERSION ]] 
then
chown -R postgres:postgres /var/lib/pgsql
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data initdb"
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/data/pg.log start"
waiting_db
psql -U postgres -c "create database sopds"
psql -U postgres -c "create user sopds with password 'sopds'"
psql -U postgres -c "grant all privileges on database sopds to sopds"
cd /sopds
python3 manage.py migrate
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/data/pg.log stop"




fi
if [ $EXT_DB == False ]
then
su postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/data/pg.log start"
waiting_db
fi
cd /sopds
if [ $MIGRATE == True ]
then
python3 manage.py migrate
fi
if [ ! -f /var/lib/pgsql/setconf ]
then
python3 manage.py sopds_util setconf SOPDS_ROOT_LIB $SOPDS_ROOT_LIB
python3 manage.py sopds_util setconf SOPDS_INPX_ENABLE $SOPDS_INPX_ENABLE
python3 manage.py sopds_util setconf SOPDS_LANGUAGE $SOPDS_LANGUAGE
#autocreate the superuser
if [[ ! -z $SOPDS_SU_NAME && ! -z $SOPDS_SU_EMAIL &&  ! -z $SOPDS_SU_PASS ]]
then
expect /sopds/superuser.exp
fi
#
touch /var/lib/pgsql/setconf
fi
python3 manage.py sopds_server start & python3 manage.py sopds_scanner start
