#include "pinmux.h"
#include "hw_types.h"
#include "hw_memmap.h"
#include "pin.h"
#include "rom.h"
#include "rom_map.h"
#include "prcm.h"

void PinMuxConfig(void)
{
    // 使能外设时钟
    MAP_PRCMPeripheralClkEnable(PRCM_UARTA0, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_I2CA0, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA1, PRCM_RUN_MODE_CLK); // 用于 LED 所在的 GPIO 组

    // UART0 引脚配置 (TX: 55, RX: 57)
    MAP_PinTypeUART(PIN_55, PIN_MODE_3);
    MAP_PinTypeUART(PIN_57, PIN_MODE_3);

    // I2C0 引脚配置 (SCL: 01, SDA: 02)
    // 注意：LaunchPad 上通常有跳线帽决定 01/02 引脚是连 LED 还是 I2C。
    // 使用传感器时请确保跳线帽连接到 I2C 一侧。
    MAP_PinTypeI2C(PIN_01, PIN_MODE_1);
    MAP_PinTypeI2C(PIN_02, PIN_MODE_1);

    // PWM 配置: 红色 LED (PIN_64) 映射到 Timer A2B (Mode 3)
    MAP_PinTypeTimer(PIN_64, PIN_MODE_3);
}
