#include <stdio.h>
#include "hw_types.h"
#include "hw_ints.h"
#include "hw_memmap.h"
#include "hw_common_reg.h"
#include "interrupt.h"
#include "hw_apps_rcm.h"
#include "prcm.h"
#include "rom.h"
#include "rom_map.h"
#include "gpio.h"
#include "utils.h"
#include "gpio_if.h"
#include "pinmux.h"

volatile int g_bLedRunning = 0;  // 0: 停止, 1: 运行
volatile int g_bDirection = 1;    // 1: 正向 (红-橙-绿), 0: 反向 (绿-橙-红)

#if defined(ccs)
extern void (* const g_pfnVectors[])(void);
#endif
#if defined(ewarm)
extern uVectorEntry __vector_table;
#endif

// SW3 (GPIO 13) 中断处理 - 切换运行/停止
void GPIOA1IntHandler(void)
{
    unsigned long ulStatus;
    // 获取并清除中断状态
    ulStatus = MAP_GPIOIntStatus(GPIOA1_BASE, true);
    MAP_GPIOIntClear(GPIOA1_BASE, ulStatus);

    if(ulStatus & 0x20) // 检查是否是 GPIO 13 触发
    {
        g_bLedRunning = !g_bLedRunning;
        if(!g_bLedRunning)
        {
            GPIO_IF_LedOff(MCU_ALL_LED_IND); // 停止时熄灭所有灯
        }
    }
}

// SW2 (GPIO 22) 中断处理 - 切换方向
void GPIOA2IntHandler(void)
{
    unsigned long ulStatus;
    // 获取并清除中断状态
    ulStatus = MAP_GPIOIntStatus(GPIOA2_BASE, true);
    MAP_GPIOIntClear(GPIOA2_BASE, ulStatus);

    if(ulStatus & 0x40) // 检查是否是 GPIO 22 触发
    {
        g_bDirection = !g_bDirection;
    }
}

// 封装单灯闪烁逻辑，便于在循环中检查状态
void SafeLedToggle(unsigned int led)
{
    if(g_bLedRunning)
    {
        GPIO_IF_LedOn(led);
        MAP_UtilsDelay(8000000);
        GPIO_IF_LedOff(led);
    }
}

void LEDBlinkyRoutine()
{
    while(1)
    {
        if(g_bLedRunning)
        {
            if(g_bDirection) // 正向：红 -> 橙 -> 绿
            {
                SafeLedToggle(MCU_RED_LED_GPIO);
                SafeLedToggle(MCU_ORANGE_LED_GPIO);
                SafeLedToggle(MCU_GREEN_LED_GPIO);
            }
            else // 反向：绿 -> 橙 -> 红
            {
                SafeLedToggle(MCU_GREEN_LED_GPIO);
                SafeLedToggle(MCU_ORANGE_LED_GPIO);
                SafeLedToggle(MCU_RED_LED_GPIO);
            }
        }
    }
}

static void BoardInit(void)
{
#ifndef USE_TIRTOS
#if defined(ccs)
    MAP_IntVTableBaseSet((unsigned long)&g_pfnVectors[0]);
#endif
#if defined(ewarm)
    MAP_IntVTableBaseSet((unsigned long)&__vector_table);
#endif
#endif
    MAP_IntMasterEnable();
    MAP_IntEnable(FAULT_SYSTICK);
    PRCMCC3200MCUInit();
}

int main()
{
    BoardInit();
    PinMuxConfig();
    GPIO_IF_LedConfigure(LED1|LED2|LED3);

    // --- 配置 SW3 (GPIO 13) 中断 ---
    MAP_GPIOIntRegister(GPIOA1_BASE, GPIOA1IntHandler);
    MAP_GPIOIntTypeSet(GPIOA1_BASE, 0x20, GPIO_FALLING_EDGE); // 下降沿触发
    MAP_GPIOIntEnable(GPIOA1_BASE, 0x20);

    // --- 配置 SW2 (GPIO 22) 中断 ---
    MAP_GPIOIntRegister(GPIOA2_BASE, GPIOA2IntHandler);
    MAP_GPIOIntTypeSet(GPIOA2_BASE, 0x40, GPIO_FALLING_EDGE); // 下降沿触发
    MAP_GPIOIntEnable(GPIOA2_BASE, 0x40);

    GPIO_IF_LedOff(MCU_ALL_LED_IND);

    LEDBlinkyRoutine();
    return 0;
}
