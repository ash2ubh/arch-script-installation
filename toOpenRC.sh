#!/usr/bin/env bash
if ! cat /etc/pacman.conf | grep -i "openrc-eudev"; then
    echo -e "[openrc-eudev]\nSigLevel=PackageOptional\nServer=http://downloads.sourceforge.net/project/archopenrc/\$repo/\$arch" >> /etc/pacman.conf
***REMOVED***

systemctl list-units --state=running "*.service" > daemons.list

pacman -Syl openrc-eudev

pacman -Sw sysvinit openrc-core eudev eudev-openrc eudev-systemdcompat dbus-nosystemd procps-ng-nosystemd syslog-ng-nosystemd

pacman -Rdd systemd libsystemd

pacman -S sysvinit openrc-core eudev eudev-openrc eudev-systemdcompatPATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA
