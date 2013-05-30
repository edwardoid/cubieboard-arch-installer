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

echo "  _____      _     _      _                         _"
echo " / ____|    | |   (_)    | |Arch Linux Intaller for| |"
echo "| |    _   _| |__  _  ___| |__   ___   __ _ _ __ __| |"
echo "| |   | | | | '_ \| |/ _ \ '_ \ / _ \ / _\` | '__/ _\` |"
echo "| |___| |_| | |_) | |  __/ |_) | (_) | (_| | | | (_| |"
echo " \_____\__,_|_.__/|_|\___|_.__/ \___/ \__,_|_|  \__,_|"
echo ""
report_critical "             by Edward Sarkisyan"
echo ""
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


while [ true ]
do
	echo -ne "Your Cubieboard ram(512 or 1024): "
	read ram

	if [ $ram -eq 512 ] || [ $ram -eq 1024 ]
	then	
		break;
	else
		report_critical "Acceptable number is 512 or 1024 only! Enter correct number!"
	fi		
done

report_critical "WARNING: if device /dev/"$dev" does not exist in your"
report_critical "         or it is not your microSD card with 2 partitions"
report_critical "         this script can damage this device.         "


###############################################################################


report_info "Unmouting partitions if they has been mounted"
umount /dev/$dev'1' 2> /dev/null
umount /dev/$dev'2' 2> /dev/null
report_ok_message "Done"	

###############################################################################

report_info "Formatting first /dev/"$dev"1 as FAT16"
mkfs.msdos -F 16 -n boot /dev/$dev'1'
check_prev_cmd_result
report_ok_message "Done"

###############################################################################

report_info "Downloading bootloader"
wget -c https://www.dropbox.com/s/sa99vmxzkjypf40/cubieboard.tar.gz
report_ok_message "Done"	

###############################################################################

report_info "Extractiong bootloader files"
tar xzf cubieboard.tar.gz
report_ok_message "Done"

###############################################################################

report_info "Writing bootloader to " $dev

dd if=hw/$ram/sunxi-spl.bin of=/dev/$dev bs=1024 seek=8
check_prev_cmd_result
dd if=hw/$ram/u-boot.bin of=/dev/$dev bs=1024 seek=32
check_prev_cmd_result
report_ok_message "Done"

###############################################################################

report_info "Creating mount points and mounting partition"
mkdir -p /tmp/boot
mkdir -p /tmp/arch
mount /dev/$dev'1' /tmp/boot
check_prev_cmd_result
mount /dev/$dev'2' /tmp/arch
check_prev_cmd_result
rm -rf /tmp/arch/*
check_prev_cmd_result
report_ok_message "Done"

###############################################################################

report_info "Downloading root filesystem"
wget -c http://archlinuxarm.org/os/ArchLinuxARM-sun4i-latest.tar.gz
check_prev_cmd_result
report_ok_message "Done"

###############################################################################

report_info "Extracting root filesystem. It can take a while... be patient..."
tar -zxf ArchLinuxARM-sun4i-latest.tar.gz -C /tmp/arch
report_ok_message "Done"

###############################################################################

report_info "Copying boot files"
cp /tmp/arch/boot/uImage /tmp/boot/uImage
check_prev_cmd_result

infix=""

if [ $ram -eq 512 ]
then
	infix="_512"
fi

cp hw/$ram/cubieboard$infix.bin /tmp/boot/
check_prev_cmd_result
cp hw/$ram/uEnv.txt /tmp/boot/uEnv.txt
check_prev_cmd_result
report_ok_message "Done"	

###############################################################################

report_info "Unmounting all"
sync
umount /dev/$dev'1'
umount /dev/$dev'2'
report_ok_message "microSD card is ready boot Arch Linux on your Cubieboard"

###############################################################################

report_ok_message "Good luck! [ Edward Sarkisyan edward.sarkisyan@gmail.com ]"
