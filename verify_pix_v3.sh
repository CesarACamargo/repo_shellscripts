#!/bin/bash
#
# Script para verificar se os jobs do PIX estão em execução
# Versão 2
# Data: 18/08/2021 - Inicio.
# Data: 20/08/2021 - Adicionado linha que mostra a quantidade de job(s) reiniciados;
# Versão 2b
# Data: 01/09/2021 - Adicionado o job PAYMENT_PARTNER para ser processado, pois estava faltando.  
# Versão 2c
# Data: 20/09/2021 - Adicionado o comando para matar a job PAYMENT_PARNTER via ID, pois o mesmo não deixa subir a execução do
# job PAYMENT depois que ele cai.
# Versão 3
# Data: 25/12/2021 - Realizado restruturação do codigo utilizando funções 
# Data: 06/08/2022 - Adicionado o novo job EXTRATO-CAN-ORACLE 
# Data: 07/10/2022 - Adicionado o comando 'jobs' para ver os jobs que subiram.

tput clear

## VARIAVEIS

echo -e "

Verificando se os seguintes jobs do PIX estao em execução:\e[33m

 PAYMENT 
 MONEYBACK 
 SETTLEMENT
 SETTLEMENT_PAYMENT
 PAYMENT_PARTNER
 PIX-ORACLE
 CAN-ORACLE
\e[0m \n"

## FUNÇÕES

job_moneyback()
{
   if yarn application -list -appStates RUNNING | grep -Eq pix-MONEYBACK
   then
      echo -e "\n\e[1;32m --> MONEYBACK... [OK] \e[0m \n"
   else
      echo -e "\n\e[5;31m MONEYBACK NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
      nohup sh SC_PIX_EXEC_PIX.sh MONEYBACK >/dev/null 2>&1 &
      echo -e "\n\e[1;32m \__> Pronto! MONEYBACK... [OK] \e[0m \n"
   fi
}

job_payment()
{
  if yarn application -list -appStates RUNNING | grep -Eq pix-PAYMENT[^_]
  then
     echo -e "\n\e[1;32m --> PAYMENT... [OK] \e[0m \n"
  else
  
     yarn application -list -appStates RUNNING | grep -E pix-PAYMENT_PARTNER > arq_pix
     
     ID=$(cat arq_pix | awk '{print $1}')
  
     echo -e "\n\e[33m Parando agora o job $ID...\e[0m\n"
  
     yarn application -kill $ID 2>&1 > /dev/null
  
     echo -e "\n\e[5;31m PAYMENT NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
     nohup sh SC_PIX_EXEC_PIX.sh PAYMENT > /dev/null 2>&1 &
     echo -e "\n \e[1;32m \__> Pronto! PAYMENT... [OK] \e[0m \n"
  
     rm -f arq_pix 2>&1> /dev/null
  fi
}

job_payment_partner()
{
  if yarn application -list -appStates RUNNING | grep -Eq pix-PAYMENT_PARTNER
  then
     echo -e "\n\e[1;32m --> PAYMENT_PARTNER... [OK] \e[0m \n"
  else
     echo -e "\n\e[5;31m PAYMENT_PARTNER NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
     nohup sh SC_PIX_EXEC_PIX.sh PAYMENT_PARTNER > /dev/null 2>&1 &
     echo -e "\n \e[1;32m \__> Pronto! PAYMENT_PARTNER... [OK] \e[0m \n"
  fi
  
}

job_settlement()
{
  if yarn application -list -appStates RUNNING | grep -Eq pix-SETTLEMENT[^_]
  then
     echo -e "\n\e[1;32m --> SETTLEMENT... [OK] \e[0m \n"
  else

     yarn application -list -appStates RUNNING | grep -E pix-SETTLEMENT_PAYMENT > arq_pix

     ID=$(cat arq_pix | awk '{print $1}')
                               
     echo -e "\n\e[33m Parando agora o job $ID...\e[0m\n"
                                     
     yarn application -kill $ID 2>&1 > /dev/null
                                          
     echo -e "\n\e[5;31m SETTLEMENT NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
     nohup sh SC_PIX_EXEC_PIX.sh SETTLEMENT > /dev/null 2>&1 &
     echo -e "\n \e[1;32m \__> Pronto! SETTLEMENT... [OK] \e[0m \n"
                                                             
     rm -f arq_pix 2>&1> /dev/null
  fi
}

job_settlement_payment()
{
  if yarn application -list -appStates RUNNING | grep -Eq pix-SETTLEMENT_PAYMENT
  then
      echo -e "\n\e[1;32m --> SETTLEMENT_PAYMENT... [OK] \e[0m \n"
  else
      echo -e "\n\e[5;31m SETTLEMENT_PAYMENT NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
      nohup sh SC_PIX_EXEC_PIX.sh SETTLEMENT_PAYMENT > /dev/null 2>&1 &
      echo -e "\n \e[1;32m \__> Pronto! SETTLEMENT_PAYMENT... [OK] \e[0m \n"
   fi
}

job_pix_oracle()
{
if yarn application -list -appStates RUNNING | grep -Eq pix-ORACLE
then
   echo -e "\n\e[1;32m --> PIX-ORACLE... [OK] \e[0m \n"
else
   echo -e "\n\e[5;31m PIX-ORACLE NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
   nohup /dados/app/COD/ext-collector-pix/SC_COD_EXEC_PIX.sh ORACLE > /dev/null 2>&1 &
   echo -e "\n \e[1;32m \__> Pronto! PIX-ORACLE... [OK] \e[0m \n"
fi
}

job_can_oracle()
{
if yarn application -list -appStates RUNNING | grep -Eq can-ORACLE
then
   echo -e "\n\e[1;32m --> CAN-ORACLE... [OK] \e[0m \n"
else
   echo -e "\n\e[5;31m CAN-ORACLE NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
   nohup /dados/app/COD/ext-collector-cancellation-lifecycle/SC_COD_EXEC_CAN.sh ORACLE > /dev/null 2>&1 &
   echo -e "\n \e[1;32m \__> Pronto! CAN-ORACLE... [OK] \e[0m \n"
fi
}

P2M=("job_payment" "job_moneyback" "job_settlement" "job_settlement_payment")

## Entrando no diretorio para executar os scripts
cd /dados/scripts/pix/p2m

## Exportando as variaveis de ambiente
export KINIT_FILE=/keytab_svc_cloudera_adm/svc_cloudera_adm.kt
export KINIT_USER=svc_cloudera_adm

for njobs in ${P2M[*]}
do
  ${njobs}
  
done

cd ~

## Entrando no diretorio para executar os scripts
cd /dados/scripts/pix/pib

## Exportando as variaveis de ambiente
export KINIT_FILE=/keytab_svc_cloudera_adm/svc_cloudera_adm.kt
export KINIT_USER=svc_cloudera_adm

job_payment_partner

## Saindo do diretorio pib
cd ~

## Verificar a job ORACLE
job_pix_oracle
job_can_oracle

## Listando quantidade de jobs reiniciados.
QTD=$(jobs | grep -c "Running")

[ $QTD -ne 0 ] && echo -e "\n\e[36mQuantidade de Job(s) reiniciado(s) ateh agora: ${QTD} \e[0m \n"

## Mostrar as jobs em execução
jobs

## FIM
