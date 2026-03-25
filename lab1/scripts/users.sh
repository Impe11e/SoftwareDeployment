#!/bin/bash
set -e

echo ">>> Етап 2. Створення користувачів та налаштування прав"

if ! id "student" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo student
    echo "student:studentpass" | chpasswd
    echo "Користувач student створений."
else
    usermod -aG sudo student
    echo "Права sudo для student підтверджено."
fi

if ! id "teacher" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo teacher
    echo "teacher:12345678" | chpasswd
    chage -d 0 teacher
    echo "Користувач teacher створений."
fi

if ! id "operator" &>/dev/null; then
    if getent group operator &>/dev/null; then
        useradd -m -s /bin/bash -g operator operator
    else
        useradd -m -s /bin/bash operator
    fi
fi
echo "operator:12345678" | chpasswd
chage -d 0 operator

if ! id "app" &>/dev/null; then
    useradd -r -s /usr/sbin/nologin app
    echo "Системний користувач app створений."
fi

echo ">>> Налаштування обмеженого sudo для operator:"

SCTL="/usr/bin/systemctl"
NGINX="/usr/sbin/nginx"

cat <<EOF | sudo tee /etc/sudoers.d/operator
operator ALL=(ALL) NOPASSWD: /usr/bin/systemctl start mywebapp, /usr/bin/systemctl stop mywebapp, /usr/bin/systemctl restart mywebapp, /usr/bin/systemctl status mywebapp, /usr/bin/systemctl reload nginx
EOF

sudo chmod 0440 /etc/sudoers.d/operator
echo "Права sudoers для operator налаштовані."
