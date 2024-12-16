#!/bin/sh
#
# Script para iniciar o servico do DSNScript-proxy
# Desenvolvedor: Cesar A. Camargo
#
# Versão: 1.0.0
# 09-12-2024 - Inicio
# Versão: 1.0.1 
# 11-12-2024 - Alterando as mensagem dos processos; consolidando as opçoes do menu; melhorando as estruturas dos codigos; 
# reformatando o layout do menu; adicionado uma condição para validar se o serviço esta em execução.
# Versão: 1.0.1b
# 15-12-2024 - Refazendo o comando -ps- com -grep- para serem mais diretos no resultado.
# Versão: 1.0.2
# 16-12-2024 - Removido a função 'restart()' pois não era necessario nesse contexto e o MENU de opções foi remodelado.
#

## COLORS
NC='\e[0m'
BOLD="\e[1m"
BLUE="\e[36m"
RED='\e[31m'
YELLOW="\e[33m"
GREEN='\e[32m'

## VARIAVEIS
U_SER=$(id -u)
DNSPRXPID="/opt/dnscrypt-proxy/dnscrypt-proxy.pid"
FILE_CONF="/opt/dnscrypt-proxy/dnscrypt-proxy.toml"
FILE_RESOLV="/etc/resolv.conf"
FILE_RESOLVBKP="/etc/resolv.conf.bkp"

## Verificando se o usuario é root
echo -e "${YELLOW}\nVerificando se tem permissão de -root- para executar este script.${NC}"
echo -ne "${YELLOW}\nAguarde... "
sleep 2 && tput clear;

if [ "$U_SER" -ne 0 ]; then

    echo -e "${RED}\nErro! SEM PERMISSAO ! Precisa ser -root- para executar esta tarefa.${NC}\n" 

else

	echo -e "${GREEN}[ Ok ]" && sleep 1

## MODULOS
	start() {
		
		cp $FILE_RESOLV $FILE_RESOLVBKP

		echo "nameserver 127.0.0.1" > $FILE_RESOLV

		sleep 3
		
		echo -e "${GREEN}\n\nIniciando serviço DNScript-proxy !!!"

		echo -ne "\nAguarde..."; 
		
		/opt/dnscrypt-proxy/dnscrypt-proxy -config $FILE_CONF &
		
		pgrep dnscrypt-proxy > $DNSPRXPID

		sleep 5; echo -e "\t Ok${NC}\n"
		
		sleep 2; ps ef | grep dnscrypt-'[proxy]'
		
		echo -e "\n" && sleep 4
		
		## Comando ss
		ss -lp 'sport = :domain'
	}

	stop(){
		
	## Verifica se o serviço esta em execução
		
		[ ! -f "$DNSPRXPID" ] && { echo -e "\n\n${RED}ERRO: O DNScrypt-proxy não esta em execução !!! ${NC}\n"; exit; }

		echo -ne "${BOLD}\n\nParando o serviço DNScrypt-proxy..."

		kill -15 $(< $DNSPRXPID) && echo -e "${GREEN}\tOk ${NC}\n"
		
		rm -f $DNSPRXPID
		
		echo -e "\n" && sleep 4
		
		## Comando ss
		ss -lp 'sport = :domain'
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
echo -e "${BLUE}
===================[ MENU ]====================
 1 -> Iniciar serviço
 2 -> Reiniciar
 3 -> Parar o serviço e restaurar a configuração s/ DNScrypt-proxy
 4 ->> Sair
===============================================${NC}\n"
	read -r -p "Selecione uma das opções acima: " OPCS

	case $OPCS in

		1) start ;;
		2) stop ; restaura ; start ;;
		3) stop ; restaura ;;
		4) echo -e "\n" & exit ;;
		*) echo -e "\nUsar uma das opcoes: { 1|2|3|4 }\n" 

	esac
fi
