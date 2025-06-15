#!/bin/bash
#
## Spoofing de MAC (Necessario ter "macchanger" instalado)
## 00:03:93:cf:68:9a - Maçã
## 5C:F3:FC:90:8d:d0 - IBM
## 00:03:FF:f7:83:af - Microsoft Corporation
## F8:D0:BD:90:8d:90 - Samsung
## 00:0A:28:30:03:d2 - Motorola
## 68:DF:DD:96:28:d8 - Xiaomi inc.
## 00:19:C5:1e:b7:a4 - SONY Computer

clear;

## Interfaces
INTF1='p4p2'
INTF2='wlan'
DEVICE=$(nmcli connection show --active | grep -E "${INTF1} | ${INTF2}?" | awk '{print $4}')

echo -e "\nParando a rede..."
sudo nmcli networking off
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager;

echo -e "\nAguarde..."
sleep 7; echo -e "\n"

### Exemplos de endereços para na técnica de MAC Spoofing
#sudo macchanger -m 00:03:93:cf:68:9a $DEVICE
#sudo macchanger -m 5C:F3:FC:90:8d:d0 $DEVICE
#sudo macchanger -m 00:03:FF:f7:83:af $DEVICE
#sudo macchanger -m F8:D0:BD:90:8d:90 $DEVICE
#sudo macchanger -m 00:0A:28:30:03:d2 $DEVICE
#sudo macchanger -m 68:DF:DD:96:28:d8 $DEVICE
#sudo macchanger -m 00:19:C5:1e:b7:a4 $DEVICE

#sudo macchanger -r $DEVICE
#sudo macchanger -A $DEVICE
#sudo macchanger -s $DEVICE
sudo macchanger -p $DEVICE ## Restaura para o MAC padrão.

echo -e "\nSubindo a rede..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo nmcli networking on

echo -e "\nRede restabelecida!\n"

ip link show $DEVICE

