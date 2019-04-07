#!/bin/bash

PORT="/dev/ttyAMA0"
GPIO_RESET_STM=4
GPIO_BUT_STM=18
GPIO_RESET_ESP=27
GPIO0_ESP=17
BAUDRATE=115200
DEFAULT_FIRMWARE="PiHat.bin"
BOOTLOADER="bootloader.bin"
FIRMWARE_ADDRESS="0x08002000"

GPIO_BEGIN_SEQ="$GPIO_BUT_STM,-$GPIO_RESET_STM,$GPIO_RESET_STM"
GPIO_END_SEQ="-$GPIO_BUT_STM,-$GPIO_RESET_STM,$GPIO_RESET_STM"
GPIO_SEQ="$GPIO_BEGIN_SEQ:$GPIO_END_SEQ"

FIRMWARE=$1


RETRIES=0

function gpio_reset_stm {
   gpio_value $GPIO_RESET_STM 0
   sleep 1
   gpio_value $GPIO_RESET_STM 1
}

function gpio_export {
   if [ -f /sys/class/gpio/export ]; then
	   echo "Exporting GPIO PIN $1"
       echo $1 > /sys/class/gpio/export
       GPIO_PATH="/sys/class/gpio/gpio$1"
       sudo chmod -R +x $GPIO_PATH
       echo "out" > "$GPIO_PATH/direction"
   fi
}

function gpio_unexport {
   if [ -f /sys/class/gpio/unexport ]; then
       GPIO_PATH="/sys/class/gpio/gpio$1"
       echo "in" > "$GPIO_PATH/direction"
       echo $1 > /sys/class/gpio/unexport
   fi
}

function gpio_value {
    echo "$2" > "/sys/class/gpio/gpio$1/value"
}

function apt_install {
	while ! [ -x "$(command -v $1)" ] && [ "$RETRIES" == 0 ]; do
		if [ -x "$(command -v apt-get)" ]; then
			echo 'Installing $1...'
			sudo apt-get install $1
			RETRIES=$((RETRIES+1))
		else
			echo 'Error: $1 is not installed.' >&2
			exit 1
		fi
	done
}

apt_install stm32flash

if [ "$1" == "cun" ]; then
   ESP_MODE=1
   gpio_export $GPIO_RESET_ESP
   sleep 1
   gpio_value $GPIO_RESET_ESP 0
fi

if [ "$1" == "-i" ]; then
   INTERACTIVE=1
   echo "Interactive mode"
   FIRMWARE=$2
fi

if [ "$1" == "-usb" ]; then
	DEFAULT_FIRMWARE="NeumannCUL.bin"
fi

if [ -z "$FIRMWARE" ] || [ ! -f $FIRMWARE ]; then
   FIRMWARE=$DEFAULT_FIRMWARE
fi

if [ "$1" == "-usb" ]; then
   dfu-util --verbose --device 1eaf:0003 --cfg 1 --alt 2 --download $FIRMWARE
   exit 0
fi


if [ ! -f $BOOTLOADER ]; then
    echo "Bootloader missing"
fi

function flashmode_instructions {
	if [ "$INTERACTIVE" == 1 ]; then
		echo "Enter flash mode by clicking the RESET button while holding down the BUT button. Release BUT afterwards and press enter."
		read
	fi
}

echo "Stopping fhem..."
sudo service fhem stop

echo "Removing read protection..."
flashmode_instructions
stm32flash -k -i $GPIO_SEQ -b $BAUDRATE $PORT

sleep 3

echo "Removing write protection..."
flashmode_instructions
stm32flash -u -i $GPIO_SEQ -b $BAUDRATE $PORT

sleep 3

echo "Flashing bootloader..."

RETRIES=0

while [ "$RETRIES" -lt 3 ]; do

flashmode_instructions
if stm32flash -i $GPIO_SEQ -b $BAUDRATE -w $BOOTLOADER $PORT; then
	printf "\n\nBootloader flashed successfully.\n\n"
	break
else
	printf "\n\nFlashing bootloader failed, trying again...\n"
	RETRIES=$((RETRIES+1))
fi

done

echo "Flashing firmware..."

RETRIES=0

while [ "$RETRIES" -lt 2 ]; do

if stm32flash -i $GPIO_SEQ -b $BAUDRATE -S $FIRMWARE_ADDRESS -w $FIRMWARE $PORT; then
	printf "\nFirmware flashed successfully.\n\n"
	break
else
	printf "\nFlashing firmware failed, trying again...\n"
	RETRIES=$((RETRIES+1))
fi

done

if [ "$RETRIES" == 2 ]; then
	echo 'Error: Flashing failed.' >&2
	exit 1
fi

echo "Enabling read protection..."
stm32flash -j -i $GPIO_SEQ -b $BAUDRATE $PORT


echo "Resetting device..."
sleep 1
gpio_export $GPIO_RESET_STM
gpio_reset_stm
gpio_unexport $GPIO_RESET_STM

if [ "$ESP_MODE" == 1 ]; then
   sleep 3
   gpio_export $GPIO_RESET_STM
   gpio_value $GPIO_RESET_STM 0
   gpio_value $GPIO_RESET_ESP 1
   sleep 1

   echo "Flashing ESP..."
   esptool.py --port $PORT --baud 115200 write_flash -fs 4MB -ff 80m 0x00000 cun/boot_v1.7.bin 0x1000 cun/user1.bin 0x3FC000 cun/esp_init_data_default.bin 0x3FE000 cun/blank.bin
   gpio_export $GPIO_RESET_ESP
   sleep 1
   gpio_value $GPIO_RESET_ESP 1
   sleep 1
   gpio_value $GPIO_RESET_ESP 0
   sleep 1
   gpio_unexport $GPIO_RESET_ESP
fi

echo "Starting fhem..."
sudo service fhem start

echo "Flashing successful. Please restart your Device by replugging the power now. A normal reboot is not enough."

exit 0
