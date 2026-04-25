cmake_minimum_required(VERSION 3.16)

# ------------------------------------------------------------------
# 版本管理配置（需要在 find_package 之前执行）
# ------------------------------------------------------------------

# 获取Git信息
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT
        TIMEOUT 5
    )
    string(STRIP "${GIT_COMMIT}" GIT_COMMIT)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        TIMEOUT 5
    )
    string(STRIP "${GIT_BRANCH}" GIT_BRANCH)
else()
    set(GIT_COMMIT "unknown")
    set(GIT_BRANCH "unknown")
endif()

# 获取构建时间
string(TIMESTAMP ZIYANOS_BUILD_TIME)

# 定义版本配置路径
set(VERSION_JSON_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/version.json)
set(VERSION_JSON_DEST ${CMAKE_BINARY_DIR}/bin/version.json)

# 确保目标目录存在
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 读取源配置文件
file(READ ${VERSION_JSON_SOURCE} VERSION_JSON_CONTENT)

# 替换变量 - 使用 @TIME@ 等不会被 CMake 解析的占位符
string(REPLACE "@TIME@" "${ZIYANOS_BUILD_TIME}" VERSION_JSON_PROCESSED "${VERSION_JSON_CONTENT}")
string(REPLACE "@GIT_COMMIT@" "${GIT_COMMIT}" VERSION_JSON_PROCESSED "${VERSION_JSON_PROCESSED}")
string(REPLACE "@GIT_BRANCH@" "${GIT_BRANCH}" VERSION_JSON_PROCESSED "${VERSION_JSON_PROCESSED}")

# 写入目标配置文件
file(WRITE ${VERSION_JSON_DEST} "${VERSION_JSON_PROCESSED}")

# 定义预处理宏，供C++代码使用
add_compile_definitions(ZIYANOS_VERSION_JSON_PATH="${VERSION_JSON_DEST}")

# ------------------------------------------------------------------

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
# 使用系统 curl 库（不再自行编译子模块）
# ------------------------------------------------------------------
find_package(CURL REQUIRED)

# 某些发行版可能不导出 CURL::libcurl 目标，则手动创建导入目标
if(NOT TARGET CURL::libcurl)
    add_library(CURL::libcurl UNKNOWN IMPORTED)
    set_target_properties(CURL::libcurl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIRS}"
        IMPORTED_LOCATION "${CURL_LIBRARIES}"
    )
endif()

# ------------------------------------------------------------------
# 版本管理配置
# ------------------------------------------------------------------

# 使用外部命令获取Git信息
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT
        TIMEOUT 5
    )
    string(STRIP "${GIT_COMMIT}" GIT_COMMIT)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        TIMEOUT 5
    )
    string(STRIP "${GIT_BRANCH}" GIT_BRANCH)
else()
    set(GIT_COMMIT "unknown")
    set(GIT_BRANCH "unknown")
 endif()

# 获取构建时间
string(TIMESTAMP ZIYANOS_BUILD_TIME)

# 定义版本配置路径
set(VERSION_JSON_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/version.json)
set(VERSION_JSON_DEST ${CMAKE_BINARY_DIR}/bin/version.json)

# 确保目标目录存在
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 读取源配置文件
file(READ ${VERSION_JSON_SOURCE} VERSION_JSON_CONTENT)

# 替换变量 - 使用 @TIME@ 等不会被 CMake 解析的占位符
string(REPLACE "@TIME@" "${ZIYANOS_BUILD_TIME}" VERSION_JSON_PROCESSED "${VERSION_JSON_CONTENT}")
string(REPLACE "@GIT_COMMIT@" "${GIT_COMMIT}" VERSION_JSON_PROCESSED "${VERSION_JSON_PROCESSED}")
string(REPLACE "@GIT_BRANCH@" "${GIT_BRANCH}" VERSION_JSON_PROCESSED "${VERSION_JSON_PROCESSED}")

# 写入目标配置文件
file(WRITE ${VERSION_JSON_DEST} "${VERSION_JSON_PROCESSED}")

# 定义预处理宏，供C++代码使用
add_compile_definitions(ZIYANOS_VERSION_JSON_PATH="${VERSION_JSON_DEST}")

# ------------------------------------------------------------------
# 收集所有C++源文件
set(CPP_SOURCES
    src/modules/apps/appinfo.cpp
    src/modules/apps/appregistry.cpp
    src/modules/apps/appmodel.cpp
    src/modules/apps/activewindowsmodel.cpp
    src/modules/filesystem/filesystem.cpp
    src/modules/settings/SettingsManager.cpp
    src/modules/settings/VersionManager.cpp
    src/modules/system/SystemUtils.cpp
    src/modules/download/DownloadManager.cpp
    src/modules/logging/LogManager.cpp
    src/modules/network/network.cpp
    src/core/main.cpp
)

# 收集所有头文件
set(HEADER_FILES
    src/modules/apps/appinfo.h
    src/modules/apps/appregistry.h
    src/modules/apps/appmodel.h
    src/modules/apps/activewindowsmodel.h
    src/modules/filesystem/filesystem.h
    src/modules/settings/SettingsManager.h
    src/modules/settings/VersionManager.h
    src/modules/system/SystemUtils.h
    src/modules/download/DownloadManager.h
    src/modules/logging/LogManager.h
    src/modules/network/network.h
)

# 添加可执行文件
add_executable(ZiyanOS
    ${CPP_SOURCES}
    ${HEADER_FILES}
)

set_target_properties(ZiyanOS PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
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
        src/resources/qml/apps/settings/ResolutionPage.qml
        src/resources/qml/apps/settings/NetworkPage.qml
        # 应用：下载管理器
        src/resources/qml/apps/downloadmanager/DownloadManagerWindow.qml
        # 应用：彩蛋
        src/resources/qml/apps/easteregg/EasterEggWindow.qml
    RESOURCES
        src/resources/assets/logo.png
        src/resources/assets/logo_animation.gif
        src/resources/fonts/NotoColorEmoji.ttf
        src/resources/fonts/SourceHanSansSC-Medium-2.otf
        src/resources/config/builtin_apps.json
)

# 设置包含目录（系统 curl 头文件路径已通过 CURL::libcurl 自动处理）
target_include_directories(ZiyanOS PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/apps
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/filesystem
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/settings
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/system
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/download
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/mouseoverlay
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/logging
    ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/network
)

# 链接Qt库和CURL库
target_link_libraries(ZiyanOS
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Gui
        Qt6::Multimedia
        Qt6::WebEngineQuick
        CURL::libcurl
)

# Linux 特定链接库（pthread、dl 通常为隐式依赖，显式添加确保兼容）
if(LINUX)
    target_link_libraries(ZiyanOS PRIVATE pthread dl)
endif()

# 复制 licenses 目录到输出目录
file(COPY ${CMAKE_SOURCE_DIR}/licenses
     DESTINATION ${CMAKE_BINARY_DIR}/bin)

# 设置目标属性
set_target_properties(ZiyanOS PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)