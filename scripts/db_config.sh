#!/bin/bash
apt-get update
apt-get install -y postgresql postgresql-contrib
PG_CONF=$(find /etc/postgresql/ -name 'postgresql.conf' -print -quit)
PG_HBA=$(find /etc/postgresql/ -name 'pg_hba.conf' -print -quit)
sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/^listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
echo "host all all 192.168.56.0/24 md5" | tee -a "$PG_HBA" > /dev/null
systemctl start postgresql
systemctl enable postgresql
echo "ALTER USER postgres WITH PASSWORD 'postgres';" | sudo -u postgres psql
echo "CREATE DATABASE restaurant_management_system;" | sudo -u postgres psql
