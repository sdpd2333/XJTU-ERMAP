#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "simplelink.h"
#include "netcfg.h"
#include "hw_ints.h"
#include "hw_types.h"
#include "hw_memmap.h"
#include "hw_common_reg.h"
#include "interrupt.h"
#include "utils.h"
#include "rom.h"
#include "rom_map.h"
#include "prcm.h"
#include "pin.h"
#include "osi.h"
#include "gpio_if.h"
#include "gpio.h"
#include "uart_if.h"
#include "uart.h"
#include "i2c_if.h"
#include "timer.h"
#include "common.h"
#include "tmp006drv.h"
#include "bma222drv.h"
#include "pinmux.h"
#include "FreeRTOS.h"
#include "task.h"
#include "prcm.h"

//=============================================================================
// 宏定义配置
//=============================================================================
#define APPLICATION_NAME        "Sensor Network Transfer (Edge Computing)"
#define OOB_TASK_PRIORITY       1
#define SPAWN_TASK_PRIORITY     9
#define OSI_STACK_SIZE          2048

#define IP_ADDR                 SL_IPV4_VAL(192,168,31,75)
#define PORT_NUM                5001
#define BUF_SIZE                1400

#define MY_SSID_NAME            /*"TP-LINK_76E3"*/"Redmi_217D"
#define MY_SECURITY_KEY         /*"xjtu624624"*/"13927779896"
#define MY_SECURITY_TYPE        SL_SEC_TYPE_WPA

// 状态位掩码和操作宏
#ifndef STATUS_BIT_CONNECTION
#define STATUS_BIT_CONNECTION   0
#endif
#ifndef STATUS_BIT_IP_AQUIRED
#define STATUS_BIT_IP_AQUIRED   1
#endif
#ifndef IS_CONNECTED
#define IS_CONNECTED(status)    (status & (1<<STATUS_BIT_CONNECTION))
#endif
#ifndef IS_IP_ACQUIRED
#define IS_IP_ACQUIRED(status)  (status & (1<<STATUS_BIT_IP_AQUIRED))
#endif

#ifndef SET_STATUS_BIT
#define SET_STATUS_BIT(status_variable, bit)  status_variable |= (1<<(bit))
#endif
#ifndef CLR_STATUS_BIT
#define CLR_STATUS_BIT(status_variable, bit)  status_variable &= ~(1<<(bit))
#endif

//=============================================================================
// 全局变量
//=============================================================================
volatile unsigned long  g_ulStatus = 0;
unsigned long  g_ulDestinationIp = IP_ADDR;
unsigned int   g_uiPortNum = PORT_NUM;
char g_cBsdBuf[BUF_SIZE];
unsigned long  g_ulIpAddr = 0;
int g_tmp006Status = 0;
int g_bma222Status = 0;

// 调试模式标志位 (0: 正常网络模式, 1: 本地串口调试模式)
int g_bDebugMode = 0;

// 控制模式与状态切换全局变量
int g_DisplayState = 0;  // 0: 全部, 1: 温度, 2: 加速度, 3: 按键, 4: 超声波

#if defined(ccs) || defined (gcc)
extern void (* const g_pfnVectors[])(void);
#endif
#if defined(ewarm)
extern uVectorEntry __vector_table;
#endif

//=============================================================================
// 辅助函数: 安全浮点数转字符串
//=============================================================================
void FloatToStr(float val, char* str) {
    if (val < 0) {
        val = -val;
        sprintf(str, "-%d.%02d", (int)val, (int)((val - (int)val) * 100));
    } else {
        sprintf(str, "%d.%02d", (int)val, (int)((val - (int)val) * 100));
    }
}

//=============================================================================
// SimpleLink 异步事件回调函数及 FreeRTOS 钩子函数
//=============================================================================
void SimpleLinkWlanEventHandler(SlWlanEvent_t *pWlanEvent) {
    if(pWlanEvent->Event == SL_WLAN_CONNECT_EVENT) SET_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION);
    else if(pWlanEvent->Event == SL_WLAN_DISCONNECT_EVENT) { CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION); CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED); }
}
void SimpleLinkNetAppEventHandler(SlNetAppEvent_t *pNetAppEvent) {
    if(pNetAppEvent->Event == SL_NETAPP_IPV4_IPACQUIRED_EVENT) { SET_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED); g_ulIpAddr = pNetAppEvent->EventData.ipAcquiredV4.ip; }
}
void SimpleLinkHttpServerCallback(SlHttpServerEvent_t *pEvent, SlHttpServerResponse_t *pResponse) {}
void SimpleLinkGeneralEventHandler(SlDeviceEvent_t *pDevEvent) {}
void SimpleLinkSockEventHandler(SlSockEvent_t *pSock) {}

