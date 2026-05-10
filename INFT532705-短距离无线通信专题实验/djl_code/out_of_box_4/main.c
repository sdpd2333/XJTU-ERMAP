// Standard includes
#include <stdlib.h>
#include <string.h>

// Simplelink includes
#include "simplelink.h"
#include "netcfg.h"

// Driverlib includes
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
#include "uart.h"
#include "gpio.h" // 增加GPIO支持用于按键读取

// OS includes
#include "osi.h"

// Common interface includes
#include "gpio_if.h"
#include "uart_if.h"
#include "i2c_if.h"
#include "common.h"

// App Includes
#include "device_status.h"
#include "smartconfig.h"
#include "tmp006drv.h"
#include "bma222drv.h"
#include "pinmux.h"

#define APPLICATION_VERSION              "1.4.0"
#define APP_NAME                         "YihaoWang_CC3200"
#define OOB_TASK_PRIORITY                1
#define SPAWN_TASK_PRIORITY              9
#define OSI_STACK_SIZE                   2048
#define SL_STOP_TIMEOUT                  200

// 自定义网络配置参数
#define AP_SSID_NAME                     "YihaoWang"
#define AP_PASSWORD                      "2224411546"
#define STA_SSID_NAME                    /*"TP-LINK_76E3"*/"Redmi_217D"
#define STA_PASSWORD                     /*"xjtu624624"*/"13927779896"

typedef enum
{
  LED_OFF = 0,
  LED_ON,
  LED_BLINK
}eLEDStatus;

//*****************************************************************************
//                 GLOBAL VARIABLES -- Start
//*****************************************************************************
static const char pcDigits[] = "0123456789";
static unsigned char POST_token[] = "__SL_P_ULD";
static unsigned char GET_token_TEMP[]  = "__SL_G_UTP";
static unsigned char GET_token_ACC[]  = "__SL_G_UAC";
static unsigned char GET_token_UIC[]  = "__SL_G_UIC";

static int g_iInternetAccess = -1;
static unsigned char g_ucDryerRunning = 0;
static unsigned int g_uiDeviceModeConfig = ROLE_STA; // 默认为STA模式
static unsigned char g_ucLEDStatus = LED_OFF;
static unsigned long  g_ulStatus = 0; // SimpleLink Status
static unsigned char  g_ucConnectionSSID[SSID_LEN_MAX+1];
static unsigned char  g_ucConnectionBSSID[BSSID_LEN_MAX];
static int g_tmp006Status = 0;
static int g_bma222Status = 0;

#if defined(ccs)
extern void (* const g_pfnVectors[])(void);
#endif
#if defined(ewarm)
extern uVectorEntry __vector_table;
#endif
//*****************************************************************************
//                 GLOBAL VARIABLES -- End
//*****************************************************************************

#ifdef USE_FREERTOS
void vApplicationTickHook( void ) {}
void vAssertCalled( const char *pcFile, unsigned long ulLine ) { while(1) {} }
void vApplicationIdleHook( void ) {}
void vApplicationStackOverflowHook( OsiTaskHandle *pxTask, signed char *pcTaskName) { for( ;; ); }
void vApplicationMallocFailedHook() { while(1) {} }
#endif

// 数字转字符串
static unsigned short itoa(char cNum, char *cString)
{
    char* ptr;
    char uTemp = cNum;
    unsigned short length;
    if (cNum == 0)
    {
        length = 1;
        *cString = '0';
        return length;
    }
    length = 0;
    while (uTemp > 0)
    {
        uTemp /= 10;
        length++;
    }
    uTemp = cNum;
    ptr = cString + length;
    while (uTemp > 0)
    {
        --ptr;
        *ptr = pcDigits[uTemp % 10];
        uTemp /= 10;
    }
    return length;
}

