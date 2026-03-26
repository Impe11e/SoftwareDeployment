#!/bin/bash
set -e

ROOT_DIR="/home/student/software_deployment/lab1"
APP_DIR="$ROOT_DIR/mywebapp"
VARIANT=27

echo ">>> Етап 4. Налаштування конфігурації та прав"

sudo mkdir -p /etc/mywebapp
cat <<EOF | sudo tee /etc/mywebapp/config.json
{
  "server": { "host": "127.0.0.1", "port": 3000 },
  "db": {
    "user": "app",
    "host": "127.0.0.1",
    "database": "mywebapp_db",
    "password": "password",
    "port": 5432
  }
}
EOF

sudo chown -R root:app /etc/mywebapp
sudo chmod 640 /etc/mywebapp/config.json

sudo chmod +x /home/student
sudo chmod +x /home/student/software_deployment
sudo chmod +x /home/student/software_deployment/lab1

cd "$APP_DIR"
npm install --production

sudo chown -R app:app "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

echo "$VARIANT" > /home/student/gradebook
sudo chown student:student /home/student/gradebook

echo ">>> Налаштування Systemd Socket Activation"

cat <<EOF | sudo tee /etc/systemd/system/mywebapp.socket
[Unit]
Description=Socket for MyWebApp

[Socket]
ListenStream=3000
BindIPv6Only=both

[Install]
WantedBy=sockets.target
EOF

cat <<EOF | sudo tee /etc/systemd/system/mywebapp.service
[Unit]
Description=My Web App Service
After=network.target postgresql.service
Requires=mywebapp.socket

[Service]
User=app
Group=app
WorkingDirectory=$APP_DIR
Environment=NODE_ENV=production

ExecStartPre=/usr/bin/node src/db/migrate.js
ExecStart=/usr/bin/node src/app.js
Restart=always
EOF

sudo systemctl daemon-reload

sudo systemctl disable mywebapp.service || true

sudo systemctl enable mywebapp.socket
sudo systemctl start mywebapp.socket

echo ">>> Сервіс та сокет успішно налаштовано та запущено!"
