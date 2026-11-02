# INFT431005 · 无线通信系统虚拟仿真实验

[返回课程导航](../README.md) · [通用使用指南](../docs/USAGE.md)

包括网络认知、网络配置与 LTE 物理层 MIMO 仿真资料。

## 资料导航

| 入口 | 内容 |
| --- | --- |
| [实验 1](1-%E7%A7%BB%E5%8A%A8%E9%80%9A%E4%BF%A1%E7%B3%BB%E7%BB%9F%E7%BD%91%E7%BB%9C%E7%BB%93%E6%9E%84%E8%AE%A4%E7%9F%A5%E4%B8%8E%E7%8E%B0%E7%BD%91%E8%AE%BE%E5%A4%87%E4%BD%93%E9%AA%8C.docx) | 移动通信系统网络结构认知与现网设备体验 |
| [实验 2](2-%E7%BD%91%E7%BB%9C%E8%A7%84%E5%88%92%E8%AE%BE%E8%AE%A1%E4%B8%8E%E6%A0%B8%E5%BF%83%E7%BD%91%E5%BC%80%E9%80%9A%E9%85%8D%E7%BD%AE.docx) | 网络规划设计与核心网开通配置 |
| [实验 3](3-%E6%97%A0%E7%BA%BF%E7%BD%91%E5%BC%80%E9%80%9A%E9%85%8D%E7%BD%AE%E4%B8%8E%E7%BD%91%E7%BB%9C%E9%AA%8C%E8%AF%81.docx) | 无线网开通配置与网络验证 |
| [实验 4](4-LTE%E7%89%A9%E7%90%86%E5%B1%82MIMO%E6%8A%80%E6%9C%AF%E5%8E%9F%E7%90%86%E4%B8%8E%E9%AA%8C%E8%AF%81.docx) | LTE 物理层 MIMO 技术原理与验证 |
| [仿真代码、数据与图片](code) | Alamouti、V-BLAST 及性能对比 |
| [原始参考程序包](%E5%8F%82%E8%80%83%E7%A8%8B%E5%BA%8F%E5%8C%85) | 教学参考脚本及部分数据 |

## 使用说明

MATLAB 脚本使用 `qammod`、`qamdemod`、`biterr` 等函数，需要 Communications Toolbox。运行自编脚本时，将当前文件夹设为 `code`。

| 脚本 | 用途 |
| --- | --- |
| `tiaozhi_diffrence.m` | 生成 2 发 1 收在 QPSK、8QAM、16QAM 下的数据 |
| `doubleRX.m` | 生成 2 发 2 收的相应数据 |
| `Ber_qam_2T2R.m` | 读取上述六组数据并比较曲线 |
| `datdsize_diffrence.m` | 比较不同仿真样本量 |
| `VBLAST_zf_2T2R.m` / `VBLAST_zf_4T4R.m` | 2×2 / 4×4 V-BLAST 检测仿真 |
| `VLBLAT_zf_2T2R.m` / `VLBLAT_zf_4T4R.m` | 历史命名的变体，运行前查看 `M`、`Nt`、`Nr` |
| `compare_2T2R.m` | V-BLAST 与 Alamouti 对比，默认 `M = 16` |

建议先运行 `tiaozhi_diffrence` 和 `doubleRX`，再运行 `Ber_qam_2T2R`。历史 MAT 文件内部的误码率变量名并不完全一致，绘图脚本兼容 `ber1` 与对应的 `ber2` / `ber3`，并检查信噪比轴。

V-BLAST 与对比脚本的新结果写入 `code/results/`，文件名包含调制方式和天线数；相同配置再次运行会覆盖同名结果。其余历史脚本仍在当前目录保存结果，建议在工作副本中运行。

`参考程序包` 保留教学原稿，部分绘图所需 MAT 文件需要先自行生成。仿真使用随机信道；重现实验时请记录随机种子、样本量、调制阶数与功率定义。V-BLAST 和 Alamouti 的传输速率不同，当前对比采用相同总发射功率及接收噪声定义，不能直接解读为相同频谱效率下的性能比较。
