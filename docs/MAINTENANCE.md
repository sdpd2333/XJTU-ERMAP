# 仓库维护与验证

[返回项目首页](../README.md) · [贡献指南](../CONTRIBUTING.md)

## 日常检查

在仓库根目录执行，要求 Python 3.10+ 和 Git：

```bash
git add <本次新增或修改的文件>
python scripts/check_repository.py
python -m unittest discover -s tests -p "test_*.py" -v
git diff --check
git diff --cached --check
```

检查脚本根据 Git 索引列出文件，再读取工作区内容；新增文件先暂存，删除文件使用 `git rm`。正式提交前检查暂存差异，确保验证过的版本就是准备提交的版本。

脚本会检查：

- 每个课程目录有说明，并出现在根 README 的课程导航中。
- Markdown 的 UTF-8 编码、相对文件 / 目录链接以及标题锚点。
- 路径的大小写冲突、丢失文件、Office 锁文件和已知编译缓存。
- 本地网络配置未加入版本控制。

链接检查覆盖本仓库使用的内联 Markdown 链接格式，支持百分号编码、带空格的尖括号路径及标题锚点；不检查外部网站、HTML 链接或压缩包内部链接。CI 在 Linux 和 Windows 上运行相同检查及 Python 回归测试。

## 文件保留原则

- 报告、指导书、课件、图片、音频、MAT 数据、Simulink 模型和原始参考代码属于资料。
- `Debug/`、`Release/`、`slprj/` 和 Office `~$` 文件属于可再生成内容，使用 `.gitignore` 防止误提交。
- 同名或相似目录需要比较内容后再判断是否重复。通信原理实验中的两份 `example_s` 存在不同源码和独有截图，均予以保留。
- 历史源码存在不同编码。修改时保留原有编码，或在确需转换时明确说明范围；不要批量格式化第三方示例。

清理当前分支中的构建缓存会减少检出文件数量，但不会缩小已有 Git 历史。下载时使用浅克隆可以减少历史获取量。

## 本轮代码修正的验证范围

维护改动修正了 51 单片机位选越界与无效键值返回、信号实验的固定样本数越界，以及 MIMO 仿真的输出命名、结果字段和绘图数据读取。V-BLAST 仿真采用预分配数组及线性方程求解，保留原实验的检测流程。

可使用 `python scripts/check_firmware.py` 在安装 GCC 的主机上编译并检查 51 示例的边界行为。检查使用模拟寄存器和有限次数的主循环，不能验证 Keil C51 代码生成或实验板的时序、电气行为。

MATLAB / Communications Toolbox、Keil C51、CCS 与目标实验板的完整实验验证需要相应环境。代码审阅和通用检查不能替代这些验证；提交记录应明确实际完成的检查，避免将历史结果当作本轮运行结果。

具备 MATLAB 时，可在仓库根目录执行 `addpath('tests'); test_matlab`，验证短音频频谱求和、样本截断、历史误码率字段兼容与无效数据处理。完整随机信道仿真还需要 Communications Toolbox。

## 网络配置

CC3200 的网络凭据放在被忽略的 `djl_code/network_config.h` 中，公开仓库只维护示例配置。历史提交中出现过的凭据需要更换；当前改动未重写仓库历史。