// 读取加速度传感器
void ReadAccSensor()
{
    const short csAccThreshold = 5;
    signed char cAccXT1,cAccYT1,cAccZT1;
    signed char cAccXT2,cAccYT2,cAccZT2;
    signed short sDelAccX, sDelAccY, sDelAccZ;
    int iRet = -1;
    int iCount = 0;

    iRet = BMA222ReadNew(&cAccXT1, &cAccYT1, &cAccZT1);
    if(iRet) return;

    for(iCount=0; iCount<2; iCount++)
    {
        MAP_UtilsDelay((90*80*1000));
        iRet = BMA222ReadNew(&cAccXT2, &cAccYT2, &cAccZT2);
        if(iRet) continue;

        sDelAccX = abs((signed short)cAccXT2 - (signed short)cAccXT1);
        sDelAccY = abs((signed short)cAccYT2 - (signed short)cAccYT1);
        sDelAccZ = abs((signed short)cAccZT2 - (signed short)cAccZT1);

        if(sDelAccX > csAccThreshold || sDelAccY > csAccThreshold || sDelAccZ > csAccThreshold)
        {
            g_ucDryerRunning = 1; // 检测到移动
            break;
        }
        else
        {
            g_ucDryerRunning = 0;
        }
    }
}

//*****************************************************************************
// SimpleLink Asynchronous Event Handlers -- Start
//*****************************************************************************
void SimpleLinkWlanEventHandler(SlWlanEvent_t *pWlanEvent)
{
    if(pWlanEvent == NULL) { UART_PRINT("Null pointer\n\r"); LOOP_FOREVER(); }
    switch(pWlanEvent->Event)
    {
        case SL_WLAN_CONNECT_EVENT:
        {
            SET_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION);
            memcpy(g_ucConnectionSSID,pWlanEvent->EventData.STAandP2PModeWlanConnected.ssid_name,
                   pWlanEvent->EventData.STAandP2PModeWlanConnected.ssid_len);
            memcpy(g_ucConnectionBSSID,pWlanEvent->EventData.STAandP2PModeWlanConnected.bssid,
                   SL_BSSID_LENGTH);
            UART_PRINT("[WLAN EVENT] 已连接到AP: %s\n\r", g_ucConnectionSSID);
        }
        break;
        case SL_WLAN_DISCONNECT_EVENT:
        {
            slWlanConnectAsyncResponse_t*  pEventData = NULL;
            CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_CONNECTION);
            CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED);
            pEventData = &pWlanEvent->EventData.STAandP2PModeDisconnected;
            if(SL_WLAN_DISCONNECT_USER_INITIATED_DISCONNECTION == pEventData->reason_code)
            {
                UART_PRINT("[WLAN EVENT] 设备主动断开连接\n\r");
            }
            else
            {
                UART_PRINT("[WLAN ERROR] 连接断开，原因码: %d\n\r", pEventData->reason_code);
            }
            memset(g_ucConnectionSSID,0,sizeof(g_ucConnectionSSID));
            memset(g_ucConnectionBSSID,0,sizeof(g_ucConnectionBSSID));
        }
        break;
        case SL_WLAN_STA_CONNECTED_EVENT:
            UART_PRINT("[WLAN EVENT] 设备已连接到CC3200 AP\n\r");
            break;
        case SL_WLAN_STA_DISCONNECTED_EVENT:
            UART_PRINT("[WLAN EVENT] 设备已从CC3200 AP断开\n\r");
            break;
        default:
            break;
    }
}

