#!/bin/bash
#
# Script para realizar limpeza na lixeira.
# Criada em 18/11/2022.
# Inserido o codigo para validação da keytab - 21/11/2022. 
#
# Versão: 1

## FUNÇOES

function VALIDA_KEY
{

## COLORS
BLUE='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;93m'
GREEN='\033[0;32m'
NC='\033[0m'

##------------------------------------------------------------------------------------------
tput clear

echo -e "\n${YELLOW}INFO - VALIDA_KERBEROS ${NC}"
retCode=1
ct=0

while [ $retCode -ne 0 ]
do

	echo -e "\nInicio execucao do comando kinit" & sleep 3

	find /run/cloudera-scm-agent/process | egrep "hdfs.keytab" | head -1 | xargs -i kinit -kt {} hdfs/`hostname -f`@DOMHIAE.EINSTEIN.BR
	sleep 10

	echo -e "\nExecucao do comando klist - lista credenciais" & sleep 2
	data_ano=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c28-31`
	data_mes=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c22-23`
	data_dia=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c25-26`
	data_hora=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c33-34`
	data_minuto=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c36-37`
	data_segundo=`klist | grep krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR | cut -c39-40`
	data_expiracao=$data_ano$data_mes$data_dia$data_hora$data_minuto$data_segundo


	echo -e "\nData em que a credencial sera expirada (a data so sera preenchida caso o kinit tenha executado com sucesso): $data_expiracao" & sleep 2
	data_atual=`date +%Y%m%d%H%M%S`
	echo -e "\nData atual de tentativa de execucao do kinit (autenticacao): $data_atual" & sleep 2
	
	if [ $data_atual -lt $data_expiracao ] && [ `klist | grep 'krbtgt/DOMHIAE.EINSTEIN.BR@DOMHIAE.EINSTEIN.BR' | wc -l` -eq 1 ] && [ `klist | grep 'lpfbigdap06.einstein.br' | wc -l` -eq 1 ]
	
	then
	 echo -e "\nFoi feita a execucao do klist e foi verificado que existe uma chave ativa\n" & sleep 2
	
	 retCode=0
	
	else
	 echo -e "\nFoi feita a execucao do klist e foi verificado que nÃƒÂ£o existe uma chave ativa\n" & sleep 2
	
	 retCode=1
	
	fi
	
	if [ $retCode -eq 0 ]
	 then
	  echo -e "\n${GREEN}INFO - KERBEROS VALIDADO COM SUCESSO ${NC}" & sleep 2
	else
	 sleep 120
	
	 ct=$(($ct+1))
	
	 echo -e "\n${RED}ERRO - ERRO NA VALIDACAO DO KERBEROS, TENTATIVA DE REEXECUCAO DO COMANDO KINIT ${NC}" & sleep 2
	 echo -e "\nReturnCode: ${retCode}"
	
	  if [ $ct -eq 4 ]
	   then
	
	    exit $retCode
	
	  fi
	
	fi
	
done
}

function CLEAR_TRASH
{
## COLOR
BLUE='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;93m'
GREEN='\033[0;32m'
NC='\033[0m'

## INCIO DO CODIGO DE LIMPEZA

QTDLX1=$(hdfs dfs -du -h /user/hive/.Trash | grep -v Current | wc -l)
QTDLX2=$(hdfs dfs -du -h /user/_usr_bigdataprd/.Trash | grep -v Current | wc -l)
QTDALL=$(expr $QTDLX1 + $QTDLX2)

tput clear

echo -e "\n${BLUE}Iniciando varredura...${NC}\n"

[ $QTDLX1 -gt 0 ] && { hdfs dfs -du -h /user/hive/.Trash | grep -v Current; } 
echo -e '\n'
[ $QTDLX2 -gt 0 ] && { hdfs dfs -du -h /user/_usr_bigdataprd/.Trash | grep -v Current; } 

echo -e "\n${YELLOW}${QTDLX1} lixo(s) encontrado(s) em /user/hive/.Trash${NC}" 
echo -e "\n${YELLOW}${QTDLX2} lixo(s) encontrado(s) em /user/_usr_bigdataprd/.Trash${NC}\n" 
echo -e "\n"

read -p "Deseja limpar a lixeira (S/N)? " -e -n1 resp

if [[ $resp == +(S|s) ]]; then
     echo -e "\n"
#     hdfs dfs -du -h /user/hive/.Trash 
     hdfs dfs -rm -R -skipTrash /user/hive/.Trash/23*
     echo -e "\n"
#     hdfs dfs -du -h /user/_usr_bigdataprd/.Trash 
     hdfs dfs -rm -R -skipTrash /user/_usr_bigdataprd/.Trash/23*
     echo -e "\n${GREEN}Ok, total de ${QTDALL} lixo(s) removido(s) com exito!${NC}\n"

elif [[ $resp == +(N|n) ]]; then
     
     echo -e "\nOk, saindo...\n"
     exit

else [[ $resp != +(S|s|N|n) ]]

     echo -e "\n${RED}Opcao Invalida! Favor digitar S ou N.${NC}\n"
     exit 

fi || { echo -e "\nLixeira vazia por enquanto!"; }
}

## COLOR
RED='\033[0;31m'
YELLOW='\033[1;93m'
NC='\033[0m'

tput clear

echo -e "\n${YELLOW}Menu:${NC} \n"

read -p "Digite [1] para limpar a lixeira ou [2] para validar Kerberos ou [3] para sair: " -e -n1 opc

    case "$opc" in
	1) CLEAR_TRASH ;;
	2) VALIDA_KEY ;;
	3) echo -e "\nOk, saindo...\n"; exit ;;
	*) echo -e "\n${RED}Opcao Invalida!!!\n${NC}"; exit ;;
    esac


