#!/bin/sh
#
# Script para iniciar o servico do DSNScript-proxy
# Versão: 1
# Desenvolvedor: Cesar A. Camargo
# 09/12/2024 - Inicio

## COLORS
NC='\e[0m'
BOLD="\e[1m"
BLUE="\e[36m"
RED='\e[31m'
YELLOW="\e[33m"
GREEN='\e[32m'


echo -e "${YELLOW}\nAtenção! É necessário ser -root- para executar este script.${NC}"

sleep 3 && tput clear;

DNSPRXPID="/opt/dnscrypt-proxy/dnscrypt-proxy.pid"

## Verificando se o usuario é root
U_SER=$(id -u)

if [ "$U_SER" -ne 0 ]; then

    echo -e "${RED}\nErro! Voce tem que ser root para executar esta tarefa.${NC}\n" 

else

	FILE_CONF="/opt/dnscrypt-proxy/dnscrypt-proxy.toml"
	FILE_RESOLV="/etc/resolv.conf"
	FILE_RESOLVBKP="/etc/resolv.conf.bkp"


## MODULOS
	start() {
		
		cp $FILE_RESOLV $FILE_RESOLVBKP

		echo "nameserver 127.0.0.1" > $FILE_RESOLV

		sleep 3
		
		echo -e "${GREEN}\nIniciando serviço DNScript-proxy !!!"

		echo -ne "\nAguarde..."; 
		
		/opt/dnscrypt-proxy/dnscrypt-proxy -config $FILE_CONF &
		
		pgrep dnscrypt-proxy > $DNSPRXPID

		sleep 7; echo -e "\t Ok${NC}\n"
		
		sleep 2; ps aux | grep dnscrypt-proxy | grep -E '^root'
	}

	stop(){
		
		echo -ne "${BOLD}\n\nParando o serviço DNScrypt-proxy..."

		kill -15 $(< $DNSPRXPID)
		
		echo -e "${GREEN}\tOk ${NC}\n"
		
		#rm -f $DNSPRXPID
	}

	restart(){
	
		stop;
			
		echo -e "${GREEN}Iniciando o serviço DNScript-proxy !!!\n"
		
		echo -ne "\nAguarde... " 
		
		/opt/dnscrypt-proxy/dnscrypt-proxy -config $FILE_CONF &

		pgrep dnscrypt-proxy > $DNSPRXPID
		
		sleep 7; echo -e "\t[Ok] ${NC}\n" 

		ps aux | grep dnscrypt-proxy | grep -E '^root'
	}

	restaura(){

		rm -f $FILE_RESOLV

		mv $FILE_RESOLVBKP $FILE_RESOLV

		echo -e "\n${BOLD}Parando a rede...${NC}"
		nmcli networking off
		systemctl stop NetworkManager
		systemctl disable NetworkManager;

		sleep 3;

		echo -e "${YELLOW}\nSubindo a rede...${NC}"
		systemctl enable NetworkManager
		systemctl start NetworkManager
		nmcli networking on

		echo -e "${GREEN}\nRede restabelecida!${NC}\n"
	}

## MENU
	echo -e "\n${BLUE}[ MENU ]\n"
	echo -e " 1 -> Iniciar serviço"
	echo -e " 2 -> Parar serviço"
	echo -e " 3 -> Reiniciar"
	echo -e " 4 -> Restaurar configuração s/ DNScrypt-proxy"
	echo -e " 5 ->> Sair"
	echo -e "==============================================${NC}\n"
	
	read -r -n1 -p "Selecione uma das opções acima: " OPCS

	case $OPCS in

		1) start ;;
		2) stop ;;
		3) restart ;;
		4) restaura ;;
		5) echo -e "\n" & exit ;;
		*) echo -e "\nUsar uma das opcoes: { 1|2|3|4|5 }\n" 

	esac
fi
