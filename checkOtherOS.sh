#!/usr/bin/env bash

nano /etc/default/grub

pacman -S os-prober

grub-mkcon***REMOVED***g -o /boot/grub/grub.cfg