cmake_minimum_required(VERSION 3.16)

project(ZiyanOS VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找Qt6组件
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    QuickControls2
    Gui
    Multimedia
    WebEngineQuick
)

# 启用Qt的CMake集成
qt_standard_project_setup(REQUIRES 6.8)

# ------------------------------------------------------------------
# curl 子模块构建配置
# ------------------------------------------------------------------

# 检查子模块是否存在（若不存在则提示用户初始化）
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/third_party/curl/CMakeLists.txt")
    message(FATAL_ERROR
        "curl submodule not found. Please run:\n"
        "  git submodule update --init --recursive"
    )
endif()

# 设置 curl 构建选项（根据需求调整）
set(CURL_USE_SCHANNEL ON  CACHE BOOL "使用 Windows 原生 SSL (Schannel)" FORCE)   # Windows 内置 SSL，无需 OpenSSL
set(CURL_DISABLE_LDAP  ON  CACHE BOOL "禁用 LDAP" FORCE)
set(CURL_DISABLE_TELNET ON CACHE BOOL "禁用 Telnet" FORCE)
set(CURL_DISABLE_POP3  ON  CACHE BOOL "禁用 POP3" FORCE)
set(CURL_DISABLE_IMAP  ON  CACHE BOOL "禁用 IMAP" FORCE)
set(CURL_DISABLE_SMTP  ON  CACHE BOOL "禁用 SMTP" FORCE)
set(CURL_DISABLE_RTSP  ON  CACHE BOOL "禁用 RTSP" FORCE)
set(CURL_USE_LIBPSL     OFF CACHE BOOL "不使用 LIBPSL" FORCE)
set(CURL_STATICLIB     OFF CACHE BOOL "构建动态库 (DLL)" FORCE)                   # 与原预编译库一致，动态链接
# 若需要静态链接，可将上面改为 ON，并移除后续 DLL 复制步骤

# 添加 curl 子目录
add_subdirectory(third_party/curl)

# ------------------------------------------------------------------
# 收集所有C++源文件
set(CPP_SOURCES
    src/modules/filesystem/filesystem.cpp
    src/modules/settings/SettingsManager.cpp
    src/modules/system/SystemUtils.cpp
    src/modules/download/DownloadManager.cpp
    src/modules/logging/LogManager.cpp
    src/modules/wallpaper/WallpaperManager.cpp
    src/modules/network/network.cpp
    src/core/main.cpp
)

# 收集所有头文件
set(HEADER_FILES
    src/modules/filesystem/filesystem.h
    src/modules/settings/SettingsManager.h
    src/modules/system/SystemUtils.h
    src/modules/download/DownloadManager.h
    src/modules/logging/LogManager.h
    src/modules/wallpaper/WallpaperManager.h
    src/modules/network/network.h
)

# 添加可执行文件
add_executable(ZiyanOS
    ${CPP_SOURCES}
    ${HEADER_FILES}
)

# 配置QML模块
qt_add_qml_module(ZiyanOS
    URI ZiyanOS
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/ZiyanOS
    QML_FILES
        # 主桌面
        src/resources/qml/Desktop.qml
        # 锁屏界面和主控制器
        src/resources/qml/LockScreen.qml
        src/resources/qml/WindowManager.qml
        src/resources/qml/PowerWindow.qml
        # 通用组件
        src/resources/qml/components/DesktopIcon.qml
        src/resources/qml/components/ZiyanWindow.qml
        src/resources/qml/components/FilePicker.qml
        # 应用：计算器
        src/resources/qml/apps/calculator/CalculatorWindow.qml
        src/resources/qml/apps/calculator/CalculatorButton.qml
        # 应用：文本编辑器
        src/resources/qml/apps/texteditor/TextEditor.qml
        # 应用：图片查看器
        src/resources/qml/apps/imageviewer/ImageViewer.qml
        # 应用：音乐播放器
        src/resources/qml/apps/musicplayer/MusicPlayer.qml
        # 应用：视频播放器
        src/resources/qml/apps/videoplayer/VideoPlayer.qml
        # 应用：网页浏览器
        src/resources/qml/apps/browser/BrowserWindow.qml
        src/resources/qml/apps/browser/WelcomePage.qml
        src/resources/qml/apps/browser/ErrorPage.qml
        src/resources/qml/apps/browser/MaintenancePage.qml
        # 应用：文件浏览器
        src/resources/qml/apps/filebrowser/FileBrowserWindow.qml
        # 应用：设置
        src/resources/qml/apps/settings/SettingsWindow.qml
        src/resources/qml/apps/settings/AboutPage.qml
        src/resources/qml/apps/settings/WallpaperPage.qml
        src/resources/qml/apps/settings/WindowSettingsPage.qml
        src/resources/qml/apps/settings/ResolutionPage.qml
        src/resources/qml/apps/settings/NetworkPage.qml
        # 应用：下载管理器
        src/resources/qml/apps/downloadmanager/DownloadManagerWindow.qml
        # 应用：Windows兼容层
        src/resources/qml/apps/winecompat/WineCompatLayer.qml
        # 应用：彩蛋
        src/resources/qml/apps/easteregg/EasterEggWindow.qml
    RESOURCES
        src/resources/assets/logo.png
        src/resources/assets/logo_animation.gif
        src/resources/assets/hwl.png
        src/resources/fonts/NotoColorEmoji.ttf
        src/resources/fonts/SourceHanSansSC-Medium-2.otf
)

# 设置包含目录（已移除手动添加的 include/curl 路径，因为 curl 目标会自动处理）
target_include_directories(ZiyanOS PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/filesystem
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/settings
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/system
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/download
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/mouseoverlay
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/logging
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/wallpaper
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/network
)

# 链接Qt库和CURL库（使用 CURL::libcurl 目标）
target_link_libraries(ZiyanOS
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Gui
        Qt6::Multimedia
        Qt6::WebEngineQuick
        CURL::libcurl          # 替换原有的 libcurl
)

# Windows特定的链接库（curl 自身已处理依赖，但保留原有链接项无妨）
if(WIN32)
    target_link_libraries(ZiyanOS PRIVATE
        ws2_32     # Winsock
        crypt32    # Crypto API
    )

    # 复制 curl DLL 到输出目录（仅在动态库构建时）
    if(NOT CURL_STATICLIB)
        add_custom_command(TARGET ZiyanOS POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:CURL::libcurl>"          # 生成器表达式，展开为 DLL 的完整路径
            "$<TARGET_FILE_DIR:ZiyanOS>/"
            COMMENT "Copying curl DLL to output directory"
        )
    endif()

    # 设置Windows子系统
    set_target_properties(ZiyanOS PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

# 设置目标属性
set_target_properties(ZiyanOS PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)