#ifdef USE_FREERTOS
void vApplicationTickHook( void ) {}
void vAssertCalled( const char *pcFile, unsigned long ulLine ) { while(1); }
void vApplicationIdleHook( void ) {}
void vApplicationStackOverflowHook( OsiTaskHandle *pxTask, signed char *pcTaskName) { for( ;; ); }
void vApplicationMallocFailedHook() { while(1); }
#endif

//=============================================================================
// 板载及网络初始化
//=============================================================================
static void BoardInit(void) {
#ifndef USE_TIRTOS
#if defined(ccs) || defined(gcc)
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

static long WlanConnect() {
    SlSecParams_t secParams = {0};
    long lRetVal = -1;

    lRetVal = sl_Start(0, 0, 0);
    if (lRetVal != ROLE_STA) { sl_WlanSetMode(ROLE_STA); sl_Stop(0xFF); lRetVal = sl_Start(0, 0, 0); }
    sl_WlanPolicySet(SL_POLICY_CONNECTION, SL_CONNECTION_POLICY(0, 0, 0, 0, 0), NULL, 0);

    if(IS_CONNECTED(g_ulStatus)) {
        sl_WlanDisconnect();
        while(IS_CONNECTED(g_ulStatus)) { osi_Sleep(10); }
        CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED);
    }

    secParams.Key = (signed char*)MY_SECURITY_KEY;
    secParams.KeyLen = strlen(MY_SECURITY_KEY);
    secParams.Type = MY_SECURITY_TYPE;

    UART_PRINT("正在连接到路由器: %s ...\n\r", MY_SSID_NAME);
    lRetVal = sl_WlanConnect((signed char*)MY_SSID_NAME, strlen(MY_SSID_NAME), 0, &secParams, 0);
    if(lRetVal < 0 && lRetVal != -71) return lRetVal;

    unsigned int uiTimeout = 0;
    while((!IS_CONNECTED(g_ulStatus)) || (!IS_IP_ACQUIRED(g_ulStatus))) {
#ifndef SL_PLATFORM_MULTI_THREADED
        _SlNonOsMainLoopTask();
#endif
        osi_Sleep(100);
        if(++uiTimeout > 200) return -1;
    }

    unsigned long ulDevIp = sl_Ntohl(g_ulIpAddr);
    UART_PRINT("WiFi连接成功! 设备IP: %d.%d.%d.%d\n\r",
               SL_IPV4_BYTE(ulDevIp,0), SL_IPV4_BYTE(ulDevIp,1),
               SL_IPV4_BYTE(ulDevIp,2), SL_IPV4_BYTE(ulDevIp,3));
    return 0;
}

float ReadUltrasonicDistance() {
    unsigned long ulStart, ulStop, ulDiff;
    volatile int timeout;

    MAP_GPIOPinWrite(GPIOA1_BASE, 0x02, 0x02);
    MAP_UtilsDelay(800000/3 / 100);
    MAP_GPIOPinWrite(GPIOA1_BASE, 0x02, 0x00);

    timeout = 20000000;
    while(MAP_GPIOPinRead(GPIOA0_BASE, 0x8) == 0 && timeout > 0) timeout--;
    if (timeout <= 0) return -1.0;

    ulStart = MAP_TimerValueGet(TIMERA0_BASE, TIMER_A);

    timeout = 20000000;
    while(MAP_GPIOPinRead(GPIOA0_BASE, 0x8) != 0 && timeout > 0) timeout--;
    ulStop = MAP_TimerValueGet(TIMERA0_BASE, TIMER_A);

    if (timeout <= 0) return -2.0;

    if (ulStop >= ulStart) ulDiff = ulStop - ulStart;
    else ulDiff = (0xFFFFFFFF - ulStart) + ulStop + 1;

    return (float)ulDiff * 17.0f / 80000.0f;
}

