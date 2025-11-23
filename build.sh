#!/bin/bash

# Ten skrypt jest przeznaczony do uruchamiania WEWNĄTRZ maszyny Build (192.168.56.13)
# Służy do zbudowania aplikacji i wysłania jej na maszynę Artifact (192.168.56.14)

# Zatrzymanie skryptu w przypadku błędu
set -e

# Konfiguracja
ARTIFACT_HOST="192.168.56.14"
ARTIFACT_USER="vagrant"
ARTIFACT_PASS="vagrant"
export VITE_BACKEND_URL=""
# Katalogi robocze (używamy katalogu domowego, aby uniknąć problemów z blokowaniem plików na Windows/shared folder)
WORK_DIR="/home/vagrant/build_work"

echo "=== [1/4] Przygotowanie środowiska ==="
# Czyszczenie poprzednich buildów
rm -rf $WORK_DIR
mkdir -p $WORK_DIR

# Sprawdzenie czy sshpass jest zainstalowany
if ! command -v sshpass &> /dev/null; then
    echo "Błąd: sshpass nie jest zainstalowany."
    sudo apt-get install -y sshpass
fi

echo "=== [2/4] Budowanie Backend (Java/Gradle) ==="
echo "--> Kopiowanie źródeł..."
cp -r /vagrant/RestaurantManagementSystem/backend $WORK_DIR/backend

echo "--> Kompilacja..."
cd $WORK_DIR/backend
# Naprawa końców linii w razie gdyby Windows je popsuł
sed -i 's/\r$//' gradlew
chmod +x gradlew
./gradlew clean build -x test --no-daemon

# Znalezienie pliku wynikowego .jar
JAR_FILE=$(find build/libs -name "*SNAPSHOT.jar" | head -n 1)
if [ -z "$JAR_FILE" ]; then
    echo "Błąd: Nie znaleziono pliku .jar po budowaniu!"
    exit 1
fi

echo "=== [3/4] Budowanie Frontend (Node/Vite) ==="
echo "--> Kopiowanie źródeł..."
cp -r /vagrant/RestaurantManagementSystem/frontend $WORK_DIR/frontend

echo "--> Instalacja i Build..."
cd $WORK_DIR/frontend
npm install
npm run build

echo "--> Pakowanie do .tar.gz..."
cd dist
tar -czf $WORK_DIR/frontend-artifact.tar.gz .

echo "=== [4/4] Wysyłanie artefaktów na maszynę Artifact ($ARTIFACT_HOST) ==="

# 1. Wysyłamy pliki do /tmp na maszynie Artifact (bo tam vagrant ma prawo zapisu)
echo "--> Upload przez SCP..."
sshpass -p "$ARTIFACT_PASS" scp -o StrictHostKeyChecking=no $WORK_DIR/backend/$JAR_FILE $ARTIFACT_USER@$ARTIFACT_HOST:/tmp/backend-artifact.jar
sshpass -p "$ARTIFACT_PASS" scp -o StrictHostKeyChecking=no $WORK_DIR/frontend-artifact.tar.gz $ARTIFACT_USER@$ARTIFACT_HOST:/tmp/frontend-artifact.tar.gz

# 2. Przenosimy pliki z /tmp do docelowego folderu Nginx (wymaga sudo na maszynie zdalnej)
echo "--> Przenoszenie do katalogu publikacji..."
sshpass -p "$ARTIFACT_PASS" ssh -o StrictHostKeyChecking=no $ARTIFACT_USER@$ARTIFACT_HOST "sudo mv /tmp/backend-artifact.jar /var/www/html/artifacts/ && sudo mv /tmp/frontend-artifact.tar.gz /var/www/html/artifacts/ && sudo chmod 755 /var/www/html/artifacts/*"

echo "========================================================"
echo "SUKCES! Artefakty zostały zbudowane i wysłane."
echo "Sprawdź: http://$ARTIFACT_HOST/artifacts/"
echo "========================================================"