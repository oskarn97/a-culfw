esptool.py --port /dev/cu.SLAB_USBtoUART --baud 115200 write_flash -fs 4MB -ff 80m 0x00000 cun/boot_v1.7.bin 0x1000 cun/user1.bin 0x3FC000 cun/esp_init_data_default.bin 0x3FE000 cun/blank.bin
