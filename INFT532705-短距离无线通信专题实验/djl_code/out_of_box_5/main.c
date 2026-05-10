#include <stdlib.h>
#include <string.h>
#include <stdio.h>
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
#include "uart_if.h"
#include "uart.h"     // 添加 UART 相关头文件以支持非阻塞查询
#include "i2c_if.h"
#include "common.h"
#include "tmp006drv.h"
#include "bma222drv.h"
#include "pinmux.h"

//=============================================================================
// 宏定义配置
//=============================================================================
#define APPLICATION_NAME        "Sensor Network Transfer"
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

#if defined(ccs) || defined (gcc)
extern void (* const g_pfnVectors[])(void);
#endif
#if defined(ewarm)
extern uVectorEntry __vector_table;
#endif

//=============================================================================
// 辅助函数: 安全浮点数转字符串 (避免嵌入式不支持%f的问题)
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
// SimpleLink 异步事件回调函数
//=============================================================================
void SimpleLinkWlanEventHandler(SlWlanEvent_t *pWlanEvent) {
    if(pWlanEvent->Event == SL_WLAN_CONNECT_EVENT) {
        SET_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION);
    } else if(pWlanEvent->Event == SL_WLAN_DISCONNECT_EVENT) {
        CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION);
        CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED);
    }
}

void SimpleLinkNetAppEventHandler(SlNetAppEvent_t *pNetAppEvent) {
    if(pNetAppEvent->Event == SL_NETAPP_IPV4_IPACQUIRED_EVENT) {
        SET_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED);
        g_ulIpAddr = pNetAppEvent->EventData.ipAcquiredV4.ip;
    }
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
    if (lRetVal != ROLE_STA) {
        sl_WlanSetMode(ROLE_STA);
        sl_Stop(0xFF);
        lRetVal = sl_Start(0, 0, 0);
    }

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

//=============================================================================
// 核心任务逻辑：读取并发送传感器数据
//=============================================================================
int SendSensorDataLoop(int iSockID, struct SlSockAddrIn_t *sAddr, int bIsTCP) {
    float fCurrentTemp = 0.0, fTempC = 0.0;
    signed char cAccX = 0, cAccY = 0, cAccZ = 0;
    float fAccX_m_s2, fAccY_m_s2, fAccZ_m_s2;
    char strT[10], strX[10], strY[10], strZ[10];
    int iAddrSize = sizeof(SlSockAddrIn_t);
    int iStatus, i;

    UART_PRINT("\n\r>>> 开始发送传感器数据。随时按 'q' 键中断并返回菜单 <<<\n\r");

    while(1) {
        // 1. 读取数据与换算
        if (g_tmp006Status) {
            TMP006DrvGetTemp(&fCurrentTemp);
            // 华氏度转摄氏度: C = (F - 32) * 5 / 9
            fTempC = (fCurrentTemp - 32.0f) * 5.0f / 9.0f;
        }

        if (g_bma222Status) {
            BMA222ReadNew(&cAccX, &cAccY, &cAccZ);
            // LSB转公制: 64 = 1g = 9.8 m/s^2
            fAccX_m_s2 = ((float)cAccX / 64.0f) * 9.8f;
            fAccY_m_s2 = ((float)cAccY / 64.0f) * 9.8f;
            fAccZ_m_s2 = ((float)cAccZ / 64.0f) * 9.8f;
        }

        // LED阈值指示 (基于原始值判断)
        if (cAccX > 15 || cAccX < -15) {
            GPIO_IF_LedOn(MCU_RED_LED_GPIO); GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);
        } else {
            GPIO_IF_LedOff(MCU_RED_LED_GPIO); GPIO_IF_LedOn(MCU_GREEN_LED_GPIO);
        }

        // 2. 格式化数据字符串
        FloatToStr(fTempC, strT);
        FloatToStr(fAccX_m_s2, strX);
        FloatToStr(fAccY_m_s2, strY);
        FloatToStr(fAccZ_m_s2, strZ);
        sprintf(g_cBsdBuf, "Temp: %s C | Accel(m/s2): X=%s, Y=%s, Z=%s", strT, strX, strY, strZ);

        // 3. 网络发送
        if (bIsTCP) {
            iStatus = sl_Send(iSockID, g_cBsdBuf, strlen(g_cBsdBuf), 0);
        } else {
            iStatus = sl_SendTo(iSockID, g_cBsdBuf, strlen(g_cBsdBuf), 0, (SlSockAddr_t*)sAddr, iAddrSize);
        }

        if (iStatus <= 0) {
            UART_PRINT("网络发送错误，代码: %d\n\r", iStatus);
            return -1;
        } else {
            UART_PRINT("发送成功: %s\n\r", g_cBsdBuf);
        }

        // 4. 非阻塞延时(约1秒)，随时监测串口输入实现切换
        for (i = 0; i < 100; i++) {
            if (MAP_UARTCharsAvail(CONSOLE)) {
                char c = MAP_UARTCharGetNonBlocking(CONSOLE);
                if (c == 'q' || c == 'Q') {
                    UART_PRINT("\n\r[用户中断] 已停止传输...\n\r");
                    return -1; // 返回中断信号
                }
            }
            osi_Sleep(10);
        }
    }
    return 0;
}