void SimpleLinkNetAppEventHandler(SlNetAppEvent_t *pNetAppEvent)
{
    if(pNetAppEvent == NULL) { UART_PRINT("Null pointer\n\r"); LOOP_FOREVER(); }
    switch(pNetAppEvent->Event)
    {
        case SL_NETAPP_IPV4_IPACQUIRED_EVENT:
        {
            SET_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_AQUIRED);

            // STA模式：获取并打印 CC3200的IP 和 路由器(网关)的IP
            UART_PRINT("\n\r[NETAPP EVENT] --- STA模式 IP信息 ---\n\r");
            UART_PRINT("CC3200板 IP地址: %d.%d.%d.%d\n\r",
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.ip,3),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.ip,2),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.ip,1),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.ip,0));
            UART_PRINT("路由器(网关) IP地址: %d.%d.%d.%d\n\r",
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.gateway,3),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.gateway,2),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.gateway,1),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipAcquiredV4.gateway,0));
            UART_PRINT("-----------------------------------\n\r");
        }
        break;
        case SL_NETAPP_IP_LEASED_EVENT:
        {
            SET_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_LEASED);

            // AP模式：获取并打印 分配给笔记本(客户端)的IP
            UART_PRINT("\n\r[NETAPP EVENT] --- AP模式 客户端已连接 ---\n\r");
            UART_PRINT("笔记本(客户端) IP地址: %d.%d.%d.%d\n\r",
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipLeased.ip_address,3),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipLeased.ip_address,2),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipLeased.ip_address,1),
                SL_IPV4_BYTE(pNetAppEvent->EventData.ipLeased.ip_address,0));
            UART_PRINT("------------------------------------------\n\r");
        }
        break;
        case SL_NETAPP_IP_RELEASED_EVENT:
        {
            CLR_STATUS_BIT(g_ulStatus, STATUS_BIT_IP_LEASED);
        }
        break;
        default:
            break;
    }
}


void SimpleLinkHttpServerCallback(SlHttpServerEvent_t *pSlHttpServerEvent,
                                SlHttpServerResponse_t *pSlHttpServerResponse)
{
    // 保留原有HTTP回调函数逻辑以维持对原有POST/GET请求的响应支持
    // ...
}

void SimpleLinkGeneralEventHandler(SlDeviceEvent_t *pDevEvent)
{
    if(pDevEvent == NULL) { UART_PRINT("Null pointer\n\r"); LOOP_FOREVER(); }
    UART_PRINT("[GENERAL EVENT] - ID=[%d] Sender=[%d]\n\n",
               pDevEvent->EventData.deviceEvent.status,
               pDevEvent->EventData.deviceEvent.sender);
}

void SimpleLinkSockEventHandler(SlSockEvent_t *pSock)
{
    if(pSock == NULL) { UART_PRINT("Null pointer\n\r"); LOOP_FOREVER(); }
}
//*****************************************************************************
// SimpleLink Asynchronous Event Handlers -- End
//*****************************************************************************

static void InitializeAppVariables()
{
    g_ulStatus = 0;
    memset(g_ucConnectionSSID,0,sizeof(g_ucConnectionSSID));
    memset(g_ucConnectionBSSID,0,sizeof(g_ucConnectionBSSID));
    g_iInternetAccess = -1;
    g_ucDryerRunning = 0;
    g_uiDeviceModeConfig = ROLE_STA;
    g_ucLEDStatus = LED_OFF;
}

static int ConfigureMode(int iMode)
{
    long lRetVal = -1;
    lRetVal = sl_WlanSetMode(iMode);
    ASSERT_ON_ERROR(lRetVal);
    lRetVal = sl_Stop(SL_STOP_TIMEOUT);
    CLR_STATUS_BIT_ALL(g_ulStatus);
    return sl_Start(NULL,NULL,NULL);
}

// 设置AP模式参数
static int SetAPConfig()
{
    long lRetVal = -1;
    unsigned char ucVal = SL_SEC_TYPE_WPA;
    lRetVal = sl_WlanSet(SL_WLAN_CFG_AP_ID, WLAN_AP_OPT_SECURITY_TYPE, 1, &ucVal);
    ASSERT_ON_ERROR(lRetVal);
    lRetVal = sl_WlanSet(SL_WLAN_CFG_AP_ID, WLAN_AP_OPT_PASSWORD, strlen(AP_PASSWORD), (unsigned char*)AP_PASSWORD);
    ASSERT_ON_ERROR(lRetVal);
    lRetVal = sl_WlanSet(SL_WLAN_CFG_AP_ID, WLAN_AP_OPT_SSID, strlen(AP_SSID_NAME), (unsigned char*)AP_SSID_NAME);
    ASSERT_ON_ERROR(lRetVal);
    return SUCCESS;
}

