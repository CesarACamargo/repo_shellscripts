#!/bin/bash
# scanner-wifi.sh — Escaneia redes Wi-Fi e sugere o melhor canal
# Uso: ./scanner-wifi.sh
# Linux: usa nmcli

set -eo pipefail

U_SER=$(id -u)

if [ "$U_SER" -ne 0 ]; then
    echo -e "\033[1;31m\nErro! Eh necessario ser ROOT para esta tarefa !\033[m\n"
    exit 1
fi

tput clear

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BOLD='\033[1m'
DIM='\033[0;90m'
RESET='\033[0m'

TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT

PARSED_FILE="$TMPDIR_WORK/parsed.txt"

# ── Detectar rede atual ──

get_current_ssid() {
    nmcli -t -f active,ssid dev wifi | grep '^sim' | cut -d: -f2 || echo ""
}

get_current_channel() {
    iw wlan0 info 2>/dev/null | awk '/channel/{gsub(/[^0-9]/,"",$2); print $2}'
}

# ── Scan ──

scan_networks() {
    nmcli -t -f SSID,CHAN dev wifi list | while IFS=: read -r ssid chan; do
        [ -n "$chan" ] && [ "$ssid" != "--" ] && echo "${chan}|${ssid}" >> "$PARSED_FILE"
    done
}

# ── Barra ──

signal_bar() {
    local count=$1
    local bar=""
    for ((i=0;i<8;i++)); do
        if [ $i -lt "$count" ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
    done
    echo "$bar"
}

echo -e "\n  Escaneando redes Wi-Fi...\n"

current_ssid=$(get_current_ssid)
current_channel=$(get_current_channel)

> "$PARSED_FILE"
scan_networks

echo -e "  ${BOLD}Redes encontradas (2.4 GHz):${RESET}\n"

printf "  %-6s %-6s %-10s %s\n" "Canal" "APs" "Sinal" "Nomes"
printf "  %-6s %-6s %-10s %s\n" "─────" "─────" "────────" "──────────────────────────────"

best_24_ch=""
best_24_count=999

best_any_ch=""
best_any_count=999

for ch in {1..13}; do

    aps=$(awk -F'|' -v c="$ch" '$1 == c' "$PARSED_FILE" | wc -l | tr -d ' ')
    names=$(awk -F'|' -v c="$ch" '$1 == c {print $2}' "$PARSED_FILE" | awk '!seen[$0]++' | paste -sd', ' -)

    # Melhor canal geral (qualquer um)
    if [ "$aps" -lt "$best_any_count" ]; then
        best_any_count=$aps
        best_any_ch=$ch
    fi

    # Melhor canal recomendado (1,6,11)
    case $ch in
        1|6|11)
            if [ "$aps" -lt "$best_24_count" ]; then
                best_24_count=$aps
                best_24_ch=$ch
            fi
            ;;
    esac

    # Pular canais vazios (exceto principais)
    if [ "$aps" -eq 0 ]; then
        case $ch in
            1|6|11) ;;
            *) continue ;;
        esac
    fi

    bar=$(signal_bar "$aps")

    # Destacar sua rede
    if [ -n "$current_ssid" ] && echo "$names" | grep -q "$current_ssid"; then
        names=$(echo "$names" | sed "s/$current_ssid/$(printf "${GREEN}${current_ssid}${RESET}")/")
    fi

    if [ "$aps" -ge 5 ]; then
        printf "  ${RED}%4d    %d    %s${RESET}  %b\n" "$ch" "$aps" "$bar" "$names"
    elif [ "$aps" -ge 3 ]; then
        printf "  ${YELLOW}%4d    %d    %s${RESET}  %b\n" "$ch" "$aps" "$bar" "$names"
    elif [ "$aps" -eq 0 ]; then
        printf "  %4d    %d    %s  ${DIM}(vazio)${RESET}\n" "$ch" "$aps" "$bar"
    else
        printf "  %4d    %d    %s  %b\n" "$ch" "$aps" "$bar" "$names"
    fi

done

echo ""
echo "  ─────────────────────────────────"
echo -e "  ${BOLD}Diagnóstico:${RESET}\n"

# Rede atual
if [ -n "$current_ssid" ]; then
    echo -e "  Sua rede:        ${GREEN}$current_ssid${RESET}"
else
    echo -e "  Sua rede:        ${DIM}(não detectada)${RESET}"
fi

# Canal atual
if [ -n "$current_channel" ]; then

    current_count=$(awk -F'|' -v c="$current_channel" '$1 == c' "$PARSED_FILE" | wc -l | tr -d ' ')

    if [[ "$current_channel" != "1" && "$current_channel" != "6" && "$current_channel" != "11" ]]; then
        echo -e "  Canal atual:     ${YELLOW}$current_channel — SOBREPOSTO (evite usar)${RESET}"
    else
        if [ "$current_count" -ge 5 ]; then
            echo -e "  Canal atual:     ${RED}$current_channel — CONGESTIONADO ($current_count APs)${RESET}"
        elif [ "$current_count" -ge 3 ]; then
            echo -e "  Canal atual:     ${YELLOW}$current_channel — MODERADO ($current_count APs)${RESET}"
        else
            echo -e "  Canal atual:     ${GREEN}$current_channel — BOM ($current_count APs)${RESET}"
        fi
    fi
fi

echo -e "\n  ${BOLD}Recomendação:${RESET}"

echo -e "  Canal menos ocupado: ${GREEN}$best_any_ch ($best_any_count APs)${RESET}"
echo -e "  Canal ideal 2.4 GHz: ${GREEN}$best_24_ch ($best_24_count APs, não sobreposto)${RESET}"

echo "  ─────────────────────────────────"
echo ""
