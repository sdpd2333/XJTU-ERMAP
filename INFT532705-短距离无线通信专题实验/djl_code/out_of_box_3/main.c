//*****************************************************************************
// CC3200 传感器集成应用 - 扩展版
// 新增功能：
// ① 倾斜方向判断
// ② 输出 m/s^2 加速度
// ③ 三个 LED 对应 XYZ 加速度
//*****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Driverlib
#include "hw_types.h"
#include "hw_ints.h"
#include "hw_memmap.h"
#include "rom.h"
#include "rom_map.h"
#include "utils.h"
#include "prcm.h"
#include "uart.h"
#include "timer.h"
#include "pin.h"

// 接口
#include "uart_if.h"
#include "i2c_if.h"
#include "pinmux.h"
#include "tmp006drv.h"
#include "bma222drv.h"

//*****************************************************************************
// 宏定义
//*****************************************************************************
#define SYS_CLK     80000000
#define PWM_FREQ    2000
#define TEMP_THRESHOLD   30.0
#define G_VALUE     9.8f     // 重力加速度

// LED（三个方向）
#define LED_RED_PIN     PIN_64   // X轴
#define LED_BLUE_PIN    PIN_01   // Y轴
#define LED_GREEN_PIN   PIN_02   // Z轴

#define LED_RED_BASE    TIMERA2_BASE
#define LED_BLUE_BASE   TIMERA1_BASE
#define LED_GREEN_BASE  TIMERA0_BASE

#define LED_RED_TIMER   TIMER_B
#define LED_BLUE_TIMER  TIMER_A
#define LED_GREEN_TIMER TIMER_A

#if defined(ccs)
extern void (* const g_pfnVectors[])(void);
#endif
//*****************************************************************************
// PWM 初始化
//*****************************************************************************
void InitPWM()
{
    unsigned long ulReload = SYS_CLK / PWM_FREQ;

    MAP_PRCMPeripheralClkEnable(PRCM_TIMERA2, PRCM_RUN_MODE_CLK);
    MAP_TimerConfigure(LED_RED_BASE, TIMER_CFG_SPLIT_PAIR | TIMER_CFG_B_PWM);
    MAP_TimerLoadSet(LED_RED_BASE, LED_RED_TIMER, ulReload);
    MAP_TimerEnable(LED_RED_BASE, LED_RED_TIMER);

}

//*****************************************************************************
// 设置 LED 亮度
//*****************************************************************************
void SetPWMDuty(unsigned long base, unsigned long timer, int duty)
{
    unsigned long ulReload = SYS_CLK / PWM_FREQ;

    if(duty < 0) duty = 0;
    if(duty > 100) duty = 100;

    unsigned long match = (ulReload * (100 - duty)) / 100;
    MAP_TimerMatchSet(base, timer, match);
}

//*****************************************************************************
// 主函数
//*****************************************************************************
void main()
{
    signed char cAccX, cAccY, cAccZ;
    float ax, ay, az;
    float fTemp;
    static float last_ax = 0, last_ay = 0, last_az = 0;
    int led_state = 0;  // LED 闪烁状态

    MAP_IntVTableBaseSet((unsigned long)&g_pfnVectors[0]);
    MAP_IntMasterEnable();
    PRCMCC3200MCUInit();

    PinMuxConfig();
    InitTerm();
    I2C_IF_Open(I2C_MASTER_MODE_FST);

    InitPWM();

    while(1)
    {
        if(BMA222ReadNew(&cAccX, &cAccY, &cAccZ) == 0)
        {
            ax = (cAccX / 64.0f) * G_VALUE;
            ay = (cAccY / 64.0f) * G_VALUE;
            az = (cAccZ / 64.0f) * G_VALUE;
            char *direction = "稳定";
            if(cAccZ > 0)
            {
                if(abs(cAccX) > abs(cAccY))
                {
                    if(cAccX > 20) direction = "向右倾斜";
                    else if(cAccX < -20) direction = "向左倾斜";
                }
                else
                {
                    if(cAccY > 20) direction = "向前倾斜";
                    else if(cAccY < -20) direction = "向后倾斜";
                }
            }
            else if(cAccZ < -50)
            {
                direction = "翻覆";
            }

            //计算 XYZ 轴的加速度突变（当前值与上一次值的差值绝对值之和）
            float mutation = fabsf(ax - last_ax) + fabsf(ay - last_ay) + fabsf(az - last_az);

            // 将突变量映射为亮度 (假设变化量达到 10m/s^2 时亮度为 100%)
            int dutyRed = (int)(mutation * 10);
            if(dutyRed > 100) dutyRed = 100;

            // 更新历史数据
            last_ax = ax; last_ay = ay; last_az = az;


            if(TMP006DrvGetTemp(&fTemp) == 0)
            {
                  fTemp = (fTemp -32) / 1.8;
                  Report("当前温度: %.2f C", fTemp);
                  if(fTemp > TEMP_THRESHOLD)
                  {
                       Report(" [!!! 高温报警 !!!]");
                  }
                  Report("\n\r");
            }
            // ③ 实现闪烁：根据 led_state 切换占空比
            led_state = !led_state;
            if(led_state)
            {
                  SetPWMDuty(LED_RED_BASE, LED_RED_TIMER, dutyRed);
            }
            else
            {
                  SetPWMDuty(LED_RED_BASE, LED_RED_TIMER, 0); // 熄灭
            }

            //==============================
            // 串口输出
            //==============================
            Report("加速度(m/s^2): X=%.2f Y=%.2f Z=%.2f\n\r", ax, ay, az);
            Report("倾斜方向: %s\n\r", direction);
            Report("--------------------------------\n\r");
        }
        // ④ 温度影响闪烁频率：延时与温度成反比
        // 基准延时：80,000,000 为 1秒。我们使用 (200,000,000 / 温度) 来动态调整
        // 温度越高，delay_val 越小，循环越快，频率越高。
        float temp_calc = (fTemp < 10.0f) ? 10.0f : fTemp; // 防止温度过低导致延时过大或除零
        unsigned long delay_val;
        if(fTemp <= 35)
        {
            delay_val = (unsigned long)(200000000.0f / temp_calc);
        }
        else
        {
            delay_val = 10000000;
        }

        MAP_UtilsDelay(delay_val);
    }
}

//*****************************************************************************
// FreeRTOS Hook
//*****************************************************************************
void vApplicationTickHook(void){}
void vApplicationIdleHook(void){}

void vApplicationStackOverflowHook(void *pxTask, signed char *pcTaskName)
{
    while(1);
}

void vApplicationMallocFailedHook(void)
{
    while(1);
}

void vAssertCalled(const char *pcFile, unsigned long ulLine)
{
    while(1);
}