//=============================================================================
// 核心任务逻辑：包含指令处理、数据采集与边缘计算发送
//=============================================================================
int SendSensorDataLoop(int iSockID, struct SlSockAddrIn_t *sAddr, int bIsTCP) {
    float fCurrentTemp = 0.0, fTempC = 0.0;
    signed char cAccX = 0, cAccY = 0, cAccZ = 0;
    static signed char lastAccX = 0, lastAccY = 0, lastAccZ = 0; // 用于边缘计算保存上次加速度
    float fAccX_m_s2, fAccY_m_s2, fAccZ_m_s2;
    char strT[10], strX[10], strY[10], strZ[10], strDist[10];
    int iAddrSize = sizeof(SlSockAddrIn_t);
    int iStatus = 0;
    char recvBuf[64];
    unsigned long tick_count = 0;

    UART_PRINT("\n\r>>> 开始数据传输任务。随时按 'q' 键中断并返回菜单 <<<\n\r");
    UART_PRINT("================= 控制指令说明 =================\n\r");
    UART_PRINT("  显示切换: 'S'=全部 'T'=温度 'A'=加速 'B'=按键 'U'=超声波\n\r");
    UART_PRINT("================================================\n\r");

    while(1) {
        int recvLen = 0;
        recvBuf[0] = '\0';

        // --- 1. 接收指令 (网络/串口) ---
        if (!g_bDebugMode) {
            if (bIsTCP) recvLen = sl_Recv(iSockID, recvBuf, sizeof(recvBuf)-1, 0);
            else recvLen = sl_RecvFrom(iSockID, recvBuf, sizeof(recvBuf)-1, 0, NULL, NULL);
            if (recvLen < 0 && recvLen != SL_EAGAIN) return -1;
            if (recvLen > 0) recvBuf[recvLen] = '\0';
        }

        char uartBuf[64];
        int uartLen = 0;
        while (MAP_UARTCharsAvail(CONSOLE) && uartLen < sizeof(uartBuf)-1) {
            uartBuf[uartLen++] = MAP_UARTCharGetNonBlocking(CONSOLE);
        }

        if (uartLen > 0) {
            uartBuf[uartLen] = '\0';
            if (strchr(uartBuf, 'q') || strchr(uartBuf, 'Q')) {
                UART_PRINT("\n\r[用户中断] 已停止传输...\n\r");
                GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);
                GPIO_IF_LedOff(MCU_ORANGE_LED_GPIO);
                return -1;
            }
            if (g_bDebugMode) { strcpy(recvBuf, uartBuf); recvLen = uartLen; }
        }

        if (recvLen > 0) {
            if (strchr(recvBuf, 'S')) { g_DisplayState = 0; UART_PRINT("  |- 显示全部信息\n\r"); }
            else if (strchr(recvBuf, 'T')) { g_DisplayState = 1; UART_PRINT("  |- 仅显示温度\n\r"); }
            else if (strchr(recvBuf, 'A')) { g_DisplayState = 2; UART_PRINT("  |- 仅显示加速度\n\r"); }
            else if (strchr(recvBuf, 'B')) { g_DisplayState = 3; UART_PRINT("  |- 仅显示按键\n\r"); }
            else if (strchr(recvBuf, 'U')) { g_DisplayState = 4; UART_PRINT("  |- 仅显示超声波\n\r"); }
        }

        // --- 2. 传感器采集与边缘计算 ---
        // 每 10 个 tick (约 1 秒) 执行一次
        if (tick_count % 10 == 0) {
            char payload[400] = "";
            char tempPart[64] = "";
            char accPart[64] = "";
            char btnPart[64] = "";
            char ultraPart[64] = "";
            char alarmMsg[128] = "";

            int isVibrationAlarm = 0;
            int isDistanceAlarm = 0;

            // 获取温度
            if (g_tmp006Status) {
                TMP006DrvGetTemp(&fCurrentTemp);
                fTempC = (fCurrentTemp - 32.0f) * 5.0f / 9.0f;
                FloatToStr(fTempC, strT);
                sprintf(tempPart, "Temp: %s C ", strT);
            }

            // 获取加速度与边缘计算 (剧烈震动判断)
            if (g_bma222Status) {
                BMA222ReadNew(&cAccX, &cAccY, &cAccZ);
                fAccX_m_s2 = ((float)cAccX / 64.0f) * 9.8f;
                fAccY_m_s2 = ((float)cAccY / 64.0f) * 9.8f;
                fAccZ_m_s2 = ((float)cAccZ / 64.0f) * 9.8f;
                FloatToStr(fAccX_m_s2, strX);
                FloatToStr(fAccY_m_s2, strY);
                FloatToStr(fAccZ_m_s2, strZ);
                sprintf(accPart, "| Accel: X=%s Y=%s Z=%s ", strX, strY, strZ);

                // 【边缘计算】差分震动算法：计算本次与上次的差值，消除重力影响
                int diffX = abs(cAccX - lastAccX);
                int diffY = abs(cAccY - lastAccY);
                int diffZ = abs(cAccZ - lastAccZ);

                // 阈值设为 20 (大约 0.3g 突变)，可根据实际开发板灵敏度调整
                if ((diffX > 20 || diffY > 20 || diffZ > 20) && tick_count > 0) {
                    isVibrationAlarm = 1;
                }

                // 记录本次值供下次使用
                lastAccX = cAccX; lastAccY = cAccY; lastAccZ = cAccZ;
            }

            // 获取按键
            long sw2_val = MAP_GPIOPinRead(GPIOA2_BASE, 0x40);
            long sw3_val = MAP_GPIOPinRead(GPIOA1_BASE, 0x20);
            int sw2_pressed = (sw2_val != 0) ? 0 : 1;
            int sw3_pressed = (sw3_val != 0) ? 0 : 1;
            sprintf(btnPart, "| SW2:%d SW3:%d ", sw2_pressed, sw3_pressed);

            // 获取超声波与边缘计算 (距离判断)
            float dist = ReadUltrasonicDistance();
            if (dist < 0) {
                sprintf(ultraPart, "| Dist: Timeout/Err");
            } else {
                FloatToStr(dist, strDist);
                sprintf(ultraPart, "| Dist: %s cm", strDist);

                // 【边缘计算】距离小于 10cm 报警
                if (dist < 10.0f) {
                    isDistanceAlarm = 1;
                }
            }

            // 报警状态综合处理及 LED 提示
            if (isVibrationAlarm || isDistanceAlarm) {
                GPIO_IF_LedOn(MCU_ORANGE_LED_GPIO);  // 报警亮橙灯
                GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);

                strcpy(alarmMsg, " !!! [ALARM:");
                if (isVibrationAlarm) strcat(alarmMsg, " VIBRATION");
                if (isDistanceAlarm) strcat(alarmMsg, " DIST<10cm");
                strcat(alarmMsg, "] !!!");
            } else {
                GPIO_IF_LedOff(MCU_ORANGE_LED_GPIO);
                GPIO_IF_LedOn(MCU_GREEN_LED_GPIO);   // 正常亮绿灯
            }

            // 拼接最终发送的有效载荷
            if (g_DisplayState == 0) {
                sprintf(payload, "%s%s%s%s%s\r\n", tempPart, accPart, btnPart, ultraPart, alarmMsg);
            } else if (g_DisplayState == 1) {
                sprintf(payload, "%s %s\r\n", tempPart, alarmMsg);
            } else if (g_DisplayState == 2) {
                sprintf(payload, "Accel: X=%s, Y=%s, Z=%s %s\r\n", strX, strY, strZ, alarmMsg);
            } else if (g_DisplayState == 3) {
                sprintf(payload, "SW2:%d SW3:%d %s\r\n", sw2_pressed, sw3_pressed, alarmMsg);
            } else if (g_DisplayState == 4) {
                if (dist < 0) sprintf(payload, "Dist: Timeout/Err %s\r\n", alarmMsg);
                else sprintf(payload, "Dist: %s cm %s\r\n", strDist, alarmMsg);
            }

            // 数据输出
            if (strlen(payload) > 0) {
                if (g_bDebugMode) {
                    UART_PRINT("%s", payload);
                } else {
                    if (bIsTCP) iStatus = sl_Send(iSockID, payload, strlen(payload), 0);
                    else iStatus = sl_SendTo(iSockID, payload, strlen(payload), 0, (SlSockAddr_t*)sAddr, iAddrSize);

                    if (iStatus < 0 && iStatus != SL_EAGAIN) {
                        UART_PRINT("数据发送失败，代码: %d\n\r", iStatus);
                    }
                }
            }
        }

        // 修改为 100ms 延时，降低 CPU 负担
        osi_Sleep(100);
        tick_count++;
    }
    return 0;
}

