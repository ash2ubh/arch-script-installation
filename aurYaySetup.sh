#!/usr/bin/env bash

if ! ping -c 5 google.com &> /dev/null; then
    echo -ne "Connect the internet with command:\n"
    echo -ne "- iwctl\n"
    echo -ne "- device list\n"
    echo -ne "- station DeviceName get-networks\n"
    echo -ne "- station DeviceName connect NetworkNames\n"
    echo -ne "- exit\n"
    
    exit 1
***REMOVED***

sudo pacman-key --init && sudo pacman-key --populate
# sudo pacman-key --refresh-keys
# sudo pacman -Scc
sudo pacman -S archlinux-keyring --nocon***REMOVED***rm

sudo pacman -S pacman-contrib reflector rsync --nocon***REMOVED***rm
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo reflector -a 48 -c "Germany" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

#Add parallel downloading
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

#Enable multilib
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo pacman -Sy --nocon***REMOVED***rm --needed

check_pkg_i(){
    if pacman -Qi "${1***REMOVED***" &>/dev/null; then
        return 0
    else 
        return 1
***REMOVED***
***REMOVED***

check_svc(){
    if [[ $(systemctl list-units --all -t service --full --no-legend "${1***REMOVED***.service" | sed 's/^\s*//g' | cut -f1 -d' ') == "${1***REMOVED***.service" ]]; then
        return 0
    else
        return 1
***REMOVED*** 
***REMOVED***

###############
# Chaotic-AUR #
###############
if ! check_pkg_i "chaotic-mirrorlist"; then
    printf "\n%s - Start Install and Con***REMOVED***guration Chaotic AUR \n"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com 
    sudo pacman-key --lsign-key 3056513887B78AEB 
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --nocon***REMOVED***rm
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --nocon***REMOVED***rm

    sudo echo -e '\n# Chaotic Aur\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf
    printf "\n%s - Finish Install and Con***REMOVED***guration Chaotic AUR \n"

    printf "\n%s - Start full system update along syncing our mirrorlist \n"
    sudo pacman -Syu --nocon***REMOVED***rm
    printf "\n%s - Finish update along syncing our mirrorlist \n"
else
    printf "\n%s - Chaotic AUR is Already Exist \n"
***REMOVED***

#######
# Yay #
#######
if ! check_pkg_i "yay"; then
    printf "\n%s - Start Install Yay \n"
    sudo pacman -S yay --nocon***REMOVED***rm
    printf "\n%s - Finish Install Yay \n"
else 
    printf "\n%s - Yay is Already Exist \n"
***REMOVED***

########################
# Base-devel & Keyring #
########################
base_key_lst=(
    base-devel 
    archlinux-keyring
)
printf "\n%s - Start Install base-devel & archlinux-keyring \n"
for PKG in "${base_key_lst[@]***REMOVED***"; do
    printf "\n%s - Start Install "$PKG" \n"
    sudo pacman -S --nocon***REMOVED***rm "$PKG" 
    printf "\n%s - Finished Install "$PKG" \n"
done
printf "\n%s - Finish Install base-devel & archlinux-keyring \n"
PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA
