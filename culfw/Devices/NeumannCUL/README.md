# Firmware für den Neumann CUL / Pi Hat

## benötigte Tools

- Pi Hat: stm32flash : https://sourceforge.net/p/stm32flash/wiki/Home
- CUL: dfu-util: http://dfu-util.sourceforge.net/

## a-culfw flashen

#### Pi Hat < V2.2
`./flash.sh -i`

#### Pi Hat >= V2.2
`./flash.sh`

#### Neumann CUL
Über USB anschließen und die Reset-Taste drücken. Während die LED schnell blinkt, folgendes Command ausführen:

`./flash.sh -usb`
