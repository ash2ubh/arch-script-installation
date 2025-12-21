#!/usr/bin/env bash

TARGET_DISK=""

BOOT_PART="1"
SWAP_PART="2"
ROOT_PART="3"

HOSTNAME=""
USERNAME=""
PASSWORD=""
TIMEZONE=""
GET_UCODE=""
SELECTED_DISK=""

check_internet_connection(){
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
    fi
}

pre_setup(){

    pacman-key -v archlinux-version-x86_64.iso.sig

    iso=$(curl -4 ifconfig.co/country-iso)
    timedatectl set-ntp true

    pacman -Sy 
    pacman -S --noconfirm archlinux-keyring wget
    pacman -S --noconfirm --needed pacman-contrib

    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    pacman -S --noconfirm --needed reflector rsync grub
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
    mkdir /mnt &>/dev/null 
}

diskpart_setup(){
    
    list_disk=()
    while IFS= read -r line; do
        list_disk+=("$line")
    
    done < <(lsblk -d -o NAME,SIZE,TYPE,MODEL,MOUNTPOINT | grep -v '^$')

    if [ ${#list_disk[@]} -eq 0 ]; then
        echo "Disk Not Found!"
        exit 1
    fi

    selected=1
    quit=false

    while ! $quit; do
        clear
        echo "#########################################################"
        echo "#       Use arrow keys to select, and press Enter       #"
        echo "#########################################################"
        echo ""
    
        for i in "${!list_disk[@]}"; do
            if [ $i -eq $selected ]; then
                echo "> ${list_disk[$i]}"
            else
                echo "  ${list_disk[$i]}"
            fi
        done

        read -rsn1 key
        case "$key" in
            $'\x1b')  
                read -rsn2 -t 0.1 key2
                case "$key2" in
                    '[A') 
                        selected=$((selected - 1))
                        if [ $selected -lt 0 ]; then
                            selected=$((${#list_disk[@]} - 1))
                        fi
                        ;;
                    '[B') 
                        selected=$((selected + 1))
                        if [ $selected -ge ${#list_disk[@]} ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '')  
                quit=true
                ;;
            'q')  
                exit 0
                ;;
        esac
    done

    SELECTED_DISK=$(echo "${list_disk[$selected]}" | awk '{print $1}')

    TARGET_DISK="/dev/$SELECTED_DISK"

    if $SELECTED_DISK | grep -i "nvme" > /dev/null;then
        
        GET_SECTOR_SIZE=$(nvme id-ns -H $TARGET_DISK | grep "Relative Performance" | awk '{print $1 $2 $3 $12}' | grep '4096')

        if GET_SECTOR_SIZE $> /dev/null;then

            nvme format --lbaf=$GET_LBA_FORMAT $TARGET_DISK
        
        fi

    fi 

    if $SELECTED_DISK | grep -i "sd" > /dev/null;then
        
        GET_SECTOR_SIZE=$(hdparm -I $TARGET_DISK | grep "Sector size:" | grep '4096')

        if GET_SECTOR_SIZE $> /dev/null;then

            hdparm --set-sector-size 4096 --please-destroy-my-drive $TARGET_DISK
        
        fi

    fi 

    MEM_SIZE=$(awk '/MemTotal/ {print $2}' /proc/meminfo | numfmt --from-unit=K --to=si --suffix=B --format="%.2f" | awk '{printf "%d\n", $1}')

    if [ "$MEM_SIZE" -gt 8 ]; then
        SWAP_SIZE=$(awk '/MemTotal/ {print $2}' /proc/meminfo  | numfmt --from-unit=K --to=si --suffix=B --format="%.2f" | awk '{printf $1 * 1.5}' |awk '{printf "%dGB\n", $1}')
    else
        SWAP_SIZE="8GB"
    fi
    
    echo "Swap SIZE [Auto Setup Used]: $SWAP_SIZE"

    DISK_SIZE=$(lsblk -d -o NAME,SIZE | grep $SELECTED_DISK | awk '{printf $2}' | awk '{printf "%d\n", $1}')
    echo "Total Disk Size: ${DISK_SIZE}GB"
    
    read -p "Do you want used auto setup root partition based 50% capacity of the disk? [(y) Disk Size must be more then 256GB] (y/n): " response

    if [[ "$response" =~ ^[Yy]$|^[Yy][Ee][Ss]$ ]] && [ "$DISK_SIZE" -gt 256 ]; then
        
        GET_SIZE=$((("$DISK_SIZE" - 1) / 2))
        ROOT_SIZE=$((GET_SIZE -"${SWAP_SIZE%GB}"))"GB"


        echo "ROOT SIZE [Auto Setup Used]: $ROOT_SIZE"

        fdisk $TARGET_DISK << EOF
g

n
1

+1GB
t
1

n
2

+${SWAP_SIZE}
t
2
19

n
3

+${ROOT_SIZE}
t
3
20
w
EOF

    else
        fdisk $TARGET_DISK << EOF
g

n
1

+1GB
t
1

n
2

+${SWAP_SIZE}
t
2
19

n
3


t
3
20
w
EOF

    fi
    
    echo "Partitioning Successfully!"
}

format_partition(){
    echo "Start formatting partitions..."

    # mkfs.fat -F32 "${TARGET_DISK}${BOOT_PART}"
    # mkfs.ext4 "${TARGET_DISK}${ROOT_PART}" 
    mkfs.fat -F32 -S 4096 "${TARGET_DISK}${BOOT_PART}"
    mkfs.ext4 -b 4096 "${TARGET_DISK}${ROOT_PART}" 

    mkswap "${TARGET_DISK}${SWAP_PART}"
    swapon "${TARGET_DISK}${SWAP_PART}"

    mount "${TARGET_DISK}${ROOT_PART}" /mnt
    mkdir -p /mnt/boot
    mount "${TARGET_DISK}${BOOT_PART}" /mnt/boot

    echo "Finished formatting partitions."
}

inputed(){

    read -p "Password : " getpasswd
    PASSWORD=$getpasswd

    read -p "Username : " getusernm
    USERNAME=$getusernm

    TIMEZONE=$(curl -s https://ipapi.co/timezone)

    read -p "Hostname : " gethostnm
    HOSTNAME=$gethostnm

}

install_base(){
    echo "Start Installing base system..."

    get_cpu_model=$(cat /proc/cpuinfo | grep "model name" | uniq)
    if echo "$get_cpu_model" | grep -i "intel" > /dev/null; then
        GET_UCODE="intel-ucode"
    elif echo "$get_cpu_model" | grep -i "amd" > /dev/null; then
        GET_UCODE="amd-ucode"
    fi

    pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware "$GET_UCODE" networkmanager wireless_tools wpa_supplicant sof-firmware dosfstools ntfs-3g mtools util-linux exfatprogs e2fsprogs sudo nano man-db man-pages texinfo wget curl git grub efibootmgr os-prober --noconfirm --needed

    echo "Finished Installing base system."
}

generate_fstab(){
    echo "Start Generating fstab..."

    genfstab -U /mnt >> /mnt/etc/fstab
    echo "Generated /etc/fstab:"
    cat /mnt/etc/fstab

    echo "Finished Generating fstab."

}

arch_chroot(){
    echo "Start Configuring system..."

    cat > /mnt/chroot_script.sh << EOF
TARGET_DISK="$TARGET_DISK"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
TIMEZONE="$TIMEZONE"
BOOT_PART="$BOOT_PART"
SELECTED_DISK="$SELECTED_DISK"

echo "root:\$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

useradd -m -G wheel,audio,video,storage,optical -s /bin/bash "\$USERNAME"
echo "\$USERNAME:\$PASSWORD" | chpasswd
# mkdir -m 755 /etc/sudoers.d
echo "\$USERNAME ALL=(ALL) ALL" > /etc/sudoers.d/\$USERNAME
chmod 0440 /etc/sudoers.d/\$USERNAME

ln -sf /usr/share/zoneinfo/\$TIMEZONE /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
cat /etc/locale.conf

echo "KEYMAP=us" >> /etc/vconsole.conf

echo "\$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   \$HOSTNAME.localdomain \$HOSTNAME
HOSTS_EOF

mount "\$TARGET_DISK\$BOOT_PART" /boot
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable --now NetworkManager

echo kyber > /sys/block/\$SELECTED_DISK/queue/scheduler

EOF

    chmod +x /mnt/chroot_script.sh
    arch-chroot /mnt /chroot_script.sh
    rm /mnt/chroot_script.sh

    echo "Finished Configuring system."
}

result_installation(){
    
    umount -R /mnt

    echo -ne "
    ###########################################################
    #           Arch Linux Installation Completed             #
    ###########################################################
    "

    echo -ne "
    ###########################################################
    #                 Hostname: $HOSTNAME                     #   
    #                 Username: $USERNAME                     #
    #                 Password: $PASSWORD                     #
    #                 Timezone: $TIMEZONE                     #
    ###########################################################
    "
}

main(){
    
    setfont ter-120n

    echo "Starting Arch Linux installation..."
    
    check_internet_connection
    pre_setup
    diskpart_setup
    format_partition
    inputed
    install_base
    generate_fstab
    arch_chroot
    result_installation

    echo "Finished Arch Linux installation."
}

main "$@"