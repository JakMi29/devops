#!/bin/bash

echo "=== [1/3] Uruchamianie kompilacji na maszynie Build ==="
# Kopiujemy kod źródłowy do maszyny build (korzystając z shared folder /vagrant)
# W tym scenariuszu zakładam, że kod źródłowy jest w folderze projektu na hoście.

vagrant ssh build -c "
    # 1. Backend Build
    cp -r /vagrant/RestaurantManagementSystem/backend /home/vagrant/
    cd /home/vagrant/backend
    chmod +x gradlew
    ./gradlew clean build -x test
    
    # Pakowanie artefaktu Backend
    mv build/libs/*SNAPSHOT.jar /vagrant/backend-artifact.jar
    
    # 2. Frontend Build
    cp -r /vagrant/RestaurantManagementSystem/frontend /home/vagrant/
    cd /home/vagrant/frontend
    npm install
    npm run build
    
    # Pakowanie artefaktu Frontend (folder dist)
    tar -czf /vagrant/frontend-artifact.tar.gz -C dist .
"

echo "=== [2/3] Wysyłanie artefaktów na maszynę Artifact ==="
# Pliki są teraz w folderze projektu na Twoim komputerze (dzięki /vagrant mount).
# Wysyłamy je na maszynę Artifact.

vagrant ssh artifact -c "
    # Pobranie z shared folder do katalogu nginx
    sudo cp /vagrant/backend-artifact.jar /var/www/html/artifacts/
    sudo cp /vagrant/frontend-artifact.tar.gz /var/www/html/artifacts/
    sudo chmod 755 /var/www/html/artifacts/*
"

echo "=== [3/3] Sprzątanie lokalne ==="
# Usuwamy pliki tymczasowe z folderu projektu
rm backend-artifact.jar frontend-artifact.tar.gz

echo "BUILD SUCCESS: Artefakty dostępne na http://192.168.56.14/artifacts/"