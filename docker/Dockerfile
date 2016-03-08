# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>

FROM centos:centos7
MAINTAINER The CentOS Project <cloud-ops@centos.org>

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release; yum clean all
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm
RUN yum -y install postgresql94-server postgresql94-contrib supervisor; yum clean all
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/repmgr94-2.0.2-4.rhel7.x86_64.rpm
RUN yum -y install openssh-server openssh-clients
RUN yum -y install rsync
RUN yum -y install pgpool-II-94

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./register-master.sh /register-master.sh
ADD ./start_postgres.sh /start_postgres.sh
ADD ./z_conf.json /etc/consul/z_conf.json
ADD ./register_service.py /opt/aws/register_service.py
ADD ./claim_master.py /opt/aws/claim_master.py

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
RUN chmod +x /usr/bin/postgresql-setup
RUN chmod +x /start_postgres.sh
RUN chmod +x /register-master.sh
RUN /usr/bin/postgresql-setup initdb

ADD ./postgresql.conf /var/lib/pgsql/9.4/data/postgresql.conf
RUN mkdir -p /var/lib/pgsql/9.4/repmgr/
RUN mkdir -p /var/lib/pgsql/9.4/.ssh/
ADD ./keys/authorized_keys /var/lib/pgsql/.ssh/authorized_keys
ADD ./keys/id_rsa /var/lib/pgsql/.ssh/id_rsa
ADD ./keys/id_rsa.pub /var/lib/pgsql/.ssh/id_rsa.pub

ADD ./keys/authorized_keys /root/.ssh/authorized_keys
ADD ./keys/id_rsa /root/.ssh/id_rsa
ADD ./keys/id_rsa.pub /root/.ssh/id_rsa.pub


ADD ./repmgr.conf /var/lib/pgsql/9.4/repmgr/
ADD ./pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf
RUN chown -v postgres.postgres /var/lib/pgsql/9.4/data/pg_hba.conf
RUN chown -v postgres.postgres /var/lib/pgsql/9.4/repmgr/
RUN chown -v postgres.postgres /var/lib/pgsql/9.4/repmgr/repmgr.conf
RUN chown -v postgres.postgres /var/lib/pgsql/9.4/data/postgresql.conf
RUN chown -v postgres.postgres /var/lib/pgsql/.ssh/
RUN chown -v postgres.postgres /var/lib/pgsql/.ssh/authorized_keys
RUN chown -v postgres.postgres /var/lib/pgsql/.ssh/id_rsa
RUN chown -v postgres.postgres /var/lib/pgsql/.ssh/id_rsa.pub

ADD ./pool_hba.conf /etc/pgpool-II-94/pool_hba.conf
ADD ./pgpool.conf /etc/pgpool-II-94/pgpool.conf
ADD ./failover.sh /etc/pgpool-II-94/failover.sh
RUN touch /etc/pgpool-II-94/pool_passwd
RUN chown -v postgres:postgres /etc/pgpool-II-94/pool_passwd


VOLUME ["/var/lib/pgsql/9.4"]

EXPOSE 5432
EXPOSE 9999

CMD ["/bin/bash", "/start_postgres.sh"]
