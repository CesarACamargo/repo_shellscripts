#!/bin/bash
#
# Script para verificar se os jobs Streaming estão em execução
# Versão 1
# Data: 17/12/2021 - Inicio.

tput clear

echo -e "

Verificando se os seguintes jobs estao em execução:\e[33m

PythonStreamingCOP
PythonStreamingSkyline
PythonStreamingWorthixError
PythonStreamingStratus
PythonStreamingBIT47
PythonStreamingONBOARDING_KPI
Streaming-extrato-pgo-adjustment-NORMAL
\e[0m \n"


## Funçoes

strm_cop()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingCOP 
  then

    echo -e "\n\e[1;32m --> PythonStreamingCOP... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingCOP NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    nohup /dados/Hyaku/cop/Consumer_cop.sh > /dev/null &>- & 
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


strm_skyline()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingSkyline 
  then

    echo -e "\n\e[1;32m --> PythonStreamingSkyline... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingSkyline NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    sudo su - pdoming -c ' nohup /dados/scripts/program/run/Consumer_Skyline.sh > /dev/null &>- & '
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


strm_err()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingWorthixError 
  then

    echo -e "\n\e[1;32m --> PythonStreamingWorthixError... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingWorthixError NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    sudo su - svc_cloudera_adm -c ' nohup /dados/scripts/worthix/consumer_error/consumer_worthix_error.sh > /dev/null &>- & '
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


#strm_liqd()
#{
#  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingP2P_liqd
#  then
#
#    echo -e "\n\e[1;32m --> PythonStreamingP2P_liqd... [OK] \e[0m \n"
#
#  else
#
#    echo -e "\n\e[5;31m PythonStreamingP2P_liqd NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
##    sudo su - svc_cloudera_adm -c ' nohup /dados/Hyaku/pto/Consumer_P2P_liqd.sh > /tmp/Consumer_P2P_liqd_" + v_data_stage + ".log 2>&1 & ' 
#     nohup /dados/Hyaku/pto/Consumer_P2P_liqd.sh > /tmp/Consumer_P2P_liqd_" + v_data_stage + ".log >&- & 
#    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
#  fi
#}


#strm_auth()
#{
#  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingP2P_auth
#  then
#
#    echo -e "\n\e[1;32m --> PythonStreamingP2P_auth... [OK] \e[0m \n"
#
#  else
#
#    echo -e "\n\e[5;31m PythonStreamingP2P_auth NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
#    sudo su - svc_cloudera_adm -c ' nohup /dados/Hyaku/pto/Consumer_P2P_auth.sh > /tmp/Consumer_P2P_auth_" + v_data_stage + ".log 2>&1 & '
#    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
#  fi
#}


strm_stratus()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingStratus
  then

    echo -e "\n\e[1;32m --> PythonStreamingStratus... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingStratus NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    sudo su - pdoming -c ' nohup /dados/scripts/program/run/Consumer_Stratus.sh > /dev/null &>- & '
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


strm_bit47()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingBIT47
  then

    echo -e "\n\e[1;32m --> PythonStreamingBIT47... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingBIT47 NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    #nohup /dados/scripts/bit47/consumer_bit47.sh > /dev/null &>- &
    nohup /dados/scripts/bit47/consumer_bit47.sh &>- &
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


strm_kpi()
{
  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingONBOARDING_KPI 
  then

    echo -e "\n\e[1;32m --> PythonStreamingONBOARDING_KPI... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m PythonStreamingONBOARDING_KPI NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    sudo su - pdoming -c ' nohup /dados/Hyaku/onboarding/Consumer_OnBoarding_KPI.sh > /dev/null &>- & '
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}


strm_normal()
{
  if yarn application -list -appStates RUNNING | grep -Eq streaming-extrato-pgo-adjustment-NORMAL 
  then

    echo -e "\n\e[1;32m --> Streaming-extrato-pgo-adjustment-NORMAL... [OK] \e[0m \n"

  else

    echo -e "\n\e[5;31m Streaming-extrato-pgo-adjustment-NORMAL NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
    nohup /dados/app/COD/ext-collector-pgo-adjustment/SC_COD_EXEC_PGO_ADJUSTMENT.sh > /dev/null &>- & 
    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
  fi
}

#strm_sensidial()
#{
#  if yarn application -list -appStates RUNNING | grep -Eq PythonStreamingSensediaLogs 
#  then
#
#    echo -e "\n\e[1;32m --> PythonStreamingSensediaLogs... [OK] \e[0m \n"
#
#  else
#
#    echo -e "\n\e[5;31m PythonStreamingSensediaLogs NOT RUNNING!! \e[0m \n\n \e[33m Iniciando execução do procedimento...\e[0m"
#    sudo su - svc_cloudera_adm -c ' /home/semantix_dev/DT02/sh_scripts/check_SensediaLogsRawConsumer.sh & '
#    
#    echo -e "\n\e[1;32m \__> Pronto! ... [OK] \e[0m \n"
#  fi
#}

# ARRAY
OBJOBS=(
strm_cop \ 
strm_skyline \ 
strm_err \
strm_stratus \ 
strm_bit47 \
strm_kpi \ 
strm_normal \
) 

## Funcoes abaixo foram comentadas e removidas do ARRAY
# strm_auth | strm_liqd | strm_sensidial


for jbs in ${OBJOBS[@]} 
do
  ${jbs}

done

