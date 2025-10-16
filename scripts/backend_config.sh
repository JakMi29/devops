#!/bin/bash
apt-get update
apt-get install -y openjdk-17-jdk gradle git
cp -r /vagrant/backend /opt/
cd /opt/backend
chmod +x ./gradlew
./gradlew clean build -x test --no-daemon
sudo -u vagrant ./gradlew clean build -x test --no-daemon
cd build/libs
sudo -u vagrant bash -c "java -jar RestaurantManagementSystem-0.0.1-SNAPSHOT.jar --spring.datasource.url=jdbc:postgresql://192.168.56.10:5432/restaurant_management_system &"