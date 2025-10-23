Vagrant.configure("2") do |config|
 config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048" 
    vb.cpus = 2        
  end

  config.vm.define "db" do |db|
    db.vm.box = "debian/bookworm64"
	  db.vm.hostname = "db"
    db.vm.network "forwarded_port", guest: 5432, host: 5432, host_ip: "127.0.0.1"
    db.vm.network "private_network", ip: "192.168.56.10"
    db.vm.synced_folder ".", "/vagrant"
    db.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/db.yml"
      ansible.install = true
    end
  end

  config.vm.define "backend" do |backend|
    backend.vm.box = "debian/bookworm64"
	  backend.vm.hostname = "backend"
    backend.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
    backend.vm.network "private_network", ip: "192.168.56.11"
    backend.vm.synced_folder "RestaurantManagementSystem/backend", "/vagrant/backend"
    backend.vm.synced_folder "ansible", "/vagrant/ansible"
    backend.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/backend.yml"
      ansible.install = true
    end
  end

  config.vm.define "frontend" do |frontend|
    frontend.vm.box = "debian/bookworm64"
	  frontend.vm.hostname = "frontend"
    frontend.vm.network "forwarded_port", guest: 5173, host: 5173, host_ip: "127.0.0.1"
    frontend.vm.network "private_network", ip: "192.168.56.12"
    frontend.vm.synced_folder "RestaurantManagementSystem/frontend", "/vagrant/frontend"
    frontend.vm.synced_folder "ansible", "/vagrant/ansible"
    frontend.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/frontend.yml"
      ansible.install = true
    end
  end
end