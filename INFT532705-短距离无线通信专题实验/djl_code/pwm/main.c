//*****************************************************************************
// CC3200 LED PWM - Debounced Mode
//*****************************************************************************
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Driverlib includes
#include "hw_types.h"
#include "hw_ints.h"
#include "hw_memmap.h"
#include "interrupt.h"
#include "rom.h"
#include "rom_map.h"
#include "timer.h"
#include "prcm.h"
#include "uart.h"
#include "gpio.h"
#include "pinmux.h"
#include "uart_if.h"
#include "utils.h"
#include "pin.h"

//*****************************************************************************
// 宏定义
//*****************************************************************************
#define SYS_CLK             80000000
#define PWM_FREQ            2000
#define MAX_CMD_LEN         8

// 硬件定义
#define LED_RED_PIN         PIN_64
#define LED_ORG_PIN         PIN_01
#define LED_GRN_PIN         PIN_02
#define LED_GPIO_BASE       GPIOA1_BASE
#define LED_GPIO_MASK       (GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3)

#define LED_RED_BASE        TIMERA2_BASE
#define LED_RED_TIMER       TIMER_B
#define LED_ORG_BASE        TIMERA3_BASE
#define LED_ORG_TIMER       TIMER_A
#define LED_GRN_BASE        TIMERA3_BASE
#define LED_GRN_TIMER       TIMER_B

#define SW2_GPIO_PIN        GPIO_PIN_6  // GPIO 22 on Porta2
#define SW3_GPIO_PIN        GPIO_PIN_5  // GPIO 13 on Porta1

//*****************************************************************************
// 全局变量
//*****************************************************************************
volatile int g_iDutyCycle = 50;
volatile int g_iStepSize  = 10;
volatile tBoolean g_bUpdatePWM = false;

char g_cCmdBuffer[MAX_CMD_LEN];
volatile unsigned char g_ucCmdIdx = 0;

#if defined(ccs)
extern void (* const g_pfnVectors[])(void);
#endif

// 函数声明
void UpdatePWMConfiguration();
void UARTIntHandler();
void GPIOIntHandler();
void InitPWM();

//*****************************************************************************
// 更新 PWM 配置 (保留 GPIO 切换逻辑以解决 0% 问题)
//*****************************************************************************
void UpdatePWMConfiguration()
{
    unsigned long ulReload = SYS_CLK / PWM_FREQ;

    if (g_iDutyCycle <= 0)
    {
        MAP_PinTypeGPIO(LED_RED_PIN, PIN_MODE_0, false);
        MAP_PinTypeGPIO(LED_ORG_PIN, PIN_MODE_0, false);
        MAP_PinTypeGPIO(LED_GRN_PIN, PIN_MODE_0, false);
        MAP_GPIOPinWrite(LED_GPIO_BASE, LED_GPIO_MASK, 0);
    }
    else if (g_iDutyCycle >= 100)
    {
        MAP_PinTypeGPIO(LED_RED_PIN, PIN_MODE_0, false);
        MAP_PinTypeGPIO(LED_ORG_PIN, PIN_MODE_0, false);
        MAP_PinTypeGPIO(LED_GRN_PIN, PIN_MODE_0, false);
        MAP_GPIOPinWrite(LED_GPIO_BASE, LED_GPIO_MASK, LED_GPIO_MASK);
    }
    else
    {
        MAP_PinTypeTimer(LED_RED_PIN, PIN_MODE_3);
        MAP_PinTypeTimer(LED_ORG_PIN, PIN_MODE_3);
        MAP_PinTypeTimer(LED_GRN_PIN, PIN_MODE_3);

        unsigned long ulMatch = (ulReload * (100 - g_iDutyCycle)) / 100;
        MAP_TimerMatchSet(LED_RED_BASE, LED_RED_TIMER, ulMatch);
        MAP_TimerMatchSet(LED_ORG_BASE, LED_ORG_TIMER, ulMatch);
        MAP_TimerMatchSet(LED_GRN_BASE, LED_GRN_TIMER, ulMatch);
    }
}

//*****************************************************************************
// 串口中断处理
//*****************************************************************************
void UARTIntHandler()
{
    unsigned long ulStatus = MAP_UARTIntStatus(UARTA0_BASE, true);
    MAP_UARTIntClear(UARTA0_BASE, ulStatus);

    while(MAP_UARTCharsAvail(UARTA0_BASE))
    {
        char cChar = MAP_UARTCharGetNonBlocking(UARTA0_BASE);
        if(cChar == 'n')
        {
            g_cCmdBuffer[g_ucCmdIdx] = '\0';
            if(g_ucCmdIdx > 0)
            {
                if(g_cCmdBuffer[0] == 's')
                {
                    g_iStepSize = atoi(&g_cCmdBuffer[1]);
                    if(g_iStepSize < 1) g_iStepSize = 1;
                }
                else
                {
                    g_iDutyCycle = atoi(g_cCmdBuffer);
                    if(g_iDutyCycle > 100) g_iDutyCycle = 100;
                    if(g_iDutyCycle < 0)   g_iDutyCycle = 0;
                }
                g_bUpdatePWM = true;
            }
            g_ucCmdIdx = 0;
        }
        else if(g_ucCmdIdx < MAX_CMD_LEN - 1)
        {
            g_cCmdBuffer[g_ucCmdIdx++] = cChar;
        }
    }
}

