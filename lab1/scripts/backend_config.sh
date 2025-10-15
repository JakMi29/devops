#!/bin/bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk gradle git
sudo git clone https://github.com/JakMi29/RestaurantManagementSystem
cd RestaurantManagementSystem
cd backend
sudo chmod +x ./gradlew
sudo ./gradlew clean build -x test --no-daemon
cd build/libs
java -jar RestaurantManagementSystem-0.0.1-SNAPSHOT.jar --spring.datasource.url=jdbc:postgresql://192.168.33.10:5432/restaurant_management_system