//=============================================================================
// 网络模式封装
//=============================================================================
void RunUdpClient() {
    SlSockAddrIn_t sAddr; int iSockID; SlSockNonblocking_t enableOption = { 1 };
    sAddr.sin_family = SL_AF_INET; sAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum); sAddr.sin_addr.s_addr = sl_Htonl(g_ulDestinationIp);
    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_DGRAM, 0);
    if(iSockID < 0) return;
    sl_SetSockOpt(iSockID, SL_SOL_SOCKET, SL_SO_NONBLOCKING, &enableOption, sizeof(enableOption));
    UART_PRINT("\n\r进入 UDP 客户端模式...\n\r");
    SendSensorDataLoop(iSockID, &sAddr, 0);
    sl_Close(iSockID);
}

void RunTcpClient() {
    SlSockAddrIn_t sAddr; int iSockID, iStatus; SlSockNonblocking_t enableOption = { 1 };
    sAddr.sin_family = SL_AF_INET; sAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum); sAddr.sin_addr.s_addr = sl_Htonl(g_ulDestinationIp);
    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_STREAM, 0);
    if(iSockID < 0) return;
    iStatus = sl_Connect(iSockID, (SlSockAddr_t *)&sAddr, sizeof(SlSockAddrIn_t));
    if(iStatus < 0) { UART_PRINT("TCP 连接失败!\n\r"); sl_Close(iSockID); return; }
    sl_SetSockOpt(iSockID, SL_SOL_SOCKET, SL_SO_NONBLOCKING, &enableOption, sizeof(enableOption));
    UART_PRINT("TCP 连接成功!\n\r");
    SendSensorDataLoop(iSockID, NULL, 1);
    sl_Close(iSockID);
}

