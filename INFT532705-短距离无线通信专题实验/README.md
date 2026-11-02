# INFT532705 · 短距离无线通信专题实验

[返回课程导航](../README.md) · [通用使用指南](../docs/USAGE.md)

包含 2026 年实验材料、六组课程主题的课件，以及 CC3200 示例工程。

## 资料导航

| 入口 | 内容 |
| --- | --- |
| [2026 年实验材料](2026%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E4%B8%93%E9%A2%98%E5%AE%9E%E9%AA%8C.pdf) | PDF |
| [CC3200 工程](djl_code) | blinky、pwm、out_of_box_3/4/5/6_1 |
| [短距离无线通信实验1-短距离无线通信简介及按键控制跑马灯](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C1-%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E7%AE%80%E4%BB%8B%E5%8F%8A%E6%8C%89%E9%94%AE%E6%8E%A7%E5%88%B6%E8%B7%91%E9%A9%AC%E7%81%AF.pptx) | PowerPoint 课件 |
| [短距离无线通信实验2-串口控制LED亮度](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C2-%E4%B8%B2%E5%8F%A3%E6%8E%A7%E5%88%B6LED%E4%BA%AE%E5%BA%A6.pptx) | PowerPoint 课件 |
| [短距离无线通信实验3-通过I2C读取传感器信息](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C3-%E9%80%9A%E8%BF%87I2C%E8%AF%BB%E5%8F%96%E4%BC%A0%E6%84%9F%E5%99%A8%E4%BF%A1%E6%81%AF.pptx) | PowerPoint 课件 |
| [短距离无线通信实验4-WiFi基础与基本连接](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C4-WiFi%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%9F%BA%E6%9C%AC%E8%BF%9E%E6%8E%A5.pptx) | PowerPoint 课件 |
| [短距离无线通信实验5-基于WiFi的UDP、TCP传输1](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C5-%E5%9F%BA%E4%BA%8EWiFi%E7%9A%84UDP%E3%80%81TCP%E4%BC%A0%E8%BE%931.pptx) | PowerPoint 课件 |
| [短距离无线通信实验5-基于WiFi的UDP、TCP传输2](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C5-%E5%9F%BA%E4%BA%8EWiFi%E7%9A%84UDP%E3%80%81TCP%E4%BC%A0%E8%BE%932.pptx) | PowerPoint 课件 |
| [短距离无线通信实验6-网络通信基础及综合设计实验](%E7%9F%AD%E8%B7%9D%E7%A6%BB%E6%97%A0%E7%BA%BF%E9%80%9A%E4%BF%A1%E5%AE%9E%E9%AA%8C6-%E7%BD%91%E7%BB%9C%E9%80%9A%E4%BF%A1%E5%9F%BA%E7%A1%80%E5%8F%8A%E7%BB%BC%E5%90%88%E8%AE%BE%E8%AE%A1%E5%AE%9E%E9%AA%8C.pptx) | PowerPoint 课件 |

## 使用说明

工程元数据记录的环境为 **Code Composer Studio 12.8.0、TI ARM Compiler 20.2.7.LTS、CC3200 SDK 1.5.0**。这些是原工程的版本信息，其他版本的兼容性需要自行验证。

1. 准备 CC3200 实验板、CCS 和 SDK，在 CCS 中导入 `djl_code` 下所需的工程。
2. 导入时保留各工程与 `djl_code` 的相对位置，避免仅复制某一个工程后丢失共享配置。
3. 确认 SDK 路径变量和工程链接资源已指向本机安装位置；原工程中保留了原始 SDK 的路径信息。
4. 对实验 4、5、6，将 `djl_code/network_config.example.h` 复制为同目录下的 `network_config.h`，填写本地网络参数。该文件已加入 Git 忽略规则。
5. 在实验 5、6 的 `main.c` 中按接收端环境设置 `IP_ADDR` 和 `PORT_NUM`，再编译、下载和调试。

| 工程 | 对应内容 |
| --- | --- |
| `blinky` | LED / 按键基础 |
| `pwm` | PWM 与串口控制 |
| `out_of_box_3` | I2C 传感器 |
| `out_of_box_4` | Wi-Fi AP / STA 基础连接 |
| `out_of_box_5` | UDP / TCP 通信 |
| `out_of_box_6_1` | 综合传感与网络通信 |

各工程的 `README.html` 保留 SDK 示例说明，具体实验修改以 `main.c` 为准。`Debug/` 和 `Release/` 由 CCS 编译生成，仓库保留源码、链接脚本和目标配置。

历史提交曾包含网络凭据；使用过这些凭据的网络应更换密码。将凭据移出当前源码不会清除 Git 历史中的内容。
