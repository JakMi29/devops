#!/bin/bash
apt-get update
apt-get install -y openjdk-17-jdk gradle git
cd /vagrant/RestaurantManagementSystem
cp -r ./backend /opt/
cd /opt/backend
chmod +x ./gradlew
./gradlew clean build -x test --no-daemon
cd build/libs
java -jar RestaurantManagementSystem-0.0.1-SNAPSHOT.jar --spring.datasource.url=jdbc:postgresql://192.168.56.10:5432/restaurant_management_system &
