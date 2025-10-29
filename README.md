# Projekt: System Zarządzania Restauracją (Restaurant Management System)

---

## Cel projektu

Celem projektu jest automatyzacja procesu tworzenia i konfiguracji kompletnego, wielowarstwowego środowiska deweloperskiego dla aplikacji "Restaurant Management System". [cite_start]Wykorzystano do tego Vagrant do zarządzania maszynami wirtualnymi [cite: 2] [cite_start]oraz Ansible do automatycznego provisioningu (konfiguracji oprogramowania) tych maszyn[cite: 5, 7, 9].

---

## Założenia projektu

* [cite_start]**Wirtualizacja:** Środowisko jest budowane przy użyciu Vagranta [cite: 2][cite_start], domyślnie ze wsparciem dla VirtualBox[cite: 3].
* [cite_start]**System Operacyjny:** Wszystkie trzy maszyny wirtualne (`db`, `backend`, `frontend`) używają tego samego obrazu systemu: `debian/bookworm64`[cite: 4, 6, 8].
* [cite_start]**Zarządzanie Konfiguracją:** Każda maszyna jest automatycznie konfigurowana przy starcie (`vagrant up`) za pomocą dedykowanego playbooka Ansible (`ansible_local`)[cite: 5, 7, 9].
* [cite_start]**Zasoby VM:** Maszyny wirtualne mają przydzielone 2 GB pamięci RAM oraz 2 rdzenie procesora[cite: 3].
* **Sieć:**
    * Maszyny komunikują się ze sobą w sieci prywatnej opartej na adresacji `192.168.56.0/24`.
    * [cite_start]**Baza Danych (db):** `192.168.56.10` [cite: 2]
    * [cite_start]**Backend:** `192.168.56.11` [cite: 2]
    * [cite_start]**Frontend:** `192.168.56.12` [cite: 2]
    * [cite_start]Kluczowe porty (5432, 8080, 5173) są przekierowane z maszyn wirtualnych na maszynę hosta (localhost)[cite: 2].
* **Zarządzanie kodem:**
    * [cite_start]Plik `.gitattributes` wymusza stosowanie końcówek linii (LF) dla pliku `gradlew`[cite: 1].
    * [cite_start]Plik `.gitignore` instruuje Git, aby ignorował katalog `.vagrant`[cite: 10].

---

## Aplikacja

Aplikacja składa się z trzech oddzielnych komponentów, z których każdy działa na dedykowanej maszynie wirtualnej:

* **Baza Danych (VM: `db`)**
    * **Technologia:** PostgreSQL (`postgresql`, `postgresql-contrib`).
    * **Konfiguracja (wg `db.yml`):**
        * Instaluje serwer PostgreSQL.
        * Modyfikuje `postgresql.conf`, aby serwer nasłuchiwał na wszystkich interfejsach sieciowych (`listen_addresses = '*'`).
        * Modyfikuje `pg_hba.conf`, aby zezwolić na połączenia z hasłem (md5) z całej sieci prywatnej (`192.168.56.0/24`).
        * Tworzy bazę danych o nazwie `restaurant_management_system`.
        * Ustawia hasło (`postgres`) dla użytkownika `postgres`.

* **Backend (VM: `backend`)**
    * **Technologia:** Java Spring Boot (projekt `RestaurantManagementSystem`).
    * **Konfiguracja (wg `backend.yml`):**
        * Instaluje zależności: `openjdk-17-jdk`, `gradle`, `git`.
        * Kopiuje kod źródłowy backendu do `/opt/backend/`.
        * Nadaje uprawnienia wykonywalne plikowi `gradlew`.
        * Buduje aplikację za pomocą polecenia `./gradlew clean build -x test` (z pominięciem testów).
        * Tworzy serwis `systemd` (`spring-boot.service`) do uruchamiania wygenerowanego pliku `.jar` (`RestaurantManagementSystem-0.0.1-SNAPSHOT.jar`).
        * Serwis jest uruchamiany z przekazanymi zmiennymi środowiskowymi (dane dostępowe do bazy danych).

* **Frontend (VM: `frontend`)**
    * **Technologia:** Aplikacja React (uruchamiana przez Vite).
    * **Konfiguracja (wg `frontend.yml`):**
        * Instaluje zależności: `nodejs`, `npm`, `git`.
        * Kopiuje kod źródłowy frontendu do `/opt/frontend/`.
        * Instaluje zależności projektu za pomocą `npm install`.
        * Tworzy serwis `systemd` (`vite.service`).
        * Serwis uruchamia serwer deweloperski Vite (`npm run dev`) na porcie 5173.
        * Do serwisu przekazywana jest zmienna środowiskowa `VITE_BACKEND_URL` wskazująca na adres maszyny backendowej (`http://192.168.56.11:8080`).

---

## Przygotowana architektura

Projekt implementuje klasyczną **architekturę 3-warstwową (3-tier)**, gdzie każda warstwa jest odseparowana na własnej maszynie wirtualnej.

1.  **Warstwa Danych (Data Tier):** Maszyna `db` z serwerem PostgreSQL.
2.  **Warstwa Logiki (Logic Tier):** Maszyna `backend` z aplikacją Spring Boot.
3.  **Warstwa Prezentacji (Presentation Tier):** Maszyna `frontend` z serwerem deweloperskim Vite/React.

Komunikacja przebiega następująco:
* Frontend (Vite) łączy się z Backendem (Spring Boot) poprzez sieć prywatną (na adres `192.168.56.11:8080`).
* Backend (Spring Boot) łączy się z Bazą Danych (PostgreSQL) poprzez sieć prywatną (na adres `192.168.56.10:5432`).

Całe środowisko jest w pełni zarządzane przez Vagrant, a konfiguracja jest zautomatyzowana przez Ansible, co pozwala na szybkie i powtarzalne uruchomienie aplikacji na dowolnej maszynie deweloperskiej.

---

## Refleksje i wnioski

Analiza plików konfiguracyjnych pozwala wyciągnąć następujące wnioski:

* **Środowisko deweloperskie:** Cała konfiguracja jest jednoznacznie zorientowana na stworzenie środowiska deweloperskiego, a nie produkcyjnego. Wskazują na to:
    * Uruchamianie serwera frontendu w trybie deweloperskim (`npm run dev`).
    * Pominięcie testów podczas budowania backendu (`-x test`).
    * [cite_start]Hardkodowanie poświadczeń (np. hasła do bazy danych) w pliku `Vagrantfile`[cite: 2].
    * Szerokie otwarcie bazy danych na całą podsieć prywatną (`192.168.56.0/24`).

* **Silna automatyzacja:** Projekt kładzie duży nacisk na zasadę "Infrastructure as Code". Użycie Vagranta i Ansible pozwala na odtworzenie identycznego środowiska przez każdego członka zespołu za pomocą jednej komendy (`vagrant up`).

* **Separacja warstw:** Zastosowanie 3-warstwowej architektury z odseparowanymi maszynami wirtualnymi jest dobrą praktyką, która ułatwia rozwój i testowanie poszczególnych komponentów niezależnie od siebie.