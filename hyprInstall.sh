#!/usr/bin/env bash

if ! ping -c 5 google.com &> /dev/null; then
    echo -ne "Connect the internet with command:\n"
    echo -ne "- iwctl\n"
    echo -ne "- device list\n"
    echo -ne "- station DeviceName get-networks\n"
    echo -ne "- station DeviceName connect NetworkNames\n"
    echo -ne "- exit\n"
    
    exit 1
fi

check_pkg_i(){
    if pacman -Qi "${1}" &>/dev/null; then
        return 0
    else 
        return 1
    fi
}

hypr_base=(
    aquamarine                          # a very light linux rendering backend library
    kitty                               # A modern, hackable, featureful, OpenGL-based terminal emulator
    hyprland                            # a highly customizable dynamic tiling Wayland compositor
    hyprutils                           # Hyprland utilities library used across the ecosystem
    hyprlang                            # implementation library for the hypr config language
    xdg-desktop-portal-hyprland         # xdg-desktop-portal backend for hyprland
    hyprwire                            # A fast and consistent wire protocol for IPC
    libastal-hyprland-git               # Library and cli tool for Hyprland IPC sockets
    hyprland-protocols                  # Wayland protocol extensions for Hyprland
    hypridle                            # hyprland’s idle daemon
    hyprwayland-scanner                 # A Hyprland implementation of wayland-scanner, in and for C++
    hyprland-qt-support                 # QML style provider for Hypr* QT apps
    hyprland-guiutils                   # Hyprland GUI utilities
    hyprgraphics                        # hyprland graphics resources and utilities
    xdg-desktop-portal-gtk              # A backend implementation for xdg-desktop-portal using GTK
    qt6-wayland                         # Provides APIs for Wayland
    qt6ct-kde                           # Qt 6 Configuration Utility, patched to work correctly with KDE applications
    hyprqt6engine                       # QT6 Theme Provider for Hyprland
    kvantum                             # SVG-based theme engine for Qt6 (including config tool and extra themes)
    gtk3                                # GObject-based multi-platform GUI toolkit
    gtk4                                # GObject-based multi-platform GUI toolkit
    egl-wayland                         # EGLStream-based Wayland external platform
    parallel                            # A shell tool for executing jobs in parallel 
    xdg-user-dirs                       # Manage user directories like ~/Desktop and ~/Music            
    xdg-utils                           # Command line tools that assist applications with a variety of desktop integration tasks
    jq                                  # Command-line JSON processor
    rink                                # Unit conversion tool and library written in rust
    kservice                            # Advanced plugin and service introspection
)

printf "\n%s - Start Install Hyprland dependencies \n"
for PKG in "${hypr_base[@]}"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --noconfirm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --noconfirm "$PKG" 
        else 
            printf "\n%s - Package "$PKG" is not found!. \n"
        fi
        printf "\n%s - Finished Install "$PKG" \n"
    else
         printf "\n%s - "$PKG" already exist. \n"
    fi
done

hypr_util=(
    sddm                                # QML based X11 and Wayland display manager
    uwsm                                # A standalone Wayland session manager
    quickshell                          # Flexible toolkit for making desktop shells with QtQuick
    dunst                               # Customizable and lightweight notification-daemon
    libnotify                           # Library for sending desktop notifications    
    hyprcursor                          # The hyprland cursor format, library and utilities
    hyprpaper                           # a blazing fast wayland wallpaper utility with IPC controls
    rofi                                # A window switcher, application launcher and dmenu replacement    
    hyprlock                            # hyprland’s GPU-accelerated screen locking utility
    wlogout                             # Logout menu for wayland
    hyprtoolkit                         # A modern C++ Wayland-native GUI toolkit
    hyprpolkitagent                     # Simple polkit authentication agent for Hyprland, written in QT/QML
    hyprsunset                          # An application to enable a blue-light filter on Hyprland 
    hyprpicker                          # A wlroots-compatible Wayland color picker that does not suck
    hyprshot                            # Hyprland screenshot utility
    hyprpwcenter                        # A GUI Pipewire control center
    hyprshade                           # Hyprland shade configuration tool
    hyprsome-git
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    ttf-lato
    ttf-hack
    ttf-material-symbols-variable-git 
    imagemagick                         # An image viewing/manipulation program                     
    brightnessctl                       # Lightweight brightness control tool
    udiskie                             # Removable disk automounter using udisks
    grim                                # Screenshot utility for Wayland
    slurp                               # Select a region in a Wayland compositor
    swappy                              # A Wayland native snapshot editing tool
    fastfetch                           # A feature-rich and performance oriented neofetch like system information tool
    ddcutil                             # Query and change Linux monitor settings using DDC/CI and USB.
    playerctl                           # mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others.
    matugen                             # A material you color generation tool
    adw-gtk-theme                       # Unofficial GTK 3 port of the libadwaita theme
    breeze                              # Artwork, styles and assets for the Breeze visual style for the Plasma Desktop
    cliphist                            # wayland clipboard manager
    wl-clipboard                        # Command-line copy/paste utilities for Wayland
    kwallet                             # Secure and unified container for user passwords
    glibc                               # GNU C Library
    gzip                                # GNU compression utility
    preload                             # Makes applications run faster by prefetching binaries and shared objects
    polkit
    nautilus-open-any-terminal
    yazi
    zsh                            
    eza
    oh-my-zsh-git
    zsh-theme-powerlevel10k-git
    pokemon-colorscripts-git
    ttf-material-design-icons-desktop-git
    ttf-meslo-nerd-font-powerlevel10k
)

