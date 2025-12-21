#!/usr/bin/env bash

if ! ping -c 5 archlinux.org  &> /dev/null; then
    echo -ne "Connect the internet with command:\n"
    echo -ne "- iwctl\n"
    echo -ne "- device list\n"
    echo -ne "- station DeviceName get-networks\n"
    echo -ne "- station DeviceName connect NetworkNames\n"
    echo -ne "- exit\n"

    exit 1
else
    echo -ne "- Connected.\n"
***REMOVED***

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

sddm_themes=(
    sddm-astronaut-theme
    sddm-silent-theme
    sddm-theme-obscure-git 
    where-is-my-sddm-theme-git
)

printf "\n%s - Start Install Hyprland dependencies \n"
for PKG in "${sddm_themes[@]***REMOVED***"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --nocon***REMOVED***rm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --nocon***REMOVED***rm "$PKG" 
***REMOVED*** 
            printf "\n%s - Package "$PKG" is not found!. \n"
    ***REMOVED***
        printf "\n%s - Finished Install "$PKG" \n"
***REMOVED***
done

applications=(
    brave-bin
    btop
    code
    dbeaver
    freedownloadmanager
    fsearch
    keepassxc
    neovim
    pycharm
    rustrover
    spotify
    spicetify-cli
    steam
    vivaldi
    webcord
    windsurf-electron-latest 
)

printf "\n%s - Start Install Applications \n"
for PKG in "${applications[@]***REMOVED***"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --nocon***REMOVED***rm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --nocon***REMOVED***rm "$PKG" 
***REMOVED*** 
            printf "\n%s - Package "$PKG" is not found!. \n"
    ***REMOVED***
        printf "\n%s - Finished Install "$PKG" \n"
***REMOVED***
done

svc_lst=(
    sddm
)

for servChk in "${svc_lst[@]***REMOVED***"; do
    if check_svc ${servChk***REMOVED***; then
        printf "\n%s - ${servChk***REMOVED*** service system is Already Active \n"
    else
        printf "\n%s - Start ${servChk***REMOVED*** service system... \n"
        sudo systemctl enable "${servChk***REMOVED***.service"
        sudo systemctl start "${servChk***REMOVED***.service"
        printf "\n%s - ${servChk***REMOVED*** service system is Active ... \n"
***REMOVED***
done
