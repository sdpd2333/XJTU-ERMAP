//*****************************************************************************
// pinmux.c
//*****************************************************************************

#include "pinmux.h"
#include "hw_types.h"
#include "hw_memmap.h"
#include "hw_gpio.h"
#include "pin.h"
#include "rom.h"
#include "rom_map.h"
#include "gpio.h"
#include "prcm.h"

//*****************************************************************************
void PinMuxConfig(void)
{
    // 使能外设时钟
    MAP_PRCMPeripheralClkEnable(PRCM_UARTA0, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA1, PRCM_RUN_MODE_CLK); // 用于 RED LED 和 SW2
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA2, PRCM_RUN_MODE_CLK); // 用于 ORANGE LED
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA3, PRCM_RUN_MODE_CLK); // 用于 SW3
    MAP_PRCMPeripheralClkEnable(PRCM_I2CA0, PRCM_RUN_MODE_CLK);  // 用于 I2C 传感器

    // 配置 UART0
    // PIN_55 -> UART0_TX, PIN_57 -> UART0_RX
    MAP_PinTypeUART(PIN_55, PIN_MODE_3);
    MAP_PinTypeUART(PIN_57, PIN_MODE_3);

    // 配置 I2C
    // PIN_01 -> I2C_SCL, PIN_02 -> I2C_SDA
    MAP_PinTypeI2C(PIN_01, PIN_MODE_1);
    MAP_PinTypeI2C(PIN_02, PIN_MODE_1);

    // 配置按键 SW2 (Pin 15 -> GPIO22 对应 GPIOA2_BASE 的 0x40)
    // 设为输入模式，供 OOBTask 循环查询
    MAP_PinTypeGPIO(PIN_15, PIN_MODE_0, false);
    MAP_GPIODirModeSet(GPIOA2_BASE, 0x40, GPIO_DIR_MODE_IN);
    MAP_PinConfigSet(PIN_15,PIN_STRENGTH_2MA | PIN_STRENGTH_4MA,PIN_TYPE_STD_PD);

    // 配置按键 SW3 (Pin 04 -> GPIO13 对应 GPIOA1_BASE 的 0x20)
    // 设为输入模式，供 OOBTask 循环查询
    MAP_PinTypeGPIO(PIN_04, PIN_MODE_0, false);
    MAP_GPIODirModeSet(GPIOA1_BASE, 0x20, GPIO_DIR_MODE_IN);
    MAP_PinConfigSet(PIN_04,PIN_STRENGTH_2MA | PIN_STRENGTH_4MA,PIN_TYPE_STD_PD);

    // 配置 Red LED (Pin 64 -> GPIO9 对应 GPIOA1_BASE 的 0x02)
    // 设为输出模式。用于指示 AP/STA 模式切换状态
    MAP_PinTypeGPIO(PIN_64, PIN_MODE_0, false);
    MAP_GPIODirModeSet(GPIOA1_BASE, 0x02, GPIO_DIR_MODE_OUT);
}
