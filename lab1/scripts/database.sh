#!/bin/bash
set -e

echo ">>> Етап 3. Налаштування PostgreSQL"

sudo -u postgres psql -c "CREATE USER app WITH PASSWORD 'password';" || echo "User exists"
sudo -u postgres psql -c "CREATE DATABASE mywebapp_db OWNER app;" || echo "DB exists"

echo "База даних is ready."
