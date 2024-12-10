#!/bin/bash
#
# Script para gerar backup de uma dada pasta
# Versão: 7
# Desenvolvedor: Cesar A. Camargo
# 17-09-2021 - Reescrição das linhas de teste de condição que estavam utilizando os "ifs". 
# 20-11-2024 - Reescrição das linhas que contém os comandos de compactação deixando-os mais simplificados.
# 10-12-2024 - Adicionado cores a fim de destacar algumas mensagens.

## Colors
BOLD='\e[1m'
BOLDYELLOW='\e[1;33m'
GREEN='\e[32m' 
NC='\e[0m'

origem=$1

## Verificar se foi fornecido parâmetro
[ $# -lt 1 ] && { echo -e "\nERRO: faltando parâmetro.\n"; exit; }

## Verificar se o diretório de origem existe
[ ! -d "$origem" ] && { echo -e "\nERRO: diretório $origem não existe!\n"; exit; }
 
clear
data=$(date +%d%m%Y)

#################[ Aqui comeca as funções ]##################################

function _ZIP {

    echo -e "\nCompactando $origem ...\n"
    zip -r "Backup_$origem-$data.zip" "$origem"

    echo -e "\n ${GREEN}Backup em ZIP criado com sucesso em $(pwd) ${NC} \n"
    exit
}


function _7z {

    #Pegadinha: o alias (apelido) do programa não é 7zip como esperado e sim 7za.

    #    Para compactar arquivos:
    #    $ 7za a nome-do-arquivo.7z pasta-a-ser-compactada

    #    Para descompactar arquivos:
    #    $ 7za x nome-do-arquivo.7z

    #    Para testar os arquivos:
    #    $ 7za t nome-do-arquivo.7z

    #    Para listar todos os arquivos:
    #    $ 7za l nome-do-arquivo.7z

    echo -e "\nCompactando $origem ...\n"
    7z a "Backup_$origem-$data.7z" "$origem/*"

    echo -e "\n ${GREEN}Backup em 7zip criado com sucesso em $(pwd) ${NC} \n"
    exit
}

function Bz2 {
    echo -e "\nCompactando $origem ...\n"
    tar -cvjf "Backup_$origem-$data.tar.bz2" "$origem"

    echo -e "\n ${GREEN}Backup em Bzip2 criado com sucesso em $(pwd) ${NC} \n"
    exit
}

function Gzip {
    echo -e "\nCompactando $origem ...\n"
    tar -cvzf "Backup_$origem-$data.tar.gz" "$origem"

    echo -e "\n ${GREEN}Backup em Gzip criado com sucesso em $(pwd) ${NC} \n"
    exit
}

function Xz {
    echo -e "\nCompactando $origem ...\n"
    tar -Jcvf "Backup_$origem-$data.tar.xz" "$origem" 

    echo -e "\n ${GREEN}Backup em Xz criado com sucesso em $(pwd) ${NC} \n"
    exit
}

#################[ Linhas de Comandos ]############################## 
echo -e "${BOLD}Script para compactação de pastas - v7"
echo -e "\n1) Bzip2"
echo -e "\n2) Gzip"
echo -e "\n3) Xz"
echo -e "\n4) Zip"
echo -e "\n5) 7zip"
echo -e "\n6) Sair\n"

read -r -n1 -p "Selecione uma das opções acima: " opc

echo -e "${NC}"

case $opc in

	1) echo -e "\n ${BOLDYELLOW}Voce selecionou o compactador Bzip2... ${NC} \n"; sleep 2; Bz2
        ;;
	2) echo -e "\n ${BOLDYELLOW}Voce selecionou o compactador Gzip... ${NC} \n"; sleep 2; Gzip
        ;;
	3) echo -e "\n ${BOLDYELLOW}Voce selecionou o compactador Xz... ${NC} \n"; sleep 2; Xz
        ;;    
    4) echo -e "\n ${BOLDYELLOW}Voce selecionou o compactador Zip... ${NC} \n"; sleep 2; _ZIP 
        ;;
    5) echo -e "\n ${BOLDYELLOW}Voce selecionou o compactador 7zip... ${NC} \n"; sleep 2; _7z
        ;;
    6) clear; exit
        ;;
    *) echo -e "\n ${BOLD}Favor usar uma das opcoes: { 1|2|3|4|5|6 } ${NC} \n" 
        ;;
esac

