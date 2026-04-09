#!/bin/bash
#
## Verificando se o usuario é root

U_SER=$(id -u)

if [ "$U_SER" -ne 0 ]; then

   echo -e "\033[1;31m\nErro! Voce tem que ser root para executar esta tarefa.\033[m\n" 

else

    tput clear;

    echo -e "\033[1m\nAtualizando repositorio... aguarde!!!\033[m\n"


    if ! zypper lu | grep -Eq "^v{1}" 
    then

        echo -e "\033[1;33m\nNão tem pacotes para serem atualizados!\033[m\n"

    else

        echo -e "\n";

        sudo zypper ref; echo -e "\n";

        sudo zypper dup

        exit

    fi

fi
