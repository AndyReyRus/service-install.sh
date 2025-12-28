#!/bin/bash

VM_NAME="as-srv5"
ISO_PATH="/mnt/8ca306ed-ee77-4f78-9d80-fb62c9b5ab7f/Soft/Operatin System/Astra/astra-1.8.3.8-21.08.25_15.43-di.iso"
VM_PATH="$HOME/VBox/Server/$VM_NAME"
OS_TYPE="Debian_64"


# Проверка существования ISO (добавьте для надежности)
if [ ! -f "$ISO_PATH" ]; then
    echo "Ошибка: ISO файл не найден!"
    echo "Путь: $ISO_PATH"
    exit 1
fi

# Создаем папку если не существует
mkdir -p "$VM_PATH"


# Создание ВМ
VBoxManage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register --basefolder "$HOME/VBox/Server"

# Основные настройки
VBoxManage modifyvm "$VM_NAME" \
  --cpus 4 \
  --memory 4096 \
  --vram 128 \
  --pae on \
  --hwvirtex on \
  --graphicscontroller vmsvga \
  --nic1 nat \
  --boot1 dvd \
  --boot2 disk \
  --boot3 none \
  --boot4 none \
  --audio-driver pulse \
  --audio-enabled on \
  --audio-controller ac97 \
  --usb on \
  --usb-ehci on \
  --usb-xhci off \
  --clipboard-mode bidirectional \
  --drag-and-drop bidirectional \
  --mouse usbtablet \
  --keyboard usb

# Дополнительные настройки для лучшей интеграции
VBoxManage modifyvm "$VM_NAME" \
  --accelerate3d on \
  --monitor-count 1 \
  --bioslogofadein off \
  --bioslogofadeout off

# Создание диска
VBoxManage createmedium disk --filename "$VM_PATH/${VM_NAME}.vdi" --size 51200

# Настройка хранилища
VBoxManage storagectl "$VM_NAME" \
  --name "SATA Controller" \
  --add sata \
  --controller IntelAhci \
  --portcount 2

# Жесткий диск на порт 0
VBoxManage storageattach "$VM_NAME" \
  --storagectl "SATA Controller" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "$VM_PATH/${VM_NAME}.vdi"

# Подключение диска как SATA
VBoxManage storageattach "$VM_NAME" \
  --storagectl "SATA Controller" \
  --port 1 \
  --device 0 \
  --type dvddrive \
  --medium "$ISO_PATH"

echo "ВМ '$VM_NAME' создана успешно!"