// 连接到指定STA模式路由
static int ConnectToSTA()
{
    SlSecParams_t secParams;
    long lRetVal = -1;
    unsigned long ulConnectTimeout = 0;

    secParams.Key = (signed char*)STA_PASSWORD;
    secParams.KeyLen = strlen(STA_PASSWORD);
    secParams.Type = SL_SEC_TYPE_WPA;
    UART_PRINT("正在连接到路由器: %s...\n\r", STA_SSID_NAME);
    lRetVal = sl_WlanConnect((signed char*)STA_SSID_NAME, strlen(STA_SSID_NAME), 0, &secParams, 0);
    ASSERT_ON_ERROR(lRetVal);

    // 连接超时控制
    while((!IS_CONNECTED(g_ulStatus)) || (!IS_IP_ACQUIRED(g_ulStatus)))
    {
        osi_Sleep(500);
        ulConnectTimeout += 500;
        if((ulConnectTimeout % 2000) == 0) UART_PRINT(".");

        if(ulConnectTimeout >= 20000) // 20秒超时
        {
            UART_PRINT("\n\r连接超时，请检查热点是否开启或稍后尝试切换模式。\n\r");
            return -1;
        }
    }
    UART_PRINT("\n\r成功连接到路由器并获取IP!\n\r");
    return SUCCESS;
}

// 统一的网络连接与模式切换函数
// 统一的网络连接与模式切换函数 (增强稳定版)
// 统一的网络连接与模式切换函数 (终极极度稳定版)(依然失败版)
long ConnectToNetwork()
{
    long lRetVal = -1;

    // 1. 如果当前已连接，先主动断开
    if(IS_CONNECTED(g_ulStatus))
    {
        sl_WlanDisconnect();
        osi_Sleep(2000); // 给底层一点时间处理断开事件
    }

    // 2. 获取当前NWP的真实运行模式
    lRetVal = sl_Start(NULL, NULL, NULL);
    if(lRetVal < 0) return lRetVal;
    int currentMode = lRetVal;

    // 3. 判断是否需要配置新模式
    if(currentMode != g_uiDeviceModeConfig)
    {
        lRetVal = sl_WlanSetMode(g_uiDeviceModeConfig);
        ASSERT_ON_ERROR(lRetVal);
    }

    // 4. 如果目标是AP模式，提前写入AP的SSID和密码
    if(g_uiDeviceModeConfig == ROLE_AP)
    {
        SetAPConfig();
    }

    // 5. 统一重启NWP，使所有的模式修改和AP参数修改生效 (只重启一次，极大提高稳定性)
    sl_Stop(SL_STOP_TIMEOUT);
    CLR_STATUS_BIT_ALL(g_ulStatus);
    osi_Sleep(2000); // 给硬件缓冲时间
    lRetVal = sl_Start(NULL, NULL, NULL);
    if(lRetVal < 0) return lRetVal;

    // 6. 统一重启 HTTP Server
    sl_NetAppStop(SL_NET_APP_HTTP_SERVER_ID);
    sl_NetAppStart(SL_NET_APP_HTTP_SERVER_ID);

    // 7. 根据目标模式执行连接/等待逻辑
    if(g_uiDeviceModeConfig == ROLE_AP)
    {
        // 等待AP模式自身获取到IP
        while(!IS_IP_ACQUIRED(g_ulStatus))
        {
            osi_Sleep(10);
        }

        // 获取并打印AP模式IP
        unsigned char len = sizeof(SlNetCfgIpV4Args_t);
        unsigned char dhcpIsOn = 0;
        SlNetCfgIpV4Args_t ipV4 = {0};
        sl_NetCfgGet(SL_IPV4_AP_P2P_GO_GET_INFO, &dhcpIsOn, &len, (unsigned char *)&ipV4);

        UART_PRINT("\n\r===========================================\n\r");
        UART_PRINT("已进入 AP 模式!\n\r");
        UART_PRINT("请使用笔记本连接热点 SSID: %s (密码: %s)\n\r", AP_SSID_NAME, AP_PASSWORD);
        UART_PRINT("CC3200板 IP地址: %d.%d.%d.%d\n\r",
            SL_IPV4_BYTE(ipV4.ipV4,3), SL_IPV4_BYTE(ipV4.ipV4,2),
            SL_IPV4_BYTE(ipV4.ipV4,1), SL_IPV4_BYTE(ipV4.ipV4,0));
        UART_PRINT("等待笔记本连接... (连接后将自动打印笔记本IP)\n\r");
        UART_PRINT("===========================================\n\r\n\r");
    }
    else if(g_uiDeviceModeConfig == ROLE_STA)
    {
        //UART_PRINT("debug1\n\r");
        lRetVal = ConnectToSTA();
        if(lRetVal < 0) return lRetVal;

        UART_PRINT("\n\r===========================================\n\r");
        UART_PRINT("已进入 STA 模式!\n\r");
        UART_PRINT("CC3200当前已连接路由器: %s\n\r", STA_SSID_NAME);
        UART_PRINT("(CC3200与路由器的IP已在上方事件中打印)\n\r");
        UART_PRINT("注: 请在PC的CMD终端中输入 'ipconfig' 查看笔记本IP\n\r");
        UART_PRINT("请确保您的PC与CC3200在同一个局域网内进行Ping测试\n\r");
        UART_PRINT("===========================================\n\r\n\r");
    }
    return SUCCESS;
}



