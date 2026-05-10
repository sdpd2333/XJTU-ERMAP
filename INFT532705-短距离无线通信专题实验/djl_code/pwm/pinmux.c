//*****************************************************************************
// pinmux.c
//
// 针对 LED 亮度控制任务的引脚复用配置
//*****************************************************************************

#include "pinmux.h"
#include "hw_types.h"
#include "hw_memmap.h"
#include "hw_gpio.h"
#include "pin.h"
#include "gpio.h"
#include "rom.h"
#include "rom_map.h"
#include "prcm.h"

//*****************************************************************************
void PinMuxConfig(void)
{
    //
    // 1. 使能外设时钟
    //
    MAP_PRCMPeripheralClkEnable(PRCM_UARTA0, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA0, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA1, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA2, PRCM_RUN_MODE_CLK);

    //
    // 2. 配置 UART0 引脚 (用于连接 PC)
    //
    // Pin 55 -> UART0_TX
    MAP_PinTypeUART(PIN_55, PIN_MODE_3);
    // Pin 57 -> UART0_RX
    MAP_PinTypeUART(PIN_57, PIN_MODE_3);

    //
    // 3. 配置 PWM 引脚 (红色 LED)
    // 对应 TIMERA2_BASE, TIMER_B (PWM_05)
    //
    // Pin 64 -> GPIO 09 (Timer PWM 模式)
    MAP_PinTypeTimer(PIN_64, PIN_MODE_3);
    MAP_PinTypeTimer(PIN_01, PIN_MODE_3);
    MAP_PinTypeTimer(PIN_02, PIN_MODE_3);

    //
    // 4. 配置按键 SW2 (GPIO 22)
    //
    // Pin 15 -> GPIO 22
    MAP_PinTypeGPIO(PIN_15, PIN_MODE_0, false);
    MAP_GPIODirModeSet(GPIOA2_BASE, 0x40, GPIO_DIR_MODE_IN); // GPIO_PIN_6
    // 开启内部上拉电阻
    MAP_PinConfigSet(PIN_15, PIN_STRENGTH_2MA, PIN_TYPE_STD_PU);

    //
    // 5. 配置按键 SW3 (GPIO 13)
    //
    // Pin 04 -> GPIO 13
    MAP_PinTypeGPIO(PIN_04, PIN_MODE_0, false);
    MAP_GPIODirModeSet(GPIOA1_BASE, 0x20, GPIO_DIR_MODE_IN); // GPIO_PIN_5
    // 开启内部上拉电阻
    MAP_PinConfigSet(PIN_04, PIN_STRENGTH_2MA, PIN_TYPE_STD_PU);
}
