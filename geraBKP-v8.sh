#!/usr/bin/env bash
#
# Script para gerar backup de uma dada pasta
# Versão: 5 
# Desenvolvedor: Cesar A. Camargo
# 17-09-2021 - Reescrição das linhas de teste de condição que estavam utilizando os "ifs". 
# 20-11-2024 - Reescrição das linhas que contém os comandos de compactação deixando-os mais simplificados. 
# 09/04/2026 - Inserido no codigo o programa para console Dialog que desenha caixas de dialogos na tela, similares as do modo
#               gráfico, com botões, entradas para texto e menu.

#origem=$1
origem=$( dialog --stdout --backtitle 'Entrada de Dados' --inputbox "Insira o arquivo ou pasta:" 0 0 )

## Verificar se foi fornecido parâmetro
[ -z $origem ] && { dialog --title 'ERRO:' --infobox "\nDados não encontrado ou campo vazio! " 5 40; sleep 2; clear; }

## Verificar se o diretório de origem existe
[ ! -d "$origem" ] && { dialog --title 'ERRO:' --infobox "\nDiretório não existe!" 5 40; sleep 2; clear; exit; }
 
data=$(date +%d%m%Y)

#################[ Aqui comeca as funções ]##################################

function _ZIP {

    dialog --title 'Processando...' --infobox "\nCompactando $origem ..." 5 40; sleep 2 ;

    zip -qr "Backup_$origem-$data.zip" "$origem"

    dialog --title 'Finalizado' --infobox "\nBackup em ZIP criado com sucesso em $(pwd)" 5 90; sleep 2; clear; exit
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

    dialog --title 'Processando...' --infobox "\nCompactando $origem ..." 5 30 ; sleep 2

    7z a "Backup_$origem-$data.7z" "$origem/*"

    dialog --title 'Finalizado' --infobox "\nBackup em 7zip criado com sucesso em $(pwd)" 5 90; sleep 2; clear; exit
}

function Bz2 {
    
    dialog --title 'Processando...' --infobox "\nCompactando $origem ..." 5 30 ; sleep 2

    tar -cvjf "Backup_$origem-$data.tar.bz2" "$origem"

    dialog --title 'Finalizado' --infobox "\nBackup em Bzip2 criado com sucesso em $(pwd)" 5 90; sleep 2; clear; exit
}

function Gzip {

    dialog --title 'Processando...' --infobox "\nCompactando $origem ..." 5 30 ; sleep 2

    tar -cvzf "Backup_$origem-$data.tar.gz" "$origem"

    dialog --title 'Finalizado' --infobox "\nBackup em Gzip criado com sucesso em $(pwd)" 5 90; sleep 2; clear; exit
}

function Xz {

    dialog --title 'Processando...' --infobox "\nCompactando $origem ..." 5 30 ; sleep 2

    tar -Jcvf "Backup_$origem-$data.tar.xz" "$origem" 

    dialog --title 'Finalizado' --infobox "\nBackup em Xz criado com sucesso em $(pwd)" 5 90; sleep 2; clear; exit
}

#################[ Linhas de Comandos ]############################## 

opc=$( dialog --stdout --title 'Opções' --menu "Escolha um tipo de compactador:" 0 0 0 \
    1 "Bzip2"  \
    2 "Gzip"   \
    3 "Xz"     \
    4 "Zip"    \
    5 "7zip"   \
    6 "Sair ->" )

# Apertou CANCELAR ou ESC para sair...
[ $? -ne 0 ] && exit

case $opc in

	1) dialog --title 'Aviso:' --infobox  "\nFoi selecionado o compactador Bzip2..." 5 40; sleep 2; Bz2
        ;;
	2) dialog --title 'Aviso:' --infobox  "\nFoi selecionado o compactador Gzip..." 5 50; sleep 2; Gzip
        ;;
	3) dialog --title 'Aviso:' --infobox  "\nFoi selecionado o compactador Xz..." 5 40; sleep 2; Xz
        ;;    
    4) dialog --title 'Aviso:' --infobox  "\nFoi selecionado o compactador Zip..." 5 40; sleep 2; _ZIP 
        ;;
    5) dialog --title 'Aviso:' --infobox  "\nFoi selecionado o compactador 7zip..." 5 40; sleep 2; _7z
        ;;
    6) clear; exit
        ;;
    *) dialog --title 'Aviso:' --infobox  "Usar uma das opcoes: { 1|2|3|4|5|6 }" 
        ;;
esac

