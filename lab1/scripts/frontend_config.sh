#!/bin/bash
echo "--- Uruchamianie skryptu db_config.sh ---"
sudo apt-get update
sudo apt-get install -y nodejs npm git
sudo git clone https://github.com/JakMi29/RestaurantManagementSystem
cd RestaurantManagementSystem
cd frontend
sudo npm install
sudo VITE_BACKEND_URL='http://192.168.33.11:8080' npm run dev -- --host 0.0.0.0 --port 5173