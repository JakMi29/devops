#!/bin/bash
apt-get update
apt-get install -y nodejs npm git
cp -r /vagrant/frontend /opt/
chown -R vagrant:vagrant /opt/frontend
cd /opt/frontend
sudo -u vagrant npm install
sudo -u vagrant bash -c "VITE_BACKEND_URL='http://192.168.56.11:8080' npm run dev -- --host 0.0.0.0 --port 5173 &"