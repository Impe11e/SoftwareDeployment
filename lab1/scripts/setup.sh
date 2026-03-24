#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then 
  echo "Будь ласка, запустіть скрипт через sudo: sudo ./setup.sh"
  exit 1
fi

echo "=========================================="
echo "   ЗАПУСК АВТОМАТИЗАЦІЇ РОЗГОРТАННЯ   "
echo "=========================================="

chmod +x *.sh

./packages.sh
./users.sh
./database.sh
./deploy.sh
./nginx.sh

echo "=========================================="
echo "   УСПІШНО ЗАВЕРШЕНО!   "
echo "=========================================="
echo "Сайт доступний за адресою: http://localhost (або IP віртуалки)"
echo "Gradebook створено: /home/student/gradebook"
