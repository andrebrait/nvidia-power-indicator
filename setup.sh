#!/bin/bash
# This file is part of NVIDIA Power Indicator - indicator applet for NVIDIA Optimus laptops.
# Copyright (C) 2016 André Brait Carneiro Fabotti
#
# This work is based on the works of Alfred Neumayer and Clement Lefebvre.
#
# NVIDIA Power Indicator is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NVIDIA Power Indicator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NVIDIA Power Indicator.  If not, see <http://www.gnu.org/licenses/>.

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 2>&1
    exit 1
fi

LIB_DIR="/usr/lib/nvidia-power-indicator"
SUDOERS_FILE="/etc/sudoers.d/99-nvidia-power-indicator-sudoers"
AUTOSTART_FILE="/etc/xdg/autostart/nvidia-power-indicator.desktop"

cp -R usr /
cp -R etc /
chown -R root:root ${LIB_DIR}
chmod 755 ${LIB_DIR}
chmod 755 ${LIB_DIR}/icons
chmod 644 ${LIB_DIR}/icons/*
chmod 755 ${LIB_DIR}/nvidia-power-indicator
chmod 755 ${LIB_DIR}/gpuswitcher
chown root:root ${SUDOERS_FILE}
chmod 400 ${SUDOERS_FILE}
chown root:root ${AUTOSTART_FILE}
chmod 644 ${AUTOSTART_FILE}

echo "Autostart NVIDIA Power Indicator?"
select yn in "Yes" "No"; do
    case ${yn} in
        Yes ) 	break;;
        No ) 	rm -f ${AUTOSTART_FILE}
        		break;;
    esac
done

echo -e "\nTo start NVIDIA Power Indicator now, use the command\n"
echo -e "\t$LIB_DIR/nvidia-power-indicator & disown"

echo -e "\nSetup complete."
exit 0