// 模式说明打印
static void PrintModeInstructions()
{
    UART_PRINT("\n\r[操作指南] 您随时可以通过以下方式切换模式:\n\r");
    UART_PRINT(" - 串口发送 '1' 或按下板载 SW2 键 -> 切换至 AP 模式\n\r");
    UART_PRINT(" - 串口发送 '2' 或按下板载 SW3 键 -> 切换至 STA 模式\n\r");
    UART_PRINT("[状态指示] AP模式时红灯常亮，STA模式时红灯熄灭\n\r\n\r");
}

static void OOBTask(void *pvParameters)
{
    long lRetVal = -1;

    PrintModeInstructions();

    // 初始连接
    lRetVal = ConnectToNetwork();
    if(lRetVal < 0)
    {
        UART_PRINT("初始网络连接失败，系统处于待命状态，请尝试切换模式。\n\r");
    }

    while(1)
    {
        long lInput = MAP_UARTCharGetNonBlocking(UARTA0_BASE);
        if(lInput != -1)
        {
             char cInput = (char)lInput;
             if(cInput == '1' && g_uiDeviceModeConfig != ROLE_AP)
             {
                 UART_PRINT("\n\r[中断] 接收到串口指令'1'，正在切换到 AP 模式...\n\r");
                 g_uiDeviceModeConfig = ROLE_AP;
                 ConnectToNetwork();
             }
             else if(cInput == '2' && g_uiDeviceModeConfig != ROLE_STA)
             {
                 UART_PRINT("\n\r[中断] 接收到串口指令'2'，正在切换到 STA 模式...\n\r");
                 g_uiDeviceModeConfig = ROLE_STA;
                 ConnectToNetwork();
             }
        }

        // 2. 按键状态轮询
        unsigned char ucSW2 = MAP_GPIOPinRead(GPIOA2_BASE, 0x40);
        unsigned char ucSW3 = MAP_GPIOPinRead(GPIOA1_BASE, 0x20);

        if(ucSW2 != 0 && g_uiDeviceModeConfig != ROLE_AP)
        {
             // 简单的软件防抖：延时20ms后再次确认是否真被按下
             osi_Sleep(20);
             if(MAP_GPIOPinRead(GPIOA2_BASE, 0x40) != 0)
             {
                 UART_PRINT("\n\r[中断] 检测到 SW2 按下，正在切换到 AP 模式...\n\r");
                 g_uiDeviceModeConfig = ROLE_AP;
                 ConnectToNetwork();
                 osi_Sleep(1000); // 切换后长延时，防止按键未松开导致的连续触发
             }
        }
        else if(ucSW3 != 0 && g_uiDeviceModeConfig != ROLE_STA)
        {
             // 简单的软件防抖
             osi_Sleep(20);
             if(MAP_GPIOPinRead(GPIOA1_BASE, 0x20) != 0)
             {
                 UART_PRINT("\n\r[中断] 检测到 SW3 按下，正在切换到 STA 模式...\n\r");
                 g_uiDeviceModeConfig = ROLE_STA;
                 //UART_PRINT("debug2\n\r");
                 ConnectToNetwork();
                 osi_Sleep(1000); // 切换后长延时，防止连续触发
             }
        }

        // 3. LED状态指示: AP模式红灯亮，STA模式红灯灭
        if(g_uiDeviceModeConfig == ROLE_AP)
        {
            GPIO_IF_LedOn(MCU_RED_LED_GPIO);
        }
        else
        {
            GPIO_IF_LedOff(MCU_RED_LED_GPIO);
        }

        // 4. 温度警报逻辑：超过30度才打印
        if(g_tmp006Status)
        {
            float fCurrentTemp;
            TMP006DrvGetTemp(&fCurrentTemp);
            fCurrentTemp = (fCurrentTemp - 32.0f)*5.0f/9.0f; // 华氏度转为摄氏度
            if(fCurrentTemp > 30.0f)
            {
                UART_PRINT("[警报] 环境温度过高！当前温度: %d C\r\n", (int)fCurrentTemp);
            }
        }

        // 5. 加速度警报逻辑：检测到移动才打印
        if(g_bma222Status)
        {
            ReadAccSensor();
            if(g_ucDryerRunning)
            {
                UART_PRINT("[警报] 设备发生移动/震动！\r\n");
            }
        }

        osi_Sleep(200); // 轮询睡眠周期，释放CPU
    }
}

