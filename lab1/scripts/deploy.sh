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
    "user": "mywebapp",
    "host": "127.0.0.1",
    "database": "mywebapp_db",
    "password": "password",
    "port": 5432
  }
}
EOF

sudo chown -R root:mywebapp /etc/mywebapp
sudo chmod 640 /etc/mywebapp/config.json

sudo chmod +x /home/student
sudo chmod +x /home/student/software_deployment
sudo chmod +x /home/student/software_deployment/lab1

cd "$APP_DIR"
npm install --production

sudo chown -R mywebapp:mywebapp "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

echo "$VARIANT" > /home/student/gradebook
sudo chown student:student /home/student/gradebook

cat <<EOF | sudo tee /etc/systemd/system/mywebapp.service
[Unit]
Description=My Web App Service
After=network.target postgresql.service

[Service]
User=mywebapp
Group=mywebapp
WorkingDirectory=$APP_DIR
Environment=NODE_ENV=production

ExecStartPre=/usr/bin/node src/db/migrate.js
ExecStart=/usr/bin/node src/app.js

Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mywebapp.service
sudo systemctl restart mywebapp.service

echo ">>> Сервіс успішно налаштовано та запущено!"