//=============================================================================
// 网络模式封装 (UDP客户端)
//=============================================================================
void RunUdpClient() {
    SlSockAddrIn_t sAddr;
    int iSockID;

    sAddr.sin_family = SL_AF_INET;
    sAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum);
    sAddr.sin_addr.s_addr = sl_Htonl(g_ulDestinationIp);

    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_DGRAM, 0);
    if(iSockID < 0) return;

    UART_PRINT("\n\r进入 UDP 客户端模式，发送至 %d.%d.%d.%d:%d\n\r",
               SL_IPV4_BYTE(g_ulDestinationIp,3), SL_IPV4_BYTE(g_ulDestinationIp,2),
               SL_IPV4_BYTE(g_ulDestinationIp,1), SL_IPV4_BYTE(g_ulDestinationIp,0), g_uiPortNum);

    SendSensorDataLoop(iSockID, &sAddr, 0);
    sl_Close(iSockID);
}

//=============================================================================
// 网络模式封装 (TCP客户端)
//=============================================================================
void RunTcpClient() {
    SlSockAddrIn_t sAddr;
    int iSockID, iStatus;

    sAddr.sin_family = SL_AF_INET;
    sAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum);
    sAddr.sin_addr.s_addr = sl_Htonl(g_ulDestinationIp);

    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_STREAM, 0);
    if(iSockID < 0) return;

    UART_PRINT("\n\r正在连接 TCP 服务端 %d.%d.%d.%d:%d...\n\r",
               SL_IPV4_BYTE(g_ulDestinationIp,3), SL_IPV4_BYTE(g_ulDestinationIp,2),
               SL_IPV4_BYTE(g_ulDestinationIp,1), SL_IPV4_BYTE(g_ulDestinationIp,0), g_uiPortNum);

    iStatus = sl_Connect(iSockID, (SlSockAddr_t *)&sAddr, sizeof(SlSockAddrIn_t));
    if(iStatus < 0) {
        UART_PRINT("TCP 连接失败! 代码: %d\n\r", iStatus);
        sl_Close(iSockID);
        return;
    }

    UART_PRINT("TCP 连接成功!\n\r");
    SendSensorDataLoop(iSockID, NULL, 1);
    sl_Close(iSockID);
}

