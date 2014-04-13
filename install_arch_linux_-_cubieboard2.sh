#!/bin/bash

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

function report_critical {
	echo -e "\e[1;31;47m[    "$1"    ]\033[0m"
}

function report_ok_message {
	echo -e "\e[1;32;43m[    "$1"    ]\033[0m"
}

function report_info {
	echo -e "\e[1;34;47m[    "$1"    ]\033[0m"
}

function check_prev_cmd_result {	
	ret=$?
	if [ $ret -eq 0 ]
	then
		return 0
	else
		report_critical "!!! FAIL!!! : Operation failed with code "$ret
		exit $ret
	fi
	echo $ret 
}

echo "  ___           _       _     _  "                
echo " / _ \         | |     | |   (_)                  "
echo "/ /_\ \_ __ ___| |__   | |    _ _ __  _   ___  __ "
echo "|  _  | '__/ __| '_ \  | |   | | '_ \| | | \ \/ / "
echo "| | | | | | (__| | | | | |___| | | | | |_| |>  <  "
echo "\_| |_/_|  \___|_| |_| \_____/_|_| |_|\__,_/_/\_\ "
echo ""
report_critical "	Arch Linux Installer for Cubieboard2"
report_critical "		by Edward Sarkisyan rewritten by Toast"
echo ""
while [ true ]
do
	echo -ne "Your microSD card (for /dev/sdb enter just sdb) : "
	read dev
	devFull='/dev/'$dev
	if [ -e $devFull ]
	then	
		break
	else
		report_critical "Device "$devFull" does not exists in your system!"
	fi		
done

report_critical "WARNING: if device /dev/"$dev" does not exist in your"
report_critical "         or it is not your microSD card with 1 partitions"
report_critical "         this script can damage this device.         "

# Unmount
report_info "Unmouting partitions if they has been mounted"
umount /dev/$dev'1' 2> /dev/null
report_ok_message "Done"	

# Format

report_info "Formatting first /dev/"$dev"1 as ext4"
mkfs.ext4 /dev/$dev'1'
check_prev_cmd_result
report_ok_message "Done"

# Downloading

report_info "Downloading bootloader and rootsystem"
wget -c http://archlinuxarm.org/os/ArchLinuxARM-sun7i-latest.tar.gz
report_ok_message "Done"	

# Mount Points

report_info "Creating mount points and mounting partition"
mkdir -p /tmp/arch
mount /dev/$dev'1' /tmp/arch
check_prev_cmd_result
rm -rf /tmp/arch/*
check_prev_cmd_result
report_ok_message "Done"

# Unpacking

report_info "Extracting root filesystem. It can take a while... be patient..."
tar -zxf ArchLinuxARM-sun7i-latest.tar.gz -C /tmp/arch
report_ok_message "Done"

# Write Bootloader

report_info "Writing bootloader to " $dev

dd if=/tmp/arch/boot/u-boot-sunxi-with-spl.bin of=/dev/$dev bs=1024 seek=8
check_prev_cmd_result
report_ok_message "Done"

# Unmount

report_info "Unmounting all"
sync
umount /dev/$dev'1'

# Cleaning up

report_info "Cleaning up"
rm ArchLinuxARM-sun7i-latest.tar.gz
rm -r /tmp/arch/
report_ok_message "Done"

report_ok_message "microSD card is ready boot Arch Linux on your Cubieboard"
report_ok_message "Use the serial console or SSH to the IP address given to the board by your router. The default root password is 'root'."
