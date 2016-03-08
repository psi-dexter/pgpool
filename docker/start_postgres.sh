#!/bin/bash

__clean_pids() {
    rm -rf /tmp/.s*
}

__setup_consul() {
 cp /etc/host/consul/config.json /etc/consul/config.json
 LOCAL_IP=`curl http://169.254.169.254/2009-04-04/meta-data/local-ipv4`
 sed -i 's/{ipv4}/'$LOCAL_IP'/g' /etc/consul/z_conf.json
 sed -i 's/"server":true/"server":false/g' /etc/consul/config.json
 sed -i 's/"node_name":"/"node_name":"pool-/g' /etc/consul/config.json
}

__fix_permissions() {
 chown -v postgres.postgres /var/lib/pgsql/9.4/data/pg_hba.conf
 chown -v postgres.postgres /var/lib/pgsql/9.4/repmgr/repmgr.conf
 chown -v postgres.postgres /var/lib/pgsql/9.4/data/postgresql.conf
 chown -v postgres.postgres /register-master.sh
}

__fix_sshd() {
    cp /etc/host/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
    chown root.root /etc/ssh/ssh_host_rsa_key
    chmod 400 /etc/ssh/ssh_host_rsa_key
    chmod 400 /var/lib/pgsql/.ssh/id_rsa
    chmod 400 /var/lib/pgsql/.ssh/authorized_keys
    chmod 400 /root/.ssh/id_rsa
    chmod 400 /root/.ssh/authorized_keys
    sed -i 's/#   Port 22/Port 2022/g' /etc/ssh/ssh_config
    sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
}
__setup_pgpool() {
    su --login - postgres --command "pg_md5 -m -u pgpool secret"
    echo "pgpool:$(pg_md5 secret)" > /etc/pgpool-II-94/pcp.conf
    su --login - postgres --command "pg_md5 -m -u postgres postgres"
    echo "postgres:$(pg_md5 postgres)" > /etc/pgpool-II-94/pcp.conf
}
__run_supervisor() {
supervisord -n
}

# Call all functions
__clean_pids
__setup_consul
__fix_permissions
__fix_sshd
__setup_pgpool
__run_supervisor

