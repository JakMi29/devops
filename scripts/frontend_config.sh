#!/bin/bash
apt-get update
apt-get install -y nodejs npm git
cd /vagrant/RestaurantManagementSystem
cp -r ./frontend /opt/
cd /opt/frontend
npm install
VITE_BACKEND_URL='http://192.168.56.11:8080' npm run dev -- --host 0.0.0.0 --port 5173 &