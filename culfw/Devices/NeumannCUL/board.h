#ifndef BOARD_H 
#define BOARD_H

#define _BV(a) (1<<(a))
#define bit_is_set(sfr, bit) ((sfr) & _BV(bit))

#define LONG_PULSE

#define TTY_BUFSIZE          256      // RAM: TTY_BUFSIZE*4

#if defined PiHat
#define BOARD_NAME          "Neumann CUL Pi Hat"
#define BOARD_ID_STR        "Neumann CUL Pi Hat"
#else
#define BOARD_NAME          "Neumann CUL"
#define BOARD_ID_STR        "Neumann CUL"
#endif

#define USBD_MANUFACTURER "oskar.pw"

#define HAS_UART                1

#define HAS_MULTI_CC        4
#define NUM_SLOWRF          3
#define USE_HW_AUTODETECT

#define ARM

#define HAS_USB
//#define USB_FIX_SERIAL          "012345"
#define CDC_COUNT               3
#define CDC_BAUD_RATE           115200
#define UART_BAUD_RATE          38400
#define USB_IsConnected		      (CDC_isConnected(0))
#define HAS_XRAM
#define USE_RF_MODE
#define USE_HAL
#define HAS_ONEWIRE             10        // OneWire Support

#define HAS_FHT_80b
#define HAS_FHT_8v
//#define HAS_RF_ROUTER
#define HAS_CC1101_RX_PLL_LOCK_CHECK_TASK_WAIT
#define HAS_CC1101_PLL_LOCK_CHECK_MSG
#define HAS_CC1101_PLL_LOCK_CHECK_MSG_SW

#define FHTBUF_SIZE          174
#define RCV_BUCKETS            4      //                 RAM: 25b * bucket
//#define RFR_DEBUG
#define FULL_CC1100_PA
#define HAS_RAWSEND
#define HAS_FASTRF
#define HAS_ASKSIN
#define HAS_ASKSIN_FUP
#define HAS_KOPP_FC
#define HAS_MORITZ
#define HAS_RWE
#define HAS_ESA
#define HAS_HMS
#define HAS_TX3
#define HAS_INTERTECHNO
#define HAS_UNIROLL
#define HAS_HOERMANN
#define HAS_HOERMANN_SEND
#define HAS_SOMFY_RTS
#define HAS_MAICO
#define HAS_RFNATIVE
#define HAS_ZWAVE
#define HAS_MBUS
#define HAS_RFNATIVE
#define LACROSSE_HMS_EMU

#define _433MHZ

#  if defined(_433MHZ)
#    define HAS_TCM97001
#    define HAS_IT
#    define HAS_HOMEEASY
#    define HAS_BELFOX
#    define HAS_MANCHESTER
#    define HAS_REVOLT
#  endif

//PORT 0
#define CC1100_0_CS_PIN		  4
#define CC1100_0_CS_BASE	  GPIOA
#define CC1100_0_OUT_PIN    1
#define CC1100_0_OUT_BASE   GPIOA
#define CC1100_0_IN_PIN     0
#define CC1100_0_IN_BASE    GPIOA

//PORT 1
#define CC1100_1_CS_PIN		  15
#define CC1100_1_CS_BASE	  GPIOC
#define CC1100_1_OUT_PIN    5
#define CC1100_1_OUT_BASE   GPIOB
#define CC1100_1_IN_PIN     4
#define CC1100_1_IN_BASE	  GPIOB

//PORT 2
#define CC1100_2_CS_PIN     7
#define CC1100_2_CS_BASE    GPIOB
#define CC1100_2_OUT_PIN    14
#define CC1100_2_OUT_BASE   GPIOC
#define CC1100_2_IN_PIN     6
#define CC1100_2_IN_BASE    GPIOB

//PORT 3
#define CC1100_3_CS_PIN     0
#define CC1100_3_CS_BASE    GPIOB
#define CC1100_3_OUT_PIN    0
#define CC1100_3_OUT_BASE   NULL
#define CC1100_3_IN_PIN     13
#define CC1100_3_IN_BASE    GPIOC

#define CCCOUNT             4
#define CCTRANSCEIVERS    {\
                          { {CC1100_0_OUT_BASE, CC1100_0_CS_BASE, CC1100_0_IN_BASE},\
                            {CC1100_0_OUT_PIN,  CC1100_0_CS_PIN,  CC1100_0_IN_PIN}  },\
                          { {CC1100_1_OUT_BASE, CC1100_1_CS_BASE, CC1100_1_IN_BASE},\
                            {CC1100_1_OUT_PIN,  CC1100_1_CS_PIN,  CC1100_1_IN_PIN}  },\
                          { {CC1100_2_OUT_BASE, CC1100_2_CS_BASE, CC1100_2_IN_BASE},\
                            {CC1100_2_OUT_PIN,  CC1100_2_CS_PIN,  CC1100_2_IN_PIN}  },\
                          { {CC1100_3_OUT_BASE, CC1100_3_CS_BASE, CC1100_3_IN_BASE},\
                            {CC1100_3_OUT_PIN,  CC1100_3_CS_PIN,  CC1100_3_IN_PIN}  },\
                          }

//TWI
#define TWI_SCL_PIN       CC1100_2_IN_PIN
#define TWI_SCL_BASE      CC1100_2_IN_BASE
#define TWI_SDA_PIN       CC1100_2_CS_PIN
#define TWI_SDA_BASE      CC1100_2_CS_BASE

#ifndef CDC_COUNT
#define CDC_COUNT 1
#endif
//------------------------------------------------------------------------------
//         Headers
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//         Pin Definitions
//------------------------------------------------------------------------------
#define LED_GPIO              GPIOB
#define LED_PIN               1

//#define LED2_GPIO             GPIOB
//#define LED2_PIN              0

#define USBD_CONNECT_PORT     GPIOB
#define USBD_CONNECT_PIN      9

#endif //#ifndef BOARD_H

