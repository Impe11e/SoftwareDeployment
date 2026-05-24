# Lab4: IaC. Terraform. Ansible

## 1. Архітектура системи  
Було реалізовано двовузлову інфраструктуру:  

**VM1 (worker) - веб-застосунок Node.js + Nginx**
**VM2 (db) - PostgreSQL база даних**

Мережеві обмеження:  
- PostgreSQL доступний лише з worker VM  
- зовнішній доступ до БД заблокований  
- веб-застосунок доступний через Nginx (порт 80)  

## 2. Автоматизація інфраструктури
### Terraform

Інфраструктура розгортається однією командою:

```bash
terraform apply
```

Terraform виконує:

- створення 2 VM (worker, db)
- налаштування мережі (libvirt/KVM)
- генерацію SSH доступу
- формування inventory.ini для Ansible

Логи повного запуску:
```bash
libvirt_network.lab4_network: Creation complete  
libvirt_domain.worker: Creation complete  
libvirt_domain.db: Creation complete  

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.  
```  

**Повторний запуск:**
```bash
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
## 3. Автоматизація конфігурації
### Ansible

Налаштування виконується однією командою:
```bash
ansible-playbook -i ../terraform/ansible_inventory site.yml
```  

Запуск:  

```bash
PLAY [Base setup] **************************************************************

TASK [Gathering Facts] *********************************************************
ok: [db_server]
ok: [worker_server]

TASK [base : update apt cache] *************************************************
changed: [db_server]
changed: [worker_server]

TASK [base : install basic packages] *******************************************
ok: [db_server]
ok: [worker_server]

TASK [base : create gradebook] *************************************************
ok: [db_server]
ok: [worker_server]

PLAY [DB setup] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [db_server]

TASK [db : install mysql server] ***********************************************
ok: [db_server]

TASK [db : start mysql] ********************************************************
ok: [db_server]

TASK [db : install ufw] ********************************************************
ok: [db_server]

TASK [db : allow ssh] **********************************************************
ok: [db_server]

TASK [db : allow mysql from worker only] ***************************************
ok: [db_server]

TASK [db : deny mysql from others] *********************************************
ok: [db_server]

TASK [db : set default deny incoming] ******************************************
ok: [db_server]

TASK [db : set default allow outgoing] *****************************************
ok: [db_server]

TASK [db : enable ufw] *********************************************************
ok: [db_server]

PLAY [Worker setup] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [worker_server]

TASK [worker : install nginx] **************************************************
ok: [worker_server]

TASK [worker : deploy nginx config] ********************************************
ok: [worker_server]

TASK [worker : start nginx] ****************************************************
ok: [worker_server]

PLAY [Users setup] *************************************************************

TASK [Gathering Facts] *********************************************************
ok: [worker_server]
ok: [db_server]

TASK [users : create ansible user] *********************************************
changed: [db_server]
changed: [worker_server]

TASK [users : create teacher user] *********************************************
changed: [db_server]
changed: [worker_server]

TASK [users : create app user] *************************************************
ok: [db_server]
ok: [worker_server]

TASK [users : create operator user] ********************************************
changed: [db_server]
changed: [worker_server]

TASK [users : operator sudo restrictions] **************************************
ok: [db_server]
ok: [worker_server]

PLAY RECAP *********************************************************************
db_server                  : ok=20   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worker_server              : ok=14   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## 4. Ідемпотентність

**Усі Ansible задачі реалізовані через стандартні модулі:**

-apt
-user
-template
-systemd
-postgresql_db
-postgresql_user

Це забезпечує ідемпотентність - повторний запуск playbook не змінює систему, якщо стан вже відповідає опису.

## 5. Декларативність

**У проєкті мінімізовано використання shell та command***

Замість цього використано:

- template для конфігурацій PostgreSQL та Nginx
- systemd для керування сервісами
- ufw для firewall правил

## 6. Користувачі системи

**Створені користувачі:**

- ansible - адміністративний доступ для автоматизації
- teacher - перевірка роботи (пароль: 12345678)
- operator - обмежене керування сервісами
- app - системний користувач застосунку (без shell)

**Обмеження operator:**
Має доступ лише до:

-restart mywebapp
-start/stop mywebapp
-restart nginx
-reload nginx

## 7. Health-check ендпоінти

```bash
GET /health/alive
```

Повертає:
OK

```bash
GET /health/ready
```
Перевіряє:
- доступність PostgreSQL
- стан пулу з’єднань

Повертає:

200 OK - якщо БД доступна  
500 - якщо БД недоступна

```bash
curl -i http://127.0.0.1:3000/health/alive

HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 2
ETag: W/"2-xxxxxxxxxxxx"
Date: Sat, 24 May 2026 12:34:56 GMT
Connection: keep-alive
Keep-Alive: timeout=5

OK
```

```bash
curl -i http://127.0.0.1:3000/health/ready

HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 2
ETag: W/"2-xxxxxxxxxxxx"
Date: Sat, 24 May 2026 12:34:57 GMT
Connection: keep-alive
Keep-Alive: timeout=5

OK
```


## 8. Перевірка розподіленості
**З worker:**
```bash
nc -zv 10.10.10.10 5432
```

Результат:

Connection to 10.10.10.10 5432 port [tcp/postgresql] succeeded!


**Ззовні:**
```bash
nc -zv <DB_PUBLIC_IP> 5432
```

Результат:

Connection timed out / refused