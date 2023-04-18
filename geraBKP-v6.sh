#!/bin/bash
#
# Script para gerar backup de uma dada pasta
# Versão: 5 
# 17-09-2021 - Reescrição das linhas de teste de condição que estavam utilizando os "ifs". 

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

    echo -e "\nBackup em ZIP criado com sucesso em $(pwd)\n"
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

    echo -e "\nBackup em 7zip criado com sucesso em $(pwd)\n"
    exit
}

function Bz2 {
    echo -e "\nCompactando $origem ...\n"
    #tar -cvjf "Backup_$origem-$data.bz2" "$origem"
    tar -cvf "Backup_$origem-$data.tar" "$origem" && bzip2 -9 "Backup_$origem-$data.tar"

    echo -e "\nBackup em Bzip2 criado com sucesso em $(pwd)\n"
    exit
}

function Gzip {
    echo -e "\nCompactando $origem ...\n"
    tar -cvf "Backup_$origem-$data.tar" "$origem" && gzip "Backup_$origem-$data.tar"

    echo -e "\nBackup em Gzip criado com sucesso em $(pwd)\n"
    exit
}

function Xz {
    echo -e "\nCompactando $origem ...\n"
    tar -Jcvf "Backup_$origem-$data.tar.xz" "$origem" 

    echo -e "\nBackup em Xz criado com sucesso em $(pwd)\n"
    exit
}

#################[ Linhas de Comandos ]############################## 
echo -e "\n1) Zip"
echo -e "\n2) 7zip"
echo -e "\n3) Bzip2"
echo -e "\n4) Gzip"
echo -e "\n5) Xz"
echo -e "\n6) Sair\n"

read -r -n1 -p "Selecione uma das opções acima: " opc

case $opc in
    1) echo -e "\n\nVoce selecionou o compactador Zip...\n"; sleep 3; _ZIP 
        ;;
    2) echo -e "\nVoce selecionou o compactador 7zip...\n"; sleep 3; _7z
        ;;
    3) echo -e "\nVoce selecionou o compactador Bzip2...\n"; sleep 3; Bz2
        ;;
    4) echo -e "\nVoce selecionou o compactador Gzip... \n"; sleep 3; Gzip
        ;;
    5) echo -e "\nVoce selecionou o compactador Xz... \n"; sleep 3; Xz
        ;;
    6) clear; exit
        ;;
    *) echo -e "\nUsar uma das opcoes: { 1|2|3|4|5|6 }\n" 
        ;;
esac

