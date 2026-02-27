# 字研 OS (ZiyanOS) - 桌面环境模拟器

![Logo](./src/resources/assets/logo.png)

字研 OS 是一个基于 Qt6 和 QML 开发的桌面环境模拟器，旨在提供一个完整的操作系统桌面体验。它包含了锁屏、桌面、任务栏、窗口管理器以及一系列内置应用程序，适合作为 Qt/QML 桌面应用开发的参考示例。

## 功能特点

- **完整的桌面环境**
  
  - 锁屏界面（带模糊壁纸、大时钟、登录按钮）
  - 桌面壁纸（支持图片和纯色）、桌面图标网格
  - 任务栏（高斯模糊背景、窗口图标切换、系统托盘）
  - 电源菜单（关机、重启、取消）

- **窗口管理器**
  
  - 多窗口打开、最小化/恢复、任务栏切换
  - 窗口标题栏支持自动颜色（与内容背景一致）或自定义颜色
  - 所有窗口继承自 `ZiyanWindow`，统一外观和行为

- **内置应用程序**
  
  - **浏览器**：基于 Qt WebEngine，支持本地文件打开
  - **文件浏览器**：浏览文件系统（基础功能）
  - **计算器**：简单四则运算
  - **文本编辑器**：打开/编辑文本文件（支持只读模式）
  - **图片查看器**：浏览常见图片格式
  - **音乐播放器**：播放音频文件
  - **视频播放器**：播放视频文件
  - **下载管理器**：使用 libcurl 实现 HTTP 下载
  - **Windows 兼容层**：占位窗口，展示全屏模式
  - **设置**：包含关于、壁纸、窗口外观、分辨率、网络等设置项
  - **彩蛋窗口**：隐藏惊喜 😉

- **系统设置**
  
  - **壁纸设置**：选择系统壁纸、自定义图片或纯色背景
  - **窗口设置**：切换标题栏模式（自动/自定义）、调整颜色、实验性模糊扩展
  - **分辨率设置**：预设分辨率切换，更改后倒计时恢复（防止黑屏）
  - **网络信息**：显示本机 IP 地址
  - **关于**：版本信息、开发者、开源协议、彩蛋触发（连续点击版本号）

- **实用工具**
  
  - **日志系统**：记录运行信息到文件，支持从异常重启后恢复
  - **下载管理器**：基于 libcurl，支持队列、进度显示
  - **文件操作**：封装文件系统访问
  - **系统工具**：获取系统信息、设置分辨率、关机重启等（Windows 平台）

## 技术栈

- **Qt 6.8+** (Core, Quick, QuickControls2, Multimedia, WebEngineQuick)
- **QML** 用于界面，C++17 提供后端逻辑
- **libcurl** 实现下载功能
- **Windows API**：分辨率更改、关机重启（检测 `pecmd.ini` 以区分 PE 环境）
- **CMake** 构建系统
- 字体：Noto Color Emoji、思源黑体（Source Han Sans SC）

## 构建与运行

### 环境要求

- CMake 3.16+
- Qt 6.8 或更高版本（包含所需组件）
- Visual Studio 2019+ 或 MinGW（Windows）
- libcurl（已提供预编译库在 `include/` 和 `lib/` 目录下）

### 构建步骤

1. 克隆仓库：
   
   ```bash
   git clone https://github.com/yourname/ZiyanOS.git
   cd ZiyanOS
   ```

2. 确保 Qt6 的 CMake 路径正确（可通过设置 `Qt6_DIR` 环境变量或直接安装到标准路径）。

3. 使用 CMake 配置并生成项目：
   
   ```bash
   mkdir build
   cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

4. 运行生成的可执行文件：
   
   ```bash
   ./ZiyanOS/ZiyanOS.exe   # Windows
   ```

### 命令行参数

- `--restart-after-crash`：指示本次启动是由异常重启引起的，日志系统会记录相应信息。

## 目录结构

```
ZiyanOS/
├── CMakeLists.txt                # 主构建文件
├── include/                       # 第三方库头文件（curl）
├── lib/                           # 第三方库文件（libcurl.lib, libcurl.dll）
├── src/
│   ├── core/                       # 主程序入口
│   ├── modules/                     # 功能模块
│   │   ├── filesystem/              # 文件系统操作
│   │   ├── settings/                # 设置管理器
│   │   ├── system/                  # 系统工具（分辨率、关机等）
│   │   ├── download/                # 下载管理器
│   │   ├── logging/                  # 日志系统
│   │   ├── wallpaper/                # 壁纸管理器
│   │   └── network/                  # 网络信息
│   └── resources/
│       ├── qml/                      # 所有 QML 界面文件
│       │   ├── apps/                  # 各应用程序
│       │   ├── components/             # 可复用组件
│       │   ├── Desktop.qml             # 主桌面
│       │   ├── LockScreen.qml          # 锁屏界面
│       │   ├── PowerWindow.qml         # 电源菜单
│       │   └── WindowManager.qml       # 窗口管理器
│       ├── assets/                    # 图片、动画等资源
│       └── fonts/                      # 字体文件
└── licenses/                        # 第三方协议文本（构建后放置）
```

## 第三方库许可

- **Qt**：LGPL 3.0 / GPL 3.0
- **libcurl**：MIT 许可证
- **Noto Color Emoji**：SIL Open Font License 1.1
- **思源黑体**：SIL Open Font License 1.1

协议文本位于 `licenses/` 目录下，可在设置中的“关于”页面点击查看。

## 致谢

- 感谢 **HardwareLab** 提供精神支持。
- 本项目在开发过程中使用了 **DeepSeek**（包括这个文档）进行代码辅助、问题解答和文档生成。DeepSeek 是由深度求索公司创造的 AI 助手，为项目的快速迭代提供了有力支持。

## 贡献

不接受任何贡献，仅用于展示。

## 许可证

本项目代码部分采用 [MIT 许可证](LICENSE)（需自行添加 LICENSE 文件）。字体和第三方库遵循其各自的许可证。

