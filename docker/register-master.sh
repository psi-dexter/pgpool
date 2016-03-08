#!/bin/bash
sleep 10
if  ping -c 2 master.postgres.service.snapexit
then
    echo "master avalible"
    su --login - postgres --command "/usr/pgsql-9.4/bin/repmgr -h master.postgres.service.snapexit -U repmgr -d repmgr -D /var/lib/pgsql/9.4/data -f /var/lib/pgsql/9.4/repmgr/repmgr.conf standby clone"
    #python /opt/aws/register_service.py 'postgres' '{ipv4}' 5432 'node${node_num}'
    supervisorctl start postgresql
    exit 0
else
    echo "master unavailible"
    supervisorctl start postgresql
    python /opt/aws/claim_master.py '{ipv4}'
    su --login - postgres --command "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\""
    su --login - postgres --command "psql -c \"DROP DATABASE template1;\""
    su --login - postgres --command "psql -c \"CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';\""
    su --login - postgres --command "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\""
    su --login - postgres --command "psql -d template1 -c \"VACUUM FREEZE;\""
    su --login - postgres --command "/usr/pgsql-9.4/bin/createuser --replication -s repmgr"
    su --login - postgres --command "/usr/pgsql-9.4/bin/createdb repmgr -O repmgr"
    su --login - postgres --command "psql -d repmgr -c \"ALTER USER repmgr SET search_path TO repmgr_test, repmgr, public;\""
    su --login - postgres --command "/usr/pgsql-9.4/bin/repmgr -f /var/lib/pgsql/9.4/repmgr/repmgr.conf --verbose master register"
    exit 0
fi
