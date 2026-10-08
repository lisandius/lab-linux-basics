#!/bin/bash
# Создание пользователя: домашний каталог, доступ по SSH-ключу, sudo без пароля
# Использование: sudo ./create_user.sh <имя> "<публичный ключ>"
set -e
USER_NAME="${1:?имя пользователя}"
PUBKEY="${2:?публичный ключ}"

id "$USER_NAME" >/dev/null 2>&1 || useradd -m -s /bin/bash "$USER_NAME"      # 1. домашний каталог
usermod -aG sudo "$USER_NAME"

install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "/home/$USER_NAME/.ssh"    # 2. вход по ключу
echo "$PUBKEY" > "/home/$USER_NAME/.ssh/authorized_keys"
chown "$USER_NAME:$USER_NAME" "/home/$USER_NAME/.ssh/authorized_keys"
chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"

echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USER_NAME"      # 3. sudo без пароля
chmod 440 "/etc/sudoers.d/$USER_NAME"
visudo -cf "/etc/sudoers.d/$USER_NAME"
echo "Пользователь $USER_NAME создан"
