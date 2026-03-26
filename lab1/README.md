# Web service deployment with automation  

## 1. Individual task option

N is the the student's serial number in the group list:  
**Variant (N) = 27**  

V2 = (N % 2) + 1 = (27 % 2) + 1 =  1 + 1 = 2  
V3 = (N % 3) + 1 = (27 % 3) + 1 = 0 + 1 = 1   
V5 = (N % 5) + 1 = (27 % 5) = 2 + 1 = 3  

Depends on the value of **V3** the theme of the web application is **Notes Service — простий сервіс для зберігання текстових нотаток** . 

Depending on **V2**, the configuration method (interface, port, connection to the database) of the application is **Конфігураційний файл за шляхом /etc/mywebapp/config.<extension>
Формат файлу конфігурації визначаєте самостійно на ваш розсуд та обираєте відповідне розширення файлу**.

Depending on **V5**, the port on which the application will listen is **3000**.

Depending on **V2**, a DBMS for the application is **PostgreSQL**.

------------------------------------  

## 2. Documentation for the developed web application  

Mywebapp is a server-side web application developed using the Express.js (Node.js) framework. Its main purpose is to demonstrate the deployment architecture and management of system resources via a REST API.

### System benefits
Check if this installed in the system:

**Node.js: v20.x or newer**   
**npm: v10.x or newer**  
**PostgreSQL: v15 or newer**  

### Local Environment  

**1. Clone repository**
```bash
git clone https://github.com/Impe11e/SoftwareDeployment.git software_deployment
```

**2. Go to project folder**
```bash
cd software_deployment/lab1
```

**3. Install dependencies**
```bash
npm i
```

**4. Configuration (Important):**
Create a config file at '/etc/mywebapp/config.json' (or go to the correct settings), so you know how to connect to PostgreSQL:

```bash
sudo mkdir -p /etc/mywebapp
sudo nano /etc/mywebapp/config.json
```

```bash
{
  "server": {
    "host": "127.0.0.1",
    "port": 3000
  },
  "db": {
    "user": "app",
    "host": "127.0.0.1",
    "database": "mywebapp_db",
    "password": "password",
    "port": 5432
  }
}
```
**5. Set up a database**  

```bash
-- 0. Login to the database console
sudo -u postgres psql

-- 1. Create a database (the name has be taken from config.json)
CREATE DATABASE 'mywebapp_db';

-- 2. Create a user and give him a password
CREATE USER 'app' WITH ENCRYPTED PASSWORD 'password';

-- 3. Give the user all rights to the database
GRANT ALL PRIVILEGES ON DATABASE 'mywebapp_db' TO 'app';

-- 4. Log in to the database and grant rights to the schema (critical for Postgres 15+)
\c 'mywebapp_db'
GRANT ALL ON SCHEMA public TO 'app';

-- 5. Exit
\q
```

**6. Start the server**
```bash
node mywebapp/src/app.js 
```

### API endpoint documentation

| Метод | Ендпоінт | Опис | Приклад запиту / відповіді |
|-------|----------|------|----------------------------|
| GET | / | Головна сторінка застосунку | 200 OK (Welcome message) |
| GET | /notes | Отримати список усіх нотаток | 200 OK: [{"id": 1, "title": "Note"}] |
| POST | /notes | Створити нову нотатку | "Body: {"title": "...", "content": "..."} → 201 Created"|
| GET | /notes/:id | Отримати нотатку за конкретним ID | "GET /notes/1 → {""id"": 1, ""title"": ""..."", ""content"": ""..."", ""createdAt"": "..."}"|
| GET | /health/alive | Перевірка працездатності сервісу | "200 OK: OK |
| GET | /health/ready | Перевірка готовності БД | 200 OK: OK (або 500 при помилці БД) |

## Documentation on the Deployment  

### Virtual Machine Image  
Use [ubuntu 24.04 LTS](https://ubuntu.com/download/desktop)

### How to login to the VM (SSH, Console) and how to obtain credentials (for the correspondent):  

Login to the VM via SSH:  
```bash
ssh student@VM_ip
```
**Credentias:**  
User - student  
Password - studentpass  

### To start automating the deployment you need:

**1. Clone repository**
```bash
git clone https://github.com/Impe11e/SoftwareDeployment.git software_deployment
```

**2. Go to project folder**
```bash
cd software_deployment/lab1/scripts
```

**3. Run setup script**  
```bash
sudo bash setup.sh
```

## Testing the system

### 1. Verification of Nginx and API (External access)  

Checking the list of endpoints (Root route):
```Bash
curl -i -H "Accept: text/html" http://localhost/
```

Checking "business logic" (Option 3 — Inventory):
Getting a list (JSON):
```Bash
curl -i -H "Accept: application/json" http://localhost/notes
```

Getting a list (HTML table):
```Bash
curl -i -H "Accept: text/html" http://localhost/notes
```

Creating a note:
```Bash
curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Test", "content":"hello"}' http://localhost/notes
```

Detailed information by ID (replace 1 with the real ID):
```Bash
curl -i -H "Accept: application/json" http://localhost/notes/1
```

### 2. Verification of technical endpoints (Internal access)
Here we verify that health is running locally but is closed through Nginx.

Via Nginx (Should be 403 Forbidden):

```Bash
curl -i curl -i http://'your_ip'/health/alive
curl -i curl -i http://'your_ip'/health/ready
```

Directly to the application (200 OK):

```Bash
curl -i http://localhost/health/alive
curl -i http://localhost/health/ready
```

### 3. Check the database (PostgreSQL)
We check that the database is only available locally and the tables are created by migration.

Check the connection:
```bash
sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw mywebapp_db && echo "Database exists"
```

Checking the existence of the table:
```bash
sudo -u postgres psql -d mywebapp_db -c "\dt"
```
### 4. Checking users rights   
**1. Student and teacher verification (Admins)**  
They should be able to do everything via sudo.

Command:  
```Bash
sudo -l -U student
sudo -l -U teacher
```
Expected result: There should be a line (ALL : ALL) ALL, which means full access.  

Password verification: At the first login (ssh teacher@ip) the system should ask for 12345678 and immediately force you to enter a new one.  

**2. Operator check (Limited access)**  

Check which commands are allowed:  

```bash
sudo -l -U operator
``` 

The allowed command (should work):
```bash
sudo systemctl status mywebapp
```

The forbidden command (should give an error: Sorry, user operator is not allowed to execute...):

```bash
sudo apt update or sudo cat /etc/shadow
```

**3. Check app (System User)**  
This user should not be able to log in or execute sudo.

```bash
sudo -l -U app
```
Expected result: User app is not allowed to run sudo on nodeserver3.

Shell check:

```bash
grep app /etc/passwd
```

If it ends with /usr/sbin/nologin or /bin/false - minimal rights.

## 5. Checking system requirements (gradebook and rights)  

Does the gradebook file exist:
```bash
cat /home/student/gradebook
```

Checking who is running the service (Must be the user app):
```bash
ps aux | grep app | grep -v grep
```

### 6. Checking Nginx logs

Prove that the proxy captures requests:
```bash
sudo tail -f /var/log/nginx/mywebapp_access.log
sudo tail -f /var/log/nginx/mywebapp_error.log
```