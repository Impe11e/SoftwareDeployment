#!/bin/bash
set -e

echo ">>> Етап 5. Налаштування Nginx"

CONF_PATH="/etc/nginx/sites-available/mywebapp"
LINK_PATH="/etc/nginx/sites-enabled/mywebapp"

cat <<EOF > $CONF_PATH
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/mywebapp_access.log;
    error_log /var/log/nginx/mywebapp_error.log;

    location /health/ {
        allow 127.0.0.1;
        deny all;      
        proxy_pass http://127.0.0.1:3000;
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf $CONF_PATH $LINK_PATH

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
    echo "Дефолтний конфіг Nginx видалено."
fi

echo "Перевірка конфігурації Nginx..."
nginx -t

echo "Перезапуск Nginx..."
systemctl restart nginx

echo ">>> Nginx успішно налаштовано."