//*****************************************************************************
// GPIO 中断：增加软件消抖逻辑
//*****************************************************************************
void GPIOIntHandler()
{
    unsigned long ulIntStatus2 = MAP_GPIOIntStatus(GPIOA2_BASE, true);
    unsigned long ulIntStatus1 = MAP_GPIOIntStatus(GPIOA1_BASE, true);

    // 1. 立即清除中断标志，防止中断嵌套堆积
    MAP_GPIOIntClear(GPIOA2_BASE, ulIntStatus2);
    MAP_GPIOIntClear(GPIOA1_BASE, ulIntStatus1);

    // 2. 软件消抖延时 (约 20ms)
    // CC3200 80MHz 下，MAP_UtilsDelay(1) 约为 3 个周期，800000 约等于 30ms
    MAP_UtilsDelay(900000);

    // 3. 再次确认按键状态 (低电平表示确实按下了)

    // 检查 SW2 (GPIO 22)
    if(ulIntStatus2 & SW2_GPIO_PIN)
    {
        if(MAP_GPIOPinRead(GPIOA2_BASE, SW2_GPIO_PIN) == 0) // 确认依然按下
        {
            g_iDutyCycle += g_iStepSize;
            if(g_iDutyCycle > 100) g_iDutyCycle = 100;

            Report("%03d\n\r", g_iDutyCycle);
            g_bUpdatePWM = true;
        }
    }

    // 检查 SW3 (GPIO 13)
    if(ulIntStatus1 & SW3_GPIO_PIN)
    {
        if(MAP_GPIOPinRead(GPIOA1_BASE, SW3_GPIO_PIN) == 0) // 确认依然按下
        {
            g_iDutyCycle -= g_iStepSize;
            if(g_iDutyCycle < 0) g_iDutyCycle = 0;

            Report("%03d\n\r", g_iDutyCycle);
            g_bUpdatePWM = true;
        }
    }
}

//*****************************************************************************
// 初始化与主循环
//*****************************************************************************
void InitPWM()
{
    MAP_PRCMPeripheralClkEnable(PRCM_TIMERA2, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_TIMERA3, PRCM_RUN_MODE_CLK);
    unsigned long ulReload = SYS_CLK / PWM_FREQ;

    MAP_TimerConfigure(LED_RED_BASE, (TIMER_CFG_SPLIT_PAIR | TIMER_CFG_B_PWM));
    MAP_TimerLoadSet(LED_RED_BASE, LED_RED_TIMER, ulReload);
    MAP_TimerEnable(LED_RED_BASE, LED_RED_TIMER);

    MAP_TimerConfigure(LED_ORG_BASE, (TIMER_CFG_SPLIT_PAIR | TIMER_CFG_A_PWM | TIMER_CFG_B_PWM));
    MAP_TimerLoadSet(LED_ORG_BASE, LED_ORG_TIMER, ulReload);
    MAP_TimerLoadSet(LED_GRN_BASE, LED_GRN_TIMER, ulReload);
    MAP_TimerEnable(LED_ORG_BASE, LED_ORG_TIMER);
    MAP_TimerEnable(LED_GRN_BASE, LED_GRN_TIMER);
}

void main()
{
    MAP_IntVTableBaseSet((unsigned long)&g_pfnVectors[0]);
    MAP_IntMasterEnable();
    PRCMCC3200MCUInit();

    PinMuxConfig();
    InitTerm();

    InitPWM();
    UpdatePWMConfiguration();

    // 配置 SW2 (Port A2)
    MAP_GPIOIntTypeSet(GPIOA2_BASE, SW2_GPIO_PIN, GPIO_FALLING_EDGE);
    MAP_GPIOIntRegister(GPIOA2_BASE, GPIOIntHandler);
    MAP_GPIOIntEnable(GPIOA2_BASE, SW2_GPIO_PIN);

    // 配置 SW3 (Port A1)
    MAP_GPIOIntTypeSet(GPIOA1_BASE, SW3_GPIO_PIN, GPIO_FALLING_EDGE);
    MAP_GPIOIntRegister(GPIOA1_BASE, GPIOIntHandler);
    MAP_GPIOIntEnable(GPIOA1_BASE, SW3_GPIO_PIN);

    MAP_UARTIntRegister(UARTA0_BASE, UARTIntHandler);
    MAP_UARTIntEnable(UARTA0_BASE, UART_INT_RX | UART_INT_RT);

    Report("System Ready with Debouncing. SW2/SW3 fixed.\n\r");

    while(1)
    {
        if(g_bUpdatePWM)
        {
            UpdatePWMConfiguration();
            g_bUpdatePWM = false;
        }
    }
}
