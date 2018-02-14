#!/bin/bash

PORT="/dev/ttyAMA0"
GPIO_RESET=4
GPIO_BUT=18
BAUDRATE=115200
DEFAULT_FIRMWARE="PiHat.bin"
BOOTLOADER="bootloader.bin"
FIRMWARE_ADDRESS="0x08002000"

GPIO_BEGIN_SEQ="$GPIO_BUT,-$GPIO_RESET,$GPIO_RESET"
GPIO_END_SEQ="-$GPIO_BUT,-$GPIO_RESET,$GPIO_RESET"
GPIO_SEQ="$GPIO_BEGIN_SEQ:$GPIO_END_SEQ"

FIRMWARE=$1


RETRIES=0

while ! [ -x "$(command -v stm32flash)" ] && [ "$RETRIES" == 0 ]; do
	if [ -x "$(command -v apt-get)" ]; then
		echo 'Installing stm32flash...'
		sudo apt-get install stm32flash
		RETRIES=$((RETRIES+1))
	else
		echo 'Error: stm32flash is not installed.' >&2
		exit 1
	fi
done

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


function gpio_reset {
   echo "0" > "$RESET_GPIO_PATH/value"
   sleep 1
   echo "1" > "$RESET_GPIO_PATH/value"
}

if [ -f /sys/class/gpio/export ]; then
   sleep 2
   echo $GPIO_RESET > /sys/class/gpio/export
   GPIO_RESET_PATH="/sys/class/gpio/gpio$GPIO_RESET"
   sudo chmod -R +x $GPIO_RESET_PATH
   echo "out" > "$GPIO_RESET_PATH/direction"
   gpio_reset
   sleep 5
   gpio_reset
   echo "in" > "$GPIO_RESET_PATH/direction"
   echo $GPIO_RESET > /sys/class/gpio/unexport
fi

echo "Flashing successful. Please restart your Device by replugging the power now. A normal reboot is not enough."

exit 0
