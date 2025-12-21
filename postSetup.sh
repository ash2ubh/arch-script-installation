#!/usr/bin/env bash

check_pkg_i(){
    if pacman -Qi "${1}" &>/dev/null; then
        return 0
    else 
        return 1
    fi
}

check_svc(){
    if [[ $(systemctl list-units --all -t service --full --no-legend "${1}.service" | sed 's/^\s*//g' | cut -f1 -d' ') == "${1}.service" ]]; then
        return 0
    else
        return 1
    fi 
}

svc_lst=(
    NetworkManager
    bluetooth
    nbfc_service
    preload
)

if check_pkg_i "nbfc-linux"; then
    sudo nbfc config --set auto
fi

for servChk in "${svc_lst[@]}"; do
    if check_svc ${servChk}; then
        printf "\n%s - ${servChk} service system is Already Active \n"
    else
        printf "\n%s - Start ${servChk} service system... \n"
        sudo systemctl enable "${servChk}.service"
        sudo systemctl start "${servChk}.service"
        printf "\n%s - ${servChk} service system is Active ... \n"
    fi
done

#######
# Zsh #
#######

plugin_lst=(
    https://github.com/chrissicool/zsh-256color             # enhance terminal environment with 256 colors
    https://github.com/zsh-users/zsh-completions            # press tab to complete command
    https://github.com/zsh-users/zsh-autosuggestions        # suggests commands as you type based on history
    https://github.com/zsh-users/zsh-syntax-highlighting    # highlights commands as you type
)

if check_pkg_i "zsh" && check_pkg_i "oh-my-zsh-git"; then
    # set variables
    Zsh_rc="${ZDOTDIR:-$HOME}/.zshrc"
    Zsh_Path="/usr/share/oh-my-zsh"
    Zsh_Plugins="$Zsh_Path/custom/plugins"
    Fix_Completion=""

    # generate plugins from list
    for r_plugin in "${plugin_lst[@]}"; do
        z_plugin=$(echo "${r_plugin}" | awk -F '/' '{print $NF}')
        if [ "${r_plugin:0:4}" == "http" ] && [ ! -d "${Zsh_Plugins}/${z_plugin}" ]; then
            sudo git clone "${r_plugin}" "${Zsh_Plugins}/${z_plugin}"
        fi
        if [ "${z_plugin}" == "zsh-completions" ] && [ "$(grep 'fpath+=.*plugins/zsh-completions/src' "${Zsh_rc}" | wc -l)" -eq 0 ]; then
            Fix_Completion='\nfpath+=${ZSH_CUSTOM:-${ZSH:-/usr/share/oh-my-zsh}/custom}/plugins/zsh-completions/src'
        else
            [ -z "${z_plugin}" ] || w_plugin+=" ${z_plugin}"
        fi
    done

    # update plugin array in zshrc
    echo -e "\033[0;32m[SHELL]\033[0m installing plugins (${w_plugin} )"
    sed -i "/^plugins=/c\plugins=(${w_plugin} )${Fix_Completion}" "${Zsh_rc}"
fi

# set shell
while ! chsh -s $(which zsh); do
    echo "Setup Shell Failed."
    sleep 1
done

# .zsh & .p10k.zsh
cp -r "${scrDir}/../setups/.zshrc" "${HOME}"
cp -r "${scrDir}/../setups/.p10k.zsh" "${HOME}"

# kwalletrc
if [ ! -d "~/.config/kwalletrc" ]; then
   cp -r "${scrDir}/../setups/.config/kwalletrc" "${HOME}/.config"
fi

# modprobe
if [ ! -d "/etc/modprobe.d/blacklist.conf" ]; then
   sudo touch /etc/modprobe.d/blacklist.conf 
   sudo echo -e '\n install nouveau /bin/true\n blacklist iTCO_wdt\n blacklist joydev\n blacklist mac_hid' | sudo tee -a /etc/modprobe.d/blacklist.conf 
fi

# Nvidia
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
 echo "Nvidia modules already included in /etc/mkinitcpio.conf"
else
 sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
 echo "Nvidia modules added in /etc/mkinitcpio.conf"

 sudo mkinitcpio -P 
fi

if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia | wc -l) -gt 0 ]; then
    if [ $(grep 'MODULES=' /etc/mkinitcpio.conf | grep nvidia | wc -l) -eq 0 ]; then
        sudo sed -i "/MODULES=/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/" /etc/mkinitcpio.conf
        sudo mkinitcpio -P
        if [ $(grep 'options nvidia-drm modeset=1' /etc/modprobe.d/nvidia.conf | wc -l) -eq 0 ]; then
            echo 'options nvidia-drm modeset=1' | sudo tee -a /etc/modprobe.d/nvidia.conf
        fi
    fi
fi

# GRUB
if ! sudo grep -i "nvidia-drm.modeset=1" /etc/default/grub; then
   sudo sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=".*"|GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 nvidia-drm.modeset=1 nvidia_drm.fbdev=1 rd.systemd.show_status=false nowatchdog mitigations=off"|' /etc/default/grub
   echo "modify /etc/default/grub"
   sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Network Manager
if ! sudo grep -i "dns=none" /etc/NetworkManager/NetworkManager.conf; then
   sudo echo -e '\n [main]\n dns=none\n systemd-resolved=false' | sudo tee -a /etc/NetworkManager/NetworkManager.conf
fi

# Resolv DNS
if ! sudo grep -i "nameserver 1.1.1.1" /etc/resolv.conf; then
   sudo echo -e '\n options timeout:1\n options single-request\n \n nameserver 1.1.1.1\n nameserver 1.0.0.1\n nameserver 8.8.8.8' | sudo tee -a /etc/resolv.conf
   sudo chattr +i /etc/resolv.conf
fi

GET_GLXINFO=$(glxinfo | grep "direct rendering" | awk '{print $3}')
if echo "$GET_GLXINFO" -eq "Yes";then
    sudo pacman -S mesa-utils --noconfirm
fi

echo 'vm.swappiness = 60' | sudo tee -a /etc/sysctl.d/99-swappiness.conf