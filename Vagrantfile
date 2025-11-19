Vagrant.configure("2") do |config|
  # Definicje zmiennych (bez zmian)
  DB_HOST = "192.168.56.10"
  DB_PORT = "5432"
  DB_NAME = "restaurant_management_system"
  DB_USER = "postgres"
  DB_PASSWORD = "postgres"
  
  # Adresy maszyn
  BACKEND_HOST = "192.168.56.11"
  FRONTEND_HOST = "192.168.56.12"
  BUILD_HOST = "192.168.56.13"
  ARTIFACT_HOST = "192.168.56.14"
  PROXY_HOST = "192.168.56.15"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  # 1. Baza Danych (Bez większych zmian, służy jako zasób)
  config.vm.define "db" do |db|
    db.vm.box = "debian/bookworm64"
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: DB_HOST
    db.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/db.yml"
      ansible.install = true
      ansible.extra_vars = {
        db_name: DB_NAME, db_user: DB_USER, db_password: DB_PASSWORD
      }
    end
  end

  # 2. Maszyna Build (Nowa - do kompilacji)
  config.vm.define "build" do |bld|
    bld.vm.box = "debian/bookworm64"
    bld.vm.hostname = "build"
    bld.vm.network "private_network", ip: BUILD_HOST
    bld.vm.synced_folder ".", "/vagrant" # Dostęp do kodu źródłowego z hosta
    bld.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/build_provision.yml"
      ansible.install = true
    end
  end

  # 3. Maszyna Artifact (Nowa - magazyn)
  config.vm.define "artifact" do |art|
    art.vm.box = "debian/bookworm64"
    art.vm.hostname = "artifact"
    art.vm.network "private_network", ip: ARTIFACT_HOST
    art.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/artifact.yml"
      ansible.install = true
    end
  end

  # 4. Backend (Zmodyfikowana - tylko uruchamia gotowy JAR)
  config.vm.define "backend" do |backend|
    backend.vm.box = "debian/bookworm64"
    backend.vm.hostname = "backend"
    backend.vm.network "private_network", ip: BACKEND_HOST
    backend.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/backend.yml"
      ansible.install = true
      ansible.extra_vars = {
        db_host: DB_HOST, db_port: DB_PORT, db_name: DB_NAME,
        db_user: DB_USER, db_password: DB_PASSWORD, backend_port: "8080"
      }
    end
  end

  # 5. Frontend (Zmodyfikowana - serwuje pliki statyczne Nginxem)
  config.vm.define "frontend" do |frontend|
    frontend.vm.box = "debian/bookworm64"
    frontend.vm.hostname = "frontend"
    frontend.vm.network "private_network", ip: FRONTEND_HOST
    frontend.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/frontend.yml"
      ansible.install = true
    end
  end

  # 6. Proxy (Nowa - Gateway)
  config.vm.define "proxy" do |proxy|
    proxy.vm.box = "debian/bookworm64"
    proxy.vm.hostname = "proxy"
    proxy.vm.network "private_network", ip: PROXY_HOST
    # Port forwarding dla wygody testowania z przeglądarki hosta
    proxy.vm.network "forwarded_port", guest: 80, host: 8080
    proxy.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/proxy.yml"
      ansible.install = true
      ansible.extra_vars = {
        frontend_host: FRONTEND_HOST,
        backend_host: BACKEND_HOST
      }
    end
  end
end