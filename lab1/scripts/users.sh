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
    useradd -m -s /bin/bash operator
    echo "operator:12345678" | chpasswd
    chage -d 0 operator
    echo "Користувач operator створений."
fi

if ! id "mywebapp" &>/dev/null; then
    useradd -r -s /usr/sbin/nologin mywebapp
    echo "Системний користувач mywebapp створений."
fi

echo ">>> Налаштування обмеженого sudo для operator:"

SCTL="/usr/bin/systemctl"
NGINX="/usr/sbin/nginx"

cat <<EOF > /etc/sudoers.d/operator-rules
operator ALL=(ALL) NOPASSWD: $SCTL start mywebapp.service, \\
                             $SCTL stop mywebapp.service, \\
                             $SCTL restart mywebapp.service, \\
                             $SCTL status mywebapp.service, \\
                             $SCTL reload nginx, \\
                             $NGINX -s reload, \\
                             $NGINX -t
EOF

chmod 0440 /etc/sudoers.d/operator-rules
echo "Права sudoers для operator налаштовані."