void RunTcpServer() {
    SlSockAddrIn_t sLocalAddr, sClientAddr; int iSockID, iNewSockID, iStatus;
    SlSocklen_t iAddrSize = sizeof(SlSockAddrIn_t); SlSockNonblocking_t enableOption = { 1 };
    sLocalAddr.sin_family = SL_AF_INET; sLocalAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum); sLocalAddr.sin_addr.s_addr = 0;
    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_STREAM, 0);
    if(iSockID < 0) return;
    sl_SetSockOpt(iSockID, SL_SOL_SOCKET, SL_SO_NONBLOCKING, &enableOption, sizeof(enableOption));
    iStatus = sl_Bind(iSockID, (SlSockAddr_t *)&sLocalAddr, sizeof(SlSockAddrIn_t));
    if(iStatus < 0) { sl_Close(iSockID); return; }
    iStatus = sl_Listen(iSockID, 1);
    if(iStatus < 0) { sl_Close(iSockID); return; }
    UART_PRINT("\n\rTCP 服务端等待连接... (按 'q' 中断)\n\r");
    while(1) {
        if (MAP_UARTCharsAvail(CONSOLE)) { if (MAP_UARTCharGetNonBlocking(CONSOLE) == 'q') break; }
        iNewSockID = sl_Accept(iSockID, (struct SlSockAddr_t *)&sClientAddr, &iAddrSize);
        if(iNewSockID >= 0) {
            sl_SetSockOpt(iNewSockID, SL_SOL_SOCKET, SL_SO_NONBLOCKING, &enableOption, sizeof(enableOption));
            UART_PRINT("收到客户端连接!\n\r");
            if (SendSensorDataLoop(iNewSockID, NULL, 1) < 0) { sl_Close(iNewSockID); break; }
            sl_Close(iNewSockID);
        } else if (iNewSockID == SL_EAGAIN) { osi_Sleep(10); } else break;
    }
    sl_Close(iSockID);
}

