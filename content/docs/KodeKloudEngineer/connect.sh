#!/bin/bash

# ----------------------------------------------
#  Server Definitions
# ----------------------------------------------

declare -A SERVERS
declare -A USERS
declare -A PASSWORDS

# App Servers
SERVERS[stapp01]="172.16.238.10"; USERS[stapp01]="tony";    PASSWORDS[stapp01]="Ir0nM@n"
SERVERS[stapp02]="172.16.238.11"; USERS[stapp02]="steve";   PASSWORDS[stapp02]="Am3ric@"
SERVERS[stapp03]="172.16.238.12"; USERS[stapp03]="banner";  PASSWORDS[stapp03]="BigGr33n"

# Load Balancer
SERVERS[stlb01]="172.16.238.14"; USERS[stlb01]="loki";     PASSWORDS[stlb01]="Mischi3f"

# DB Server
SERVERS[stdb01]="172.16.239.10"; USERS[stdb01]="peter";    PASSWORDS[stdb01]="Sp!dy"

# Storage
SERVERS[ststor01]="172.16.238.15"; USERS[ststor01]="natasha"; PASSWORDS[ststor01]="Bl@kW"

# Backup
SERVERS[stbkp01]="172.16.238.16"; USERS[stbkp01]="clint";   PASSWORDS[stbkp01]="H@wk3y3"

# Mail
SERVERS[stmail01]="172.16.238.17"; USERS[stmail01]="groot"; PASSWORDS[stmail01]="Gr00T123"

# CI/CD Server
SERVERS[jenkins]="172.16.238.19"; USERS[jenkins]="jenkins"; PASSWORDS[jenkins]="j@rv!s"


# ----------------------------------------------
#  Functions
# ----------------------------------------------

connect_server() {
    local host=$1
    local ip=${SERVERS[$host]}
    local user=${USERS[$host]}
    local pass=${PASSWORDS[$host]}

    echo "Connecting to $host ($ip) ..."
    echo "User: $user"
    echo "Password: $pass"
    sleep 1

    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user@$ip"
}

submenu() {
    local title=$1
    shift
    local items=("$@")

    while true; do
        clear
        echo "==== $title ===="
        echo

        i=1
        for host in "${items[@]}"; do
            echo "$i) $host  (User: ${USERS[$host]} | Pass: ${PASSWORDS[$host]} | IP: ${SERVERS[$host]})"
            ((i++))
        done

        echo "0) Back"
        echo
        read -p "Select: " opt

        if [[ $opt -eq 0 ]]; then
            return
        fi

        idx=$((opt-1))
        if [[ $idx -ge 0 && $idx -lt ${#items[@]} ]]; then
            connect_server "${items[$idx]}"
        else
            echo "Invalid option"
            sleep 1
        fi
    done
}

search_server() {
    read -p "Enter hostname (partial allowed): " query
    matches=()

    for key in "${!SERVERS[@]}"; do
        if [[ $key == *"$query"* ]]; then
            matches+=("$key")
        fi
    done

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "No matching servers."
        sleep 1
        return
    fi

    if [[ ${#matches[@]} -eq 1 ]]; then
        connect_server "${matches[0]}"
        return
    fi

    submenu "Search Results" "${matches[@]}"
}


# ----------------------------------------------
#  Main Menu
# ----------------------------------------------

while true; do
    clear
    echo "==== Nautilus Server Menu ===="
    echo
    echo "1) App Servers"
    echo "2) Load Balancer"
    echo "3) Database Server"
    echo "4) Storage Server"
    echo "5) Backup Server"
    echo "6) Mail Server"
    echo "7) CI/CD (Jenkins)"
    echo "8) Search by hostname"
    echo "0) Exit"
    echo
    read -p "Enter choice: " choice

    case $choice in
        1) submenu "App Servers" stapp01 stapp02 stapp03 ;;
        2) submenu "Load Balancer" stlb01 ;;
        3) submenu "Database Server" stdb01 ;;
        4) submenu "Storage Server" ststor01 ;;
        5) submenu "Backup Server" stbkp01 ;;
        6) submenu "Mail Server" stmail01 ;;
        7) submenu "CI/CD Server" jenkins ;;
        8) search_server ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice"; sleep 1 ;;
    esac
done
