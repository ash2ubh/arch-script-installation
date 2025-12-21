#!/usr/bin/env bash

nano /etc/default/grub

pacman -S os-prober

grub-mkconfig -o /boot/grub/grub.cfg