printf "\n%s - Start Install Hyprland utilites \n"
for PKG in "${hypr_util[@]}"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --noconfirm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --noconfirm "$PKG" 
        else 
            printf "\n%s - Package "$PKG" is not found!. \n"
        fi
        printf "\n%s - Finished Install "$PKG" \n"
    else
         printf "\n%s - "$PKG" already exist. \n"
    fi
done

GET_VGA=$(lspci | grep -i "vga" | awk '{print $5}')

if echo "$GET_VGA" | grep -i "intel";then
    intel_dep=(
        libva-intel-driver 
        libva-utils
        libvdpau-va-gl 
        vulkan-intel 
        mesa
        lib32-vulkan-intel
        lib32-mesa 
        intel-media-driver
        intel-hybrid-codec-driver-git
        libvpl 
        vpl-gpu-rt   
    )
    for INTEL in "linux-zen-headers" "${intel_dep[@]}"; do
        sudo pacman -S --noconfirm "$INTEL"
    done
fi

if echo "$GET_VGA" | grep -i "nvidia";then
    nvidia_dep=(
        nvidia-dkms                                     
        nvidia-utils 
        nvidia-settings
        libva                        
        libva-nvidia-driver-git
        nvidia-xconfig
    )

    for NVIDIA in "linux-zen-headers" "${nvidia_dep[@]}"; do
        sudo pacman -S --noconfirm "$NVIDIA"
    done
fi


printf "\n%s - Start Install Extra dependencies \n"
for PKG in "${extra_dep[@]}"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --noconfirm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --noconfirm "$PKG" 
        else 
            printf "\n%s - Package "$PKG" is not found!. \n"
        fi
        printf "\n%s - Finished Install "$PKG" \n"
    else
         printf "\n%s - "$PKG" already exist. \n"
    fi
done


hypr_driver_dep=(           
    gst-plugin-pipewire                                  
    wireplumber                                            
    pavucontrol                                            
    pamixer                                                                                  
    network-manager-applet
    bluez 
    bluez-utils                                
    blueman
    pipewire 
    pipewire-alsa 
    alsa-utils 
    pipewire-pulse 
    pipewire-jack 
    pipewire-audio                                          
    brightnessctl
    udiskie 
    nbfc-linux 
)

printf "\n%s - Start Install Hyprland driver dependencies \n"
for PKG in "${hypr_driver_dep[@]}"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --noconfirm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --noconfirm "$PKG" 
        else 
            printf "\n%s - Package "$PKG" is not found!. \n"
        fi
        printf "\n%s - Finished Install "$PKG" \n"
    else
         printf "\n%s - "$PKG" already exist. \n"
    fi
done

extra_dep=(
    pacman-contrib   
    dipc
    dnsmasq
    htop
    ffmpeg-full
    libnewt
    mpv
    nodejs-lts-iron
    npm
    rust
    rust-analyzer
    rust-src
    sshd-openpgp-auth
    sshpass
    yt-dlp
)

printf "\n%s - Start Install Extra dependencies \n"
for PKG in "${extra_dep[@]}"; do
    if ! check_pkg_i "$PKG";then
        printf "\n%s - Start Install "$PKG" \n"
        if pacman -Ss "$PKG" &> /dev/null; then 
            sudo pacman -S --noconfirm "$PKG" 
        elif yay -Ss "$PKG" &> /dev/null; then 
            yay -S --noconfirm "$PKG" 
        else 
            printf "\n%s - Package "$PKG" is not found!. \n"
        fi
        printf "\n%s - Finished Install "$PKG" \n"
    else
         printf "\n%s - "$PKG" already exist. \n"
    fi
done
