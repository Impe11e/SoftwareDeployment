#!/bin/bash
set -e

ROOT_DIR="/home/student/software_deployment/lab1"
APP_DIR="$ROOT_DIR/mywebapp"
VARIANT=27

echo ">>> Етап 4. Налаштування сервісу та прав"

echo "$VARIANT" > /home/student/gradebook
chown student:student /home/student/gradebook

cd "$ROOT_DIR"
npm install --production

chown -R student:mywebapp "$ROOT_DIR"
chmod -R 750 "$ROOT_DIR"

cat <<EOF > /etc/systemd/system/mywebapp.service
[Unit]
Description=My Web App Service
After=network.target postgresql.service

[Service]
User=mywebapp
Group=mywebapp
WorkingDirectory=/home/student/software_deployment/lab1
Environment=NODE_ENV=production

ExecStartPre=/usr/bin/node mywebapp/src/db/migrate.js

ExecStart=/usr/bin/node mywebapp/src/app.js

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mywebapp.service
systemctl restart mywebapp.service

echo ">>> Сервіс запущено."
