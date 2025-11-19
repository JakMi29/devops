#!/bin/bash

# Generujemy inventory tymczasowe dla Ansible, używając konfiguracji SSH vagranta
# To pozwala ansible łączyć się z maszynami bez ręcznego podawania kluczy

echo "Generowanie inventory..."
cat <<EOF > deploy_inventory.ini
[backend]
192.168.56.11 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/backend/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[frontend]
192.168.56.12 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/frontend/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "Uruchamianie wdrażania..."
ansible-playbook -i deploy_inventory.ini ansible/deploy_playbook.yml

echo "DEPLOY SUCCESS!"
echo "Aplikacja dostępna przez Proxy: http://localhost:8080 (przekierowanie na 192.168.56.15)"