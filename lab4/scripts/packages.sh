#!/bin/bash
set -e

echo ">>> Етап 1. Встановлення системних пакетів"

apt-get update

apt-get install -y curl gnupg build-essential

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    nginx \
    postgresql \
    postgresql-contrib \
    nodejs \
    curl \
    git

echo "Усі пакети встановлено."
node -v

echo ">>> Статус сервісів:"
systemctl is-active --quiet nginx && echo "Nginx: OK" || echo "Nginx: ERROR"
systemctl is-active --quiet postgresql && echo "PostgreSQL: OK" || echo "PostgreSQL: ERROR"
