# 字研 OS

![MIT License](https://img.shields.io/badge/license-MIT-blue) ![Qt 6.8+](https://img.shields.io/badge/Qt-6.8+-green) ![C++17](https://img.shields.io/badge/C++-17-orange)

![Logo](./src/resources/assets/logo.png)

字研 OS 是一个基于 Qt6 和 QML 开发的桌面环境模拟器，提供完整的操作系统桌面体验——从锁屏到桌面、任务栏、窗口管理器以及一系列内置应用程序，适合作为 Qt/QML 桌面应用开发的参考示例与学习项目。

## 功能特性

### 桌面环境

- **锁屏界面** — 模糊壁纸背景、大时钟显示、登录按钮
- **桌面** — 全屏壁纸（图片 / 纯色）、应用图标网格
- **任务栏** — 半透明模糊背景、活动窗口图标切换、系统托盘
- **电源菜单** — 关机、重启、取消

### 窗口管理

- 多窗口打开、最小化 / 恢复、任务栏切换
- 无边框窗口，标题栏颜色自动跟随内容背景或自定义
- 窗口打开 / 关闭 / 最小化 / 最大化动画
- 所有窗口继承自 `ZiyanWindow`，统一外观和行为
- 支持拖动移动和右下角拖拽缩放

### 内置应用

| 应用 | 说明 |
|------|------|
| 浏览器 | 基于 Qt WebEngine，支持本地文件打开 |
| 文件浏览器 | 浏览文件系统 |
| 计算器 | 简单四则运算 |
| 文本编辑器 | 打开 / 编辑文本文件，支持只读模式 |
| 图片查看器 | 浏览常见图片格式 |
| 音乐播放器 | 播放音频文件 |
| 视频播放器 | 播放视频文件 |
| 下载管理器 | 基于 libcurl 的 HTTP 下载，支持队列和进度显示 |
| Windows 兼容层 | 运行 Windows 可执行文件，全屏模式 |
| 设置 | 壁纸、窗口外观、分辨率、网络、关于页 |
| 彩蛋 | 隐藏惊喜 |

### 系统设置

- **壁纸** — 系统壁纸、自定义图片或纯色背景
- **窗口外观** — 标题栏模式（自动 / 自定义颜色）、颜色调整
- **分辨率** — 预设分辨率切换，更改后倒计时恢复（防止黑屏）
- **网络** — 显示本机 IP 地址
- **关于** — 版本信息、开发者、开源协议、彩蛋触发

### 实用工具

- **日志系统** — 记录运行信息到文件，支持崩溃后恢复
- **下载管理** — 基于 libcurl，队列下载、进度追踪
- **文件操作** — 封装文件系统访问
- **系统工具** — 获取系统信息、设置分辨率、关机 / 重启

## 技术栈

- **Qt 6.8+** — Core, Quick, QuickControls2, Gui, Multimedia, WebEngineQuick
- **QML** 界面 + **C++17** 后端逻辑
- **libcurl** — HTTP 下载功能
- **CMake 3.16+** — 构建系统
- **字体** — Noto Color Emoji、思源黑体（Source Han Sans SC）

## 项目结构

```
ZiyanOS/
├── CMakeLists.txt                     # 主构建文件
├── version.json                       # 版本配置（构建时注入 Git 信息）
├── LICENSE                            # MIT 许可证
├── licenses/                          # 第三方库许可证
│   ├── libcurl_MIT.txt
│   ├── NotoColorEmoji_OFL.txt
│   ├── Qt_LGPL.txt
│   └── SourceHanSans_OFL.txt
└── src/
    ├── core/
    │   └── main.cpp                   # 程序入口
    ├── modules/
    │   ├── apps/                      # 应用注册与管理
    │   │   ├── appinfo.h/cpp          # 应用信息数据类
    │   │   ├── appmodel.h/cpp         # 应用列表模型
    │   │   ├── activewindowsmodel.h/cpp # 活动窗口模型
    │   │   └── appregistry.h/cpp      # 应用注册中心（单例）
    │   ├── filesystem/                # 文件系统操作
    │   │   └── filesystem.h/cpp
    │   ├── settings/                  # 设置与版本管理
    │   │   ├── SettingsManager.h/cpp
    │   │   └── VersionManager.h/cpp
    │   ├── system/                    # 系统工具
    │   │   └── SystemUtils.h/cpp
    │   ├── download/                  # 下载管理器
    │   │   └── DownloadManager.h/cpp
    │   ├── logging/                   # 日志系统
    │   │   └── LogManager.h/cpp
    │   └── network/                   # 网络信息
    │       └── network.h/cpp
    ├── compositor/                    # 合成器（预留）
    └── resources/
        ├── qml/
        │   ├── WindowManager.qml      # 窗口管理器（主入口）
        │   ├── LockScreen.qml         # 锁屏界面
        │   ├── Desktop.qml            # 桌面
        │   ├── Taskbar.qml            # 任务栏
        │   ├── PowerWindow.qml        # 电源菜单
        │   ├── components/            # 可复用组件
        │   │   ├── ZiyanWindow.qml    # 窗口基类组件
        │   │   ├── DesktopIcon.qml    # 桌面图标组件
        │   │   └── FilePicker.qml     # 文件选择器
        │   └── apps/                  # 内置应用
        │       ├── browser/
        │       ├── calculator/
        │       ├── downloadmanager/
        │       ├── easteregg/
        │       ├── filebrowser/
        │       ├── imageviewer/
        │       ├── musicplayer/
        │       ├── settings/
        │       ├── texteditor/
        │       ├── videoplayer/
        │       └── winecompat/
        ├── assets/                    # 图片、动画资源
        ├── config/
        │   └── builtin_apps.json      # 内置应用注册表
        └── fonts/                     # 字体文件
```

## 构建与运行

### 系统依赖

**Arch Linux / Manjaro：**

```bash
sudo pacman -S cmake qt6-base qt6-declarative qt6-quickcontrols2 qt6-multimedia qt6-webengine curl xorg-server-xephyr
```

**Ubuntu 24.04+：**

```bash
sudo apt install cmake qt6-base-dev qt6-declarative-dev qt6-quickcontrols2-6-dev qt6-multimedia-dev qt6-webengine-dev libcurl4-openssl-dev xserver-xephyr
```

### 编译

```bash
cmake -B build
cmake --build build -j$(nproc)
```

编译产物位于 `build/bin/ZiyanOS`。

### 运行

#### 推荐方式：Xephyr 嵌套 X 服务器

Xephyr 提供一个独立的 X11 窗口环境，避免字研 OS 窗口与宿主桌面冲突。

**1. 启动 Xephyr：**

```bash
Xephyr :1 -ac -screen 1280x720 &
```

**2. 在 Xephyr 中运行字研 OS：**

```bash
DISPLAY=:1 QT_QPA_PLATFORM=xcb ./build/bin/ZiyanOS
```

> `QT_QPA_PLATFORM=xcb` 确保 Qt 使用 X11 后端而非 Wayland，这在 Xephyr 环境中是必须的。

#### 直接运行

```bash
./build/bin/ZiyanOS
```

> 直接运行时，字研 OS 的无边框窗口将直接显示在宿主桌面环境中，可能与现有窗口管理器冲突，因此推荐使用 Xephyr。

### 命令行参数

| 参数 | 说明 |
|------|------|
| `--restart-after-crash` | 指示本次启动由崩溃恢复引起，日志系统会记录相应信息 |
| `--help` | 显示帮助信息 |
| `--version` | 显示版本号 |

## QML / C++ API 参考

所有 C++ 后端模块均通过 `qmlRegisterType` 或 `qmlRegisterSingletonType` 注册到 QML 引擎。

---

### ZiyanOS.Apps（单例）

**Import：** `import ZiyanOS.Apps 1.0`

应用注册中心，管理所有应用的注册、启动和窗口追踪。

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `appModel` | `AppModel` | 所有已注册应用的列表模型（只读） |
| `activeWindowsModel` | `ActiveWindowsModel` | 当前活动窗口的列表模型 |

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `launchApp` | `void launchApp(string appId, var parameters)` | 根据 appId 启动应用，可传递参数字典 |
| `getWindowByIndex` | `var getWindowByIndex(int index)` | 获取活动窗口列表中指定索引的窗口对象 |
| `getAppEmoji` | `string getAppEmoji(string appId)` | 获取指定应用的 Emoji 图标 |
| `registerWindow` | `void registerWindow(var window, string appId)` | 将窗口对象注册到应用中心 |
| `unregisterWindow` | `void unregisterWindow(var window)` | 从应用中心注销窗口 |
| `updateWindowSettings` | `void updateWindowSettings()` | 通知所有窗口更新设置 |

**信号**

| 信号 | 说明 |
|------|------|
| `activeWindowsChanged` | 活动窗口列表发生变化 |

---

### AppModel

**角色（Role）**

| 角色名 | 类型 | 说明 |
|--------|------|------|
| `appId` | `string` | 应用唯一标识符 |
| `name` | `string` | 应用名称 |
| `icon` | `string` | 图标资源路径 |
| `emoji` | `string` | Emoji 图标 |
| `displayIcon` | `string` | 实际显示的图标（优先使用 icon，无则用 emoji） |
| `desktopVisible` | `bool` | 是否在桌面显示 |
| `categories` | `stringList` | 分类标签 |
| `isSystemApp` | `bool` | 是否为系统应用 |

---

### ActiveWindowsModel

**角色（Role）**

| 角色名 | 类型 | 说明 |
|--------|------|------|
| `windowObject` | `var` | 窗口 QObject 实例 |
| `title` | `string` | 窗口标题 |
| `icon` | `string` | 图标路径 |
| `emoji` | `string` | Emoji 图标 |
| `appId` | `string` | 所属应用 ID |
| `displayIcon` | `string` | 实际显示图标 |

---

### ZiyanOS.FileSystem

**Import：** `import ZiyanOS.FileSystem 1.0`

文件系统操作封装，可在 QML 中实例化使用。

```qml
FileSystem { id: fs }
```

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `getDrives` | `var getDrives()` | 获取可用磁盘驱动器列表 |
| `getDirectoryContents` | `var getDirectoryContents(string path)` | 获取目录内容列表 |
| `isDir` | `bool isDir(string path)` | 判断路径是否为目录 |
| `getFileName` | `string getFileName(string path)` | 获取文件名 |
| `getFileSize` | `string getFileSize(string path)` | 获取格式化的文件大小（如 "1.5 MB"） |
| `getFileType` | `string getFileType(string path)` | 获取文件类型描述 |
| `getParentDirectory` | `string getParentDirectory(string path)` | 获取父目录路径 |
| `getFileModifiedTime` | `datetime getFileModifiedTime(string path)` | 获取文件修改时间 |
| `readFile` | `string readFile(string filePath)` | 读取文本文件全部内容 |
| `writeFile` | `bool writeFile(string filePath, string content)` | 写入文本文件，成功返回 `true` |
| `createDirectory` | `bool createDirectory(string path)` | 创建目录 |
| `fileExists` | `bool fileExists(string filePath)` | 判断文件是否存在 |
| `deleteFile` | `bool deleteFile(string filePath)` | 删除文件 |
| `deleteDirectory` | `bool deleteDirectory(string path)` | 删除目录 |
| `renameFile` | `bool renameFile(string oldPath, string newPath)` | 重命名 / 移动文件 |

**信号**

| 信号 | 参数 | 说明 |
|------|------|------|
| `errorOccurred` | `string errorMessage` | 操作出错时发射 |
| `fileOperationCompleted` | `string message` | 操作完成时发射 |

---

### ZiyanOS.SettingsManager

**Import：** `import ZiyanOS.SettingsManager 1.0`

设置管理器，基于 `QSettings` 持久化。

```qml
SettingsManager { id: settings }
```

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `desktopBackground` | `string` | 桌面背景（颜色值或图片路径），可读写 |

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `saveSettings` | `void saveSettings()` | 保存当前设置到磁盘 |
| `loadSettings` | `void loadSettings()` | 从磁盘加载设置 |
| `isValidColor` | `bool isValidColor(string color)` | 判断字符串是否为有效的 CSS 颜色值 |

**信号**

| 信号 | 参数 | 说明 |
|------|------|------|
| `desktopBackgroundChanged` | `string background` | 桌面背景改变时发射 |

---

### ZiyanOS.SystemUtils

**Import：** `import ZiyanOS.SystemUtils 1.0`

系统工具类，提供电源控制、分辨率切换和进程管理。

```qml
SystemUtils { id: sysUtils }
```

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `hasPecmdIni` | `bool hasPecmdIni()` | 检测是否运行在 PE 环境 |
| `shutdownWithCommand` | `void shutdownWithCommand()` | 执行关机命令 |
| `rebootWithCommand` | `void rebootWithCommand()` | 执行重启命令 |
| `normalQuit` | `void normalQuit()` | 正常退出应用 |
| `setResolution` | `bool setResolution(int width, int height)` | 设置屏幕分辨率，成功返回 `true` |
| `restoreOriginalResolution` | `bool restoreOriginalResolution()` | 恢复原始分辨率 |
| `startProgram` | `bool startProgram(string program, string arguments)` | 启动外部程序 |
| `isProgramRunning` | `bool isProgramRunning()` | 检查外部程序是否在运行 |
| `terminateProgram` | `bool terminateProgram()` | 终止正在运行的外部程序 |

**信号**

| 信号 | 参数 | 说明 |
|------|------|------|
| `shutdownStarted` | — | 关机开始 |
| `shutdownFailed` | `string error` | 关机失败 |
| `rebootStarted` | — | 重启开始 |
| `rebootFailed` | `string error` | 重启失败 |
| `programStarted` | — | 外部程序已启动 |
| `programFinished` | — | 外部程序已结束 |

---

### ZiyanOS.DownloadManager

**Import：** `import ZiyanOS.DownloadManager 1.0`

基于 libcurl 的 HTTP 下载管理器。

```qml
DownloadManager { id: dlManager }
```

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `ignoreSslErrors` | `bool` | 是否忽略 SSL 证书验证错误，可读写 |

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `startDownload` | `void startDownload(string url, string savePath)` | 开始下载指定 URL 到本地路径 |
| `cancelDownload` | `void cancelDownload()` | 取消当前下载 |

**信号**

| 信号 | 参数 | 说明 |
|------|------|------|
| `downloadStarted` | `string fileName, string fileSize` | 下载开始，携带文件名和格式化大小 |
| `downloadProgress` | `int bytesReceived, int bytesTotal` | 下载进度更新 |
| `downloadFinished` | `string filePath` | 下载完成，携带保存路径 |
| `downloadError` | `string errorMessage` | 下载出错 |
| `ignoreSslErrorsChanged` | `bool ignore` | SSL 忽略设置变更 |

---

### ZiyanOS.LogManager

**Import：** `import ZiyanOS.LogManager 1.0`

日志管理系统，自动捕获 `qDebug` / `qInfo` / `qWarning` / `qCritical` 输出及 QML 错误。

```qml
LogManager { id: logMgr }
```

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `isInitialized` | `bool` | 日志系统是否已初始化（只读） |

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `initialize` | `void initialize()` | 初始化日志系统（通常在 `main.cpp` 中自动调用） |
| `writeLog` | `void writeLog(string message, string category)` | 手动写入日志，`category` 默认为 `"INFO"` |
| `logFilePath` | `string logFilePath()` | 获取当前日志文件路径 |
| `setQmlEngine` | `void setQmlEngine(var engine)` | 设置 QML 引擎以捕获 QML 警告（通常自动调用） |

**信号**

| 信号 | 参数 | 说明 |
|------|------|------|
| `initialized` | — | 日志系统初始化完成 |
| `logMessage` | `string message, string category, string timestamp` | 新的日志消息 |
| `qmlError` | `string errorMessage, string url, int line` | 捕获到 QML 错误 |

---

### ZiyanOS.Network

**Import：** `import ZiyanOS.Network 1.0`

网络信息查询。

```qml
NetworkManager { id: netMgr }
```

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `localIP` | `string` | 本机局域网 IP 地址（只读） |

**信号**

| 信号 | 说明 |
|------|------|
| `localIPChanged` | IP 地址发生变化 |

---

### ZiyanOS.VersionManager（单例）

**Import：** `import ZiyanOS.VersionManager 1.0`

版本信息管理，从构建时生成的 `version.json` 读取。

**属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `version` | `string` | 版本号（如 `"2.0.0"`），只读 |
| `buildTime` | `string` | 构建时间，只读 |
| `gitCommit` | `string` | Git 短提交哈希，只读 |
| `gitBranch` | `string` | Git 分支名，只读 |
| `buildType` | `string` | 构建类型（如 `"Develop"`），只读 |
| `showExitButton` | `bool` | 是否显示退出按钮，只读 |

---

### QML 组件：ZiyanWindow

**文件：** `src/resources/qml/components/ZiyanWindow.qml`

所有应用窗口的基类组件，提供统一的标题栏、窗口控制和动画。

```qml
ZiyanWindow {
    windowTitle: "我的窗口"
    contentBackground: "#ffffff"
    titleBarColor: "#3498db"
    // ... contentItem 中放置内容
}
```

**属性**

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `windowTitle` | `string` | `"窗口"` | 标题栏显示文字 |
| `titleBarColor` | `color` | 与 `contentBackground` 一致 | 标题栏背景颜色 |
| `titleBarColorOpacity` | `real` | `1.0` | 标题栏颜色透明度 |
| `titleTextColor` | `color` | 自动计算 | 标题栏文字颜色（根据背景亮度自动黑/白） |
| `contentBackground` | `color` | `"#ecf0f1"` | 内容区背景颜色 |
| `contentItem` | `alias` | — | 内容区容器，子项通过此属性添加 |
| `allowClose` | `bool` | `true` | 是否允许关闭窗口 |
| `showMinimizeButton` | `bool` | `true` | 是否显示最小化按钮 |
| `showMaximizeButton` | `bool` | `true` | 是否显示最大化按钮 |
| `showCloseButton` | `bool` | `true` | 是否显示关闭按钮 |
| `taskbarHeight` | `int` | `50` | 任务栏高度（影响最大化计算） |
| `isMinimized` | `bool` | `false` | 窗口是否处于最小化状态 |
| `isMaximized` | `bool` | `false` | 窗口是否处于最大化状态 |

**信号**

| 信号 | 说明 |
|------|------|
| `windowClosing` | 窗口即将关闭 |
| `windowActivated` | 窗口获得焦点 |
| `windowMinimized` | 窗口最小化完成 |
| `windowMaximized` | 窗口最大化完成 |
| `windowRestored` | 窗口从最小化 / 最大化恢复 |

**方法**

| 方法 | 签名 | 说明 |
|------|------|------|
| `showWindow` | `void showWindow(int x, int y)` | 显示窗口并播放入场动画，参数可选（默认居中） |
| `startCloseAnimation` | `void startCloseAnimation()` | 播放关闭动画并关闭窗口 |
| `minimizeWindow` | `void minimizeWindow()` | 最小化窗口 |
| `restoreWindow` | `void restoreWindow()` | 从最小化恢复窗口 |
| `toggleMaximize` | `void toggleMaximize()` | 切换最大化 / 恢复状态 |

---

### QML 组件：DesktopIcon

**文件：** `src/resources/qml/components/DesktopIcon.qml`

桌面图标组件，用于在桌面上展示应用快捷方式。

---

### QML 组件：FilePicker

**文件：** `src/resources/qml/components/FilePicker.qml`

文件选择对话框组件，提供文件 / 目录浏览和选择功能。

---

## 内置应用注册表

内置应用通过 `src/resources/config/builtin_apps.json` 定义：

| ID | 名称 | Emoji | 分类 | 默认尺寸 |
|----|------|-------|------|----------|
| `browser` | 浏览器 | 🌐 | internet | 1024×768 |
| `filebrowser` | 文件浏览器 | 📁 | system | 800×600 |
| `calculator` | 计算器 | 🧮 | utilities | 400×500 |
| `texteditor` | 文本编辑器 | 📝 | utilities | 600×400 |
| `imageviewer` | 图片查看器 | 🖼️ | multimedia | 800×600 |
| `musicplayer` | 音乐播放器 | 🎵 | multimedia | 600×500 |
| `videoplayer` | 视频播放器 | 🎬 | multimedia | 800×600 |
| `downloadmanager` | 下载管理器 | ⬇️ | utilities | 700×500 |
| `settings` | 设置 | ⚙️ | system | 800×600 |
| `easteregg` | 彩蛋 | 🥚 | fun | 400×300 |

### 应用注册格式

`builtin_apps.json` 中每个应用对象的字段：

```json
{
    "id": "应用唯一标识符",
    "name": "显示名称",
    "icon": "qrc:/qt/qml/ZiyanOS/src/resources/assets/图标文件.png",
    "emoji": "🌐",
    "desktopVisible": true,
    "launchType": "qml",
    "launchTarget": "qrc:/qt/qml/ZiyanOS/src/resources/qml/apps/.../Window.qml",
    "categories": ["分类"],
    "defaultSize": { "width": 800, "height": 600 },
    "minimumSize": { "width": 400, "height": 300 },
    "isSystemApp": true
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `string` | 是 | 应用唯一标识符 |
| `name` | `string` | 是 | 应用显示名称 |
| `icon` | `string` | 否 | 图标资源路径（qrc 路径） |
| `emoji` | `string` | 否 | Emoji 备选图标 |
| `desktopVisible` | `bool` | 否 | 是否在桌面显示，默认 `true` |
| `launchType` | `string` | 是 | 启动类型：`"qml"` / `"native"` / `"webview"` |
| `launchTarget` | `string` | 是 | QML 文件路径 / 可执行文件路径 / URL |
| `categories` | `[string]` | 否 | 分类标签列表 |
| `defaultSize` | `object` | 否 | 默认窗口尺寸 `{ "width", "height" }` |
| `minimumSize` | `object` | 否 | 最小窗口尺寸 |
| `isSystemApp` | `bool` | 否 | 是否为系统应用，默认 `false` |

## 版本构建信息

构建时 CMake 会自动从 `version.json` 和 Git 生成版本信息，替换以下占位符：

| 占位符 | 替换为 |
|--------|--------|
| `@TIME@` | 构建时间戳 |
| `@GIT_COMMIT@` | Git 短提交哈希 |
| `@GIT_BRANCH@` | 当前 Git 分支名 |

生成的 `version.json` 被写入构建目录，供 `VersionManager` 在运行时读取。

## 第三方库许可证

| 库 / 资源 | 许可证 | 文件 |
|-----------|--------|------|
| Qt 6 | LGPL 3.0 / GPL 3.0 | `licenses/Qt_LGPL.txt` |
| libcurl | MIT | `licenses/libcurl_MIT.txt` |
| Noto Color Emoji | SIL OFL 1.1 | `licenses/NotoColorEmoji_OFL.txt` |
| 思源黑体 (Source Han Sans SC) | SIL OFL 1.1 | `licenses/SourceHanSans_OFL.txt` |

## 致谢

- 感谢 **HardwareLab** 提供精神支持。
- 本项目在开发过程中使用了 **DeepSeek** 进行代码辅助、问题解答和文档生成。

## 许可证

本项目代码部分采用 [MIT 许可证](LICENSE)。字体和第三方库遵循其各自的许可证。

Copyright © 2026 SomeoneHX