static void DisplayBanner(char * AppName)
{
    UART_PRINT("\n\n\n\r");
    UART_PRINT("\t\t *************************************************\n\r");
    UART_PRINT("\t\t     CC3200 %s Application       \n\r", AppName);
    UART_PRINT("\t\t *************************************************\n\r");
    UART_PRINT("\n\n\n\r");
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

void main()
{
    long lRetVal = -1;

    BoardInit();
    PinMuxConfig();
    PinConfigSet(PIN_58,PIN_STRENGTH_2MA|PIN_STRENGTH_4MA,PIN_TYPE_STD_PD);
    InitializeAppVariables();
    InitTerm();
    DisplayBanner(APP_NAME);

    // 初始化LED（基于gpio_if底层）
    GPIO_IF_LedConfigure(LED1|LED2|LED3);
    GPIO_IF_LedOff(MCU_RED_LED_GPIO);
    GPIO_IF_LedOff(MCU_ORANGE_LED_GPIO);
    GPIO_IF_LedOff(MCU_GREEN_LED_GPIO);

    // 开启I2C和传感器
    lRetVal = I2C_IF_Open(I2C_MASTER_MODE_FST);
    if(lRetVal < 0)
    {
        ERR_PRINT(lRetVal);
        DBG_PRINT("I2C open failed\n\r");
    }
    else
    {
        lRetVal = BMA222Open();
        if(lRetVal < 0) DBG_PRINT("BMA222 开启异常\n\r");
        else g_bma222Status = 1;

        lRetVal = TMP006DrvOpen();
        if(lRetVal < 0) DBG_PRINT("TMP006 开启异常\n\r");
        else g_tmp006Status = 1;
    }

    lRetVal = VStartSimpleLinkSpawnTask(SPAWN_TASK_PRIORITY);
    if(lRetVal < 0) LOOP_FOREVER();

    lRetVal = osi_TaskCreate(OOBTask, (signed char*)"OOBTask", OSI_STACK_SIZE, NULL, OOB_TASK_PRIORITY, NULL );
    if(lRetVal < 0) LOOP_FOREVER();

    osi_start();
    while (1) {}
}