//=============================================================================
// 主应用任务：菜单与调度
//=============================================================================
static void AppTask(void *pvParameters) {
    char cInput;
    while(1) {
        UART_PRINT("\n\r*********************************************\n\r");
        UART_PRINT("  设备启动选择 (边缘计算版):\n\r");
        UART_PRINT("  [D] 本地调试模式 (跳过WiFi)\n\r");
        UART_PRINT("  [W] 正常网络模式 (连接WiFi)\n\r");
        UART_PRINT("*********************************************\n\r");
        UART_PRINT("请输入选择: ");

        do { cInput = MAP_UARTCharGet(CONSOLE); } while (cInput != 'D' && cInput != 'd' && cInput != 'W' && cInput != 'w');
        MAP_UARTCharPut(CONSOLE, cInput); UART_PRINT("\n\r");

        if (cInput == 'D' || cInput == 'd') {
            g_bDebugMode = 1;
            UART_PRINT("\n\r>>> 本地调试模式启动...\n\r");
            SendSensorDataLoop(-1, NULL, 0);
        }
        else if (cInput == 'W' || cInput == 'w') {
            g_bDebugMode = 0;
            if(WlanConnect() < 0) { UART_PRINT("网络连接失败！按任意键返回...\n\r"); MAP_UARTCharGet(CONSOLE); continue; }
            while(1) {
                UART_PRINT("\n\r请选择传输模式: 1.UDPClient 2.TCPClient 3.TCPServer q.退出\n\r");
                cInput = MAP_UARTCharGet(CONSOLE);
                if (cInput == '1') RunUdpClient();
                else if (cInput == '2') RunTcpClient();
                else if (cInput == '3') RunTcpServer();
                else if (cInput == 'q' || cInput == 'Q') { sl_WlanDisconnect(); break; }
            }
        }
    }
}

//=============================================================================
// 主函数
//=============================================================================
void main() {
    long lRetVal = -1;
    BoardInit();
    PinMuxConfig();
    InitTerm();

    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA1, PRCM_RUN_MODE_CLK);
    MAP_PRCMPeripheralClkEnable(PRCM_GPIOA2, PRCM_RUN_MODE_CLK);
    MAP_PinTypeGPIO(PIN_15, PIN_MODE_0, false); MAP_GPIODirModeSet(GPIOA2_BASE, 0x40, GPIO_DIR_MODE_IN);
    MAP_PinTypeGPIO(PIN_04, PIN_MODE_0, false); MAP_GPIODirModeSet(GPIOA1_BASE, 0x20, GPIO_DIR_MODE_IN);

    MAP_PRCMPeripheralClkEnable(PRCM_TIMERA0, PRCM_RUN_MODE_CLK);
    MAP_PinTypeGPIO(PIN_64, PIN_MODE_0, false); MAP_GPIODirModeSet(GPIOA1_BASE, 0x02, GPIO_DIR_MODE_OUT); MAP_GPIOPinWrite(GPIOA1_BASE, 0x02, 0);
    MAP_PinTypeGPIO(PIN_58, PIN_MODE_0, false); MAP_GPIODirModeSet(GPIOA1_BASE, 0x80, GPIO_DIR_MODE_IN);

    MAP_TimerConfigure(TIMERA0_BASE, TIMER_CFG_PERIODIC_UP);
    MAP_TimerLoadSet(TIMERA0_BASE, TIMER_A, 0xFFFFFFFF);
    MAP_TimerEnable(TIMERA0_BASE, TIMER_A);

    GPIO_IF_LedConfigure(LED2|LED3);
    GPIO_IF_LedOff(MCU_ORANGE_LED_GPIO);
    GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);

    lRetVal = I2C_IF_Open(I2C_MASTER_MODE_FST);
    if(lRetVal >= 0) {
        if(BMA222Open() == 0) g_bma222Status = 1;
        if(TMP006DrvOpen() == 0) g_tmp006Status = 1;
    }

    VStartSimpleLinkSpawnTask(SPAWN_TASK_PRIORITY);
    osi_TaskCreate(AppTask, (signed char*)"AppTask", OSI_STACK_SIZE, NULL, OOB_TASK_PRIORITY, NULL);
    osi_start();
}
