#!/bin/bash

# Конфигурация SSH для Astra Linux

# Выход при ошибке
set -e  


# Переменные
SSH_USER="user"
SSH_PORT="2222"
SSHD_CONFIG="/etc/ssh/sshd_config"
CLOUD_INIT_CONF="/etc/ssh/sshd_config.d/50-cloud-init.conf"
SSHD_CUSTOM_CONF="/etc/ssh/sshd_config.d/user4custom.conf"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)


# Проверка запуска от root
if [[ $EUID -ne 0 ]]; then
    echo "ОШИБКА: Скрипт должен запускаться от root"
    exit 1
fi

# Проверка существования пользователя
if ! id "$SSH_USER" &>/dev/null; then
    echo "ОШИБКА: Пользователь $SSH_USER не существует"
    exit 1
fi

echo "Начало конфигурации SSH"
echo "Пользователь: $SSH_USER, Порт: $SSH_PORT"
echo ""


# 1. Создание бэкапа основного конфига
echo "1. Создание бэкапа основного sshd_config"
if [[ -f "$SSHD_CONFIG" ]]; then
    BACKUP_FILE="${SSHD_CONFIG}.backup_${BACKUP_TIMESTAMP}"
    cp "$SSHD_CONFIG" "$BACKUP_FILE"
    echo "  Бэкап создан: $BACKUP_FILE"
else
    echo "  Предупреждение: Оригинальный sshd_config не найден"
fi
echo ""


# 2. Редактирование основного конфига - оставляем только ссылку на пользовательский
echo "2. Создание минимального основного конфига"
cat > "$SSHD_CONFIG" << EOF
# Управляется bash скриптом
# Оригинальный конфиг в бэкапе: ${SSHD_CONFIG}.backup_${BACKUP_TIMESTAMP}
Include /etc/ssh/sshd_config.d/*.conf
EOF

chown root:root "$SSHD_CONFIG"
chmod 0644 "$SSHD_CONFIG"
echo "Создан новый минимальный sshd_config"
echo ""


# 3. Создание пользовательского конфига с настройками
echo "3. Создание пользовательского конфига"
mkdir -p "$(dirname "$SSHD_CUSTOM_CONF")"

cat > "$SSHD_CUSTOM_CONF" << EOF
# Управляется bash скриптом
Port $SSH_PORT
PermitRootLogin no
AllowUsers $SSH_USER
# Аутентификация
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ClientAliveInterval 300
ClientAliveCountMax 3
# Усиление безопасности
# Protocol 2
# HostbasedAuthentication no
# IgnoreRhosts yes
# X11Forwarding no
# PrintMotd no
# PrintLastLog yes
# TCPKeepAlive yes
# MaxAuthTries 3
# MaxSessions 5
# LoginGraceTime 60
EOF

chown root:root "$SSHD_CUSTOM_CONF"
chmod 0644 "$SSHD_CUSTOM_CONF"
echo "  Создан пользовательский конфиг: $SSHD_CUSTOM_CONF"
echo ""


# 4. Обработка cloud-init конфига (если существует)
echo "4. Проверка cloud-init конфига"
if [[ -f "$CLOUD_INIT_CONF" ]]; then
    cat > "$CLOUD_INIT_CONF" << EOF
# Управляется bash скриптом
PasswordAuthentication no
EOF
    chown root:root "$CLOUD_INIT_CONF"
    chmod 0644 "$CLOUD_INIT_CONF"
    echo "  Обновлен cloud-init конфиг"
else
    echo "  Cloud-init конфиг не найден, пропускаем"
fi
echo ""


# 5. Управление ssh.socket
echo "5. Настройка службы SSH"
# Останавливаем и отключаем ssh.socket если активен
if systemctl is-active --quiet ssh.socket 2>/dev/null; then
    systemctl stop ssh.socket
    systemctl disable ssh.socket
    echo "  Остановлен и отключен ssh.socket"
fi

# 6. Перезапускаем SSH
systemctl daemon-reload
systemctl restart ssh
systemctl enable ssh
echo "  SSH служба перезапущена"
echo ""


# 7. Проверка конфигурации
echo "6. Проверка конфигурации"
if ss -tulpn | grep -q ":$SSH_PORT"; then
    echo "  ✓ SSH слушает порт $SSH_PORT"
else
    echo "  ✗ SSH НЕ слушает порт $SSH_PORT"
    exit 1
fi

if systemctl is-active --quiet ssh; then
    echo "  ✓ SSH служба работает"
else
    echo "  ✗ SSH служба НЕ работает"
    systemctl status ssh --no-pager
    exit 1
fi
echo ""

# 8. Рекомендации по тестированию подключения
echo "Конфигурация завершена успешно!"
echo ""
echo "ВАЖНО:"
echo ""
echo "=============== Не закрывай сессию пока не проверишь новое подключение на новом порту! ==============="
