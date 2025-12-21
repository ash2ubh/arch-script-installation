#!/usr/bin/env bash

pacman -S grub e***REMOVED***bootmgr dosfstools mtools
grub-install --target=x86_64-e***REMOVED*** --e***REMOVED***-directory=/boot --bootloader-id=GRUB
grub-mkcon***REMOVED***g -o /boot/grub/grub.cfg
#exit
#unmount -IR /mnt
PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA
