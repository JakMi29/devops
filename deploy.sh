#!/bin/bash

# Ten skrypt jest przeznaczony do uruchamiania WEWNĄTRZ maszyny Build (192.168.56.13)
# Służy do pobrania artefaktów z maszyny Artifact i wdrożenia ich na Front/Back.

set -e

# Konfiguracja adresów
ARTIFACT_URL="http://192.168.56.14/artifacts"
BACKEND_IP="192.168.56.11"
FRONTEND_IP="192.168.56.12"
WORK_DIR="/home/vagrant/deploy_work"

echo "=== [1/3] Przygotowanie środowiska Ansible ==="
mkdir -p $WORK_DIR
cd $WORK_DIR

# 1. Generowanie pliku Inventory dla Ansible
# Definiujemy gdzie są maszyny i jak się do nich połączyć (użytkownik/hasło: vagrant/vagrant)
cat <<EOF > inventory.ini
[backend]
$BACKEND_IP ansible_user=vagrant ansible_password=vagrant ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[frontend]
$FRONTEND_IP ansible_user=vagrant ansible_password=vagrant ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

# 2. Generowanie Playbooka (Instrukcji wdrożenia)
# Ten plik YAML mówi Ansible'owi co dokładnie ma zrobić na zdalnych maszynach
cat <<EOF > deploy_playbook.yml
---
- name: Deploy Backend Application
  hosts: backend
  become: true
  tasks:
    - name: Ensure Java is installed
      apt: name=openjdk-17-jre-headless state=present update_cache=yes

    - name: Stop existing service
      systemd:
        name: spring-boot
        state: stopped
      ignore_errors: yes

    - name: Download new Artifact (.jar)
      get_url:
        url: "$ARTIFACT_URL/backend-artifact.jar"
        dest: /opt/backend/app.jar
        mode: '0755'
        force: yes

    - name: Start service
      systemd:
        name: spring-boot
        state: restarted
        enabled: yes

- name: Deploy Frontend Application
  hosts: frontend
  become: true
  tasks:
    - name: Ensure Nginx and unzip are installed
      apt:
        name:
            - nginx
            - unzip
        state: present
        update_cache: yes

    - name: Clean old files
      file:
        path: /var/www/html
        state: absent

    - name: Create web directory
      file:
        path: /var/www/html
        state: directory
        mode: '0755'

    - name: Download and Unarchive Artifact (.tar.gz)
      unarchive:
        src: "$ARTIFACT_URL/frontend-artifact.tar.gz"
        dest: /var/www/html/
        remote_src: yes
        extra_opts: ['-o']

    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
EOF

echo "=== [2/3] Uruchamianie Ansible Playbook ==="

# Sprawdzenie czy ansible jest zainstalowane
if ! command -v ansible-playbook &> /dev/null; then
    echo "Instalowanie Ansible..."
    sudo apt-get update && sudo apt-get install -y ansible sshpass
fi

# Uruchomienie wdrożenia
# export ANSIBLE_HOST_KEY_CHECKING=False zapobiega pytaniom o potwierdzenie fingerprinta SSH
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini deploy_playbook.yml

echo "=== [3/3] Weryfikacja i Sprzątanie ==="
rm -rf $WORK_DIR

echo "========================================================"
echo "DEPLOY SUCCESS!"
echo "Backend działa na: http://$BACKEND_IP:8080"
echo "Frontend działa na: http://$FRONTEND_IP"
echo "Proxy (punkt wejścia): http://192.168.56.15 (lub localhost:8080 na Windowsie)"
echo "========================================================"