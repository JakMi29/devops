#!/bin/bash
echo "--- Uruchamianie skryptu db_config.sh ---"
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
PG_CONF=$(find /etc/postgresql/ -name 'postgresql.conf' -print -quit)
PG_HBA=$(find /etc/postgresql/ -name 'pg_hba.conf' -print -quit)
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sudo sed -i "s/^listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
echo "host all all 192.168.33.0/24 md5" | sudo tee -a "$PG_HBA" > /dev/null
sudo systemctl restart postgresql
echo "ALTER USER postgres WITH PASSWORD 'postgres';" | sudo -u postgres psql
echo "CREATE DATABASE restaurant_management_system;" | sudo -u postgres psql