//=============================================================================
// 网络模式封装 (TCP服务端)
//=============================================================================
void RunTcpServer() {
    SlSockAddrIn_t sLocalAddr, sClientAddr;
    int iSockID, iNewSockID, iStatus;
    SlSocklen_t iAddrSize = sizeof(SlSockAddrIn_t);
    SlSockNonblocking_t enableOption = { 1 };

    sLocalAddr.sin_family = SL_AF_INET;
    sLocalAddr.sin_port = sl_Htons((unsigned short)g_uiPortNum);
    sLocalAddr.sin_addr.s_addr = 0;

    iSockID = sl_Socket(SL_AF_INET, SL_SOCK_STREAM, 0);
    if(iSockID < 0) return;

    // 设置Socket为非阻塞模式，防止 sl_Accept 锁死进程导致无法响应串口切换任务
    sl_SetSockOpt(iSockID, SL_SOL_SOCKET, SL_SO_NONBLOCKING, &enableOption, sizeof(enableOption));

    iStatus = sl_Bind(iSockID, (SlSockAddr_t *)&sLocalAddr, sizeof(SlSockAddrIn_t));
    if(iStatus < 0) { sl_Close(iSockID); return; }

    iStatus = sl_Listen(iSockID, 1);
    if(iStatus < 0) { sl_Close(iSockID); return; }

    UART_PRINT("\n\rTCP 服务端已启动，监听端口: %d\n\r", g_uiPortNum);
    UART_PRINT("等待连接... (随时按 'q' 键中断并返回菜单)\n\r");

    while(1) {
        // 查询串口输入，随时可跳出循环
        if (MAP_UARTCharsAvail(CONSOLE)) {
            char c = MAP_UARTCharGetNonBlocking(CONSOLE);
            if (c == 'q' || c == 'Q') {
                UART_PRINT("\n\r[用户中断] 关闭 TCP 服务端...\n\r");
                break;
            }
        }

        iNewSockID = sl_Accept(iSockID, (struct SlSockAddr_t *)&sClientAddr, &iAddrSize);
        if(iNewSockID >= 0) {
            UART_PRINT("收到客户端连接! 开始发送数据...\n\r");
            if (SendSensorDataLoop(iNewSockID, NULL, 1) < 0) {
                sl_Close(iNewSockID);
                break; // 如果在传输时按下了 q，则直接完全退出服务端模式
            }
            sl_Close(iNewSockID);
            UART_PRINT("客户端断开，等待下一个连接... (按 'q' 退出)\n\r");
        } else if (iNewSockID == SL_EAGAIN) {
            osi_Sleep(10); // 没有任何连接，休眠一会避免占满CPU
        } else {
            break; // 产生其他错误
        }
    }
    sl_Close(iSockID);
}

//=============================================================================
// 主应用任务：菜单与调度
//=============================================================================
static void AppTask(void *pvParameters) {
    char cInput;

    if(WlanConnect() < 0) {
        UART_PRINT("网络连接失败，请复位设备重试。\n\r");
        while(1) { osi_Sleep(1000); }
    }

    while(1) {
        UART_PRINT("\n\r==================================\n\r");
        UART_PRINT("  请选择传输模式 (1-3):\n\r");
        UART_PRINT("  1. UDP 客户端模式 (任务1)\n\r");
        UART_PRINT("  2. TCP 客户端模式 (任务2)\n\r");
        UART_PRINT("  3. TCP 服务端模式 (任务2)\n\r");
        UART_PRINT("==================================\n\r");

        cInput = MAP_UARTCharGet(CONSOLE);
        MAP_UARTCharPut(CONSOLE, cInput);
        UART_PRINT("\n\r");

        if (cInput == '1') {
            RunUdpClient();
        }
        else if (cInput == '2') {
            RunTcpClient();
        }
        else if (cInput == '3') {
            RunTcpServer();
        }
        else {
            UART_PRINT("无效输入，请重新选择。\n\r");
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

    GPIO_IF_LedConfigure(LED1|LED2|LED3);
    GPIO_IF_LedOff(MCU_RED_LED_GPIO);
    GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);

    lRetVal = I2C_IF_Open(I2C_MASTER_MODE_FST);
    if(lRetVal >= 0) {
        if(BMA222Open() == 0) g_bma222Status = 1;
        if(TMP006DrvOpen() == 0) g_tmp006Status = 1;
        UART_PRINT("传感器初始化完成。温度状态:%d，加速度状态:%d\n\r", g_tmp006Status, g_bma222Status);
    }

    lRetVal = VStartSimpleLinkSpawnTask(SPAWN_TASK_PRIORITY);
    if(lRetVal < 0) LOOP_FOREVER();

    lRetVal = osi_TaskCreate(AppTask, (signed char*)"AppTask", OSI_STACK_SIZE, NULL, OOB_TASK_PRIORITY, NULL);
    if(lRetVal < 0) LOOP_FOREVER();

    osi_start();

    while (1) {}
}
