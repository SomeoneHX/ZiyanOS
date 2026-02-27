import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.FileSystem

ZiyanWindow {
    id: filePicker
    width: 700
    height: 500
    windowTitle: "选择文件"
    titleBarColor: "#9b59b6"

    property bool selectFolder: false
    property string selectedPath: ""
    property var fileFilters: [] // 文件过滤器，如 [".txt", ".jpg"]
    property string defaultFileName: "" // 默认文件名（用于保存模式）
    property string fileMode: "open" // "open" 或 "save"
    property string selectedFileType: "" // 存储当前选中的文件类型，空字符串表示所有文件

    signal fileSelected(string path)
    signal canceled()

    property string currentPath: ""
    property var fileSystem: FileSystem {}

    contentItem: Item {
        anchors.fill: parent

        // 地址栏和导航栏
        Rectangle {
            id: navigationBar
            width: parent.width
            height: 70
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1

            Column {
                spacing: 5
                anchors.fill: parent
                anchors.margins: 5

                // 第一行：导航按钮
                Row {
                    width: parent.width
                    height: 30
                    spacing: 10

                    // 返回计算机按钮
                    Rectangle {
                        width: 100
                        height: 30
                        color: currentPath === "" ? "#bdc3c7" : "#3498db"
                        radius: 4

                        Text {
                            text: "← 计算机"
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: currentPath !== ""
                            onClicked: navigateTo("")
                        }
                    }

                    // 向上按钮
                    Rectangle {
                        width: 30
                        height: 30
                        color: parentDirectory === "" ? "#bdc3c7" : "#3498db"
                        radius: 4

                        Text {
                            text: "↑"
                            color: "white"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: parentDirectory !== ""
                            onClicked: {
                                if (parentDirectory !== "") {
                                    navigateTo(parentDirectory)
                                }
                            }
                        }
                    }
                }

                // 第二行：地址显示和文件名输入
                Row {
                    width: parent.width
                    height: 30
                    spacing: 10

                    Text {
                        text: "位置:"
                        color: "#2c3e50"
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // 地址显示
                    Rectangle {
                        width: parent.width - (selectFolder ? 150 : 300)
                        height: 25
                        color: "white"
                        border.color: "#bdc3c7"
                        border.width: 1
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: currentPath === "" ? "计算机" : currentPath
                            color: "#2c3e50"
                            font.pixelSize: 12
                            elide: Text.ElideLeft
                            anchors.fill: parent
                            anchors.margins: 5
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // 文件名输入（非文件夹选择模式时显示）
                    Rectangle {
                        width: 200
                        height: 25
                        color: "white"
                        border.color: "#bdc3c7"
                        border.width: 1
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !selectFolder

                        TextInput {
                            id: fileNameInput
                            anchors.fill: parent
                            anchors.margins: 5
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                            text: defaultFileName

                            onTextChanged: {
                                updateSelectedPath()
                            }
                        }

                        // 占位符文本
                        Text {
                            text: "文件名"
                            color: "#95a5a6"
                            font.pixelSize: 12
                            anchors {
                                left: parent.left
                                leftMargin: 5
                                verticalCenter: parent.verticalCenter
                            }
                            visible: fileNameInput.text === ""
                        }
                    }
                }
            }
        }

        // 文件列表区域
        Rectangle {
            width: parent.width
            height: parent.height - navigationBar.height - 60
            anchors.top: navigationBar.bottom
            color: "white"

            // 列标题
            Rectangle {
                id: columnHeaders
                width: parent.width
                height: 30
                color: "#34495e"

                Row {
                    spacing: 0
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        width: parent.width - 150
                        text: "名称"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        width: 100
                        text: "大小"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        width: 150
                        text: "修改日期"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            ListView {
                id: fileList
                width: parent.width
                height: parent.height - columnHeaders.height
                anchors.top: columnHeaders.bottom
                model: ListModel {}
                delegate: fileDelegate
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }
        }

        // 底部按钮区域
        Rectangle {
            width: parent.width
            height: 50
            anchors.bottom: parent.bottom
            color: "#ecf0f1"

            // 按钮区域（右侧）
            Row {
                spacing: 10
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                // 取消按钮
                Rectangle {
                    width: 80
                    height: 30
                    color: "#95a5a6"
                    radius: 4

                    Text {
                        text: "取消"
                        color: "white"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            filePicker.canceled()
                            filePicker.close()
                        }
                    }
                }

                // 选择按钮 - 根据模式固定文本
                Rectangle {
                    width: 120
                    height: 30
                    color: selectedPath === "" ? "#bdc3c7" : "#3498db"
                    radius: 4

                    Text {
                        text: selectFolder ? "选择文件夹" : (fileMode === "save" ? "保存" : "选择文件")
                        color: "white"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: selectedPath !== ""
                        onClicked: {
                            filePicker.fileSelected(selectedPath)
                            filePicker.close()
                        }
                    }
                }
            }

            // 文件类型过滤器（左侧）- 改为输入框
            Row {
                spacing: 10
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                visible: fileFilters.length > 0 && !selectFolder

                Text {
                    text: "文件类型:"
                    color: "#2c3e50"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 文件类型输入框
                Rectangle {
                    width: 120
                    height: 25
                    color: "white"
                    border.color: "#bdc3c7"
                    border.width: 1
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter

                    TextInput {
                        id: fileTypeInput
                        anchors.fill: parent
                        anchors.margins: 5
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12

                        onTextChanged: {
                            selectedFileType = text
                            // 添加延迟，避免频繁刷新
                            if (fileTypeTimer.running) {
                                fileTypeTimer.restart()
                            } else {
                                fileTypeTimer.start()
                            }
                        }
                    }

                    // 占位符文本
                    Text {
                        text: "例如: .txt"
                        color: "#95a5a6"
                        font.pixelSize: 12
                        anchors {
                            left: parent.left
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        visible: fileTypeInput.text === ""
                    }

                    // 清除按钮
                    Text {
                        text: "×"
                        color: "#e74c3c"
                        font.pixelSize: 14
                        font.bold: true
                        anchors {
                            right: parent.right
                            rightMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        visible: fileTypeInput.text !== ""

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fileTypeInput.text = ""
                                selectedFileType = ""
                            }
                        }
                    }
                }

                // 常用文件类型快捷按钮
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: fileFilters.slice(0, 4) // 只显示前4个常用类型

                        Rectangle {
                            width: 40
                            height: 20
                            color: selectedFileType === modelData ? "#3498db" : "#ecf0f1"
                            radius: 3

                            Text {
                                text: modelData
                                color: selectedFileType === modelData ? "white" : "#7f8c8d"
                                font.pixelSize: 10
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fileTypeInput.text = modelData
                                    selectedFileType = modelData
                                }
                            }
                        }
                    }
                }
            }
        }

        // 点击外部关闭下拉列表的透明覆盖层
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            visible: false // 由于移除了下拉列表，这个也不再需要
            z: 500

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // 空实现，因为移除了下拉列表
                }
            }
        }
    }

    // 文件项委托
    Component {
        id: fileDelegate

        Rectangle {
            width: fileList.width
            height: 30
            color: (selectedPath === model.path) ? "#d6eaf8" : (index % 2 === 0 ? "#f8f9fa" : "white")

            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                width: parent.width - 20

                // 图标 - 根据文件类型显示不同图标和颜色
                Rectangle {
                    width: 20
                    height: 20
                    color: model.isDir ? "#3498db" : getFileColor(model.name)
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: model.isDir ? "📁" : getFileIcon(model.name)
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }

                // 文件信息
                Text {
                    width: parent.width - 250
                    text: model.name
                    color: "#2c3e50"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 文件大小
                Text {
                    width: 100
                    text: model.size || ""
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 修改日期 - 确保正确引用 modified 属性
                Text {
                    width: 150
                    text: model.modified || "未知日期"  // 使用 model.modified
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (model.isDir) {
                        // 直接进入目录，移除原来的 C: 特判
                        navigateTo(model.path)
                    } else {
                        if (!selectFolder) {
                            selectedPath = model.path
                            if (fileMode === "save") {
                                // 保存模式下，将文件名填入输入框
                                fileNameInput.text = model.name
                            }
                        }
                    }
                }
                onDoubleClicked: {
                    if (model.isDir) {
                        // 直接进入目录，移除原来的 C: 特判
                        navigateTo(model.path)
                    } else if (!selectFolder) {
                        selectedPath = model.path
                        if (fileMode === "save") {
                            // 保存模式下，将文件名填入输入框
                            fileNameInput.text = model.name
                        } else {
                            // 打开模式下，直接选择文件
                            filePicker.fileSelected(selectedPath)
                            filePicker.close()
                        }
                    }
                }
            }
        }
    }

    // 计算机视图委托
    Component {
        id: computerDelegate

        Rectangle {
            width: fileList.width
            height: 50
            color: index % 2 === 0 ? "#f8f9fa" : "white"

            Row {
                spacing: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10

                // 驱动器图标 - 统一使用相同的图标和颜色
                Rectangle {
                    width: 35
                    height: 35
                    color: model.type === "system" ? "#e74c3c" : "#3498db" // 系统盘红色，其他盘蓝色
                    radius: 5
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "💾" // 统一使用磁盘图标
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }
                }

                // 驱动器信息
                Column {
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: model.name
                        color: "#2c3e50"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: model.type === "system" ? "系统分区 - " + model.size : "本地磁盘 - " + model.size
                        color: "#7f8c8d"
                        font.pixelSize: 11
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // 移除系统盘特判，允许访问任何驱动器
                    navigateTo(model.path)
                }
            }
        }
    }

    // 导航到指定路径
    function navigateTo(path) {
        currentPath = path
        // 移除原来的 selectedPath = ""，改为在函数末尾调用 updateSelectedPath()

        // 保存模式下，如果用户还没有输入文件名，则使用默认文件名
        if (fileMode === "save" && fileNameInput.text === "") {
            fileNameInput.text = defaultFileName
        }

        fileList.model.clear()

        if (path === "") {
            // 显示驱动器列表
            fileList.delegate = computerDelegate
            var drives = fileSystem.getDrives()
            for (var i = 0; i < drives.length; i++) {
                fileList.model.append({
                    "name": drives[i].name,
                    "path": drives[i].path,
                    "isDir": true,
                    "type": drives[i].type === "system" ? "system" : "drive",
                    "size": drives[i].size,
                    "modified": "" // 确保包含 modified 属性
                })
            }
        } else {
            // 显示目录内容
            fileList.delegate = fileDelegate
            var contents = fileSystem.getDirectoryContents(path)
            for (var j = 0; j < contents.length; j++) {
                // 如果选择文件夹模式，只显示文件夹
                if (!selectFolder || contents[j].isDir) {
                    // 文件过滤 - 使用单选逻辑
                    if (fileFilters.length > 0 && !contents[j].isDir && selectedFileType !== "") {
                        var fileName = contents[j].name.toLowerCase()
                        if (!fileName.endsWith(selectedFileType.toLowerCase())) {
                            continue
                        }
                    }
                    // 确保每个项都有 modified 属性
                    if (!contents[j].hasOwnProperty("modified")) {
                        contents[j].modified = ""
                    }
                    fileList.model.append(contents[j])
                }
            }
        }

        // 更新选中的路径
        updateSelectedPath()
    }

    // 更新选择的路径
    function updateSelectedPath() {
        if (selectFolder) {
            selectedPath = currentPath
        } else {
            if (fileNameInput.text && currentPath && currentPath !== "") {
                // 修复路径连接逻辑，确保使用统一的反斜杠分隔符
                var separator = "\\"
                // 确保currentPath不以分隔符结尾，同时清理可能存在的正斜杠
                var cleanPath = currentPath.replace(/\//g, "\\")
                // 移除末尾的分隔符（如果有）
                if (cleanPath.endsWith("\\")) {
                    cleanPath = cleanPath.slice(0, -1)
                }
                selectedPath = cleanPath + separator + fileNameInput.text
            } else {
                selectedPath = ""
            }
        }
    }

    // 获取文件图标
    function getFileIcon(fileName) {
        if (!fileName) return "📄"

        var ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
        switch(ext) {
            case "txt": case "log": case "ini": case "conf": return "📄"
            case "pdf": return "📕"
            case "doc": case "docx": return "📝"
            case "xls": case "xlsx": return "📊"
            case "ppt": case "pptx": return "📑"
            case "jpg": case "jpeg": case "png": case "gif": case "bmp": case "svg": return "🖼️"
            case "mp3": case "wav": case "flac": case "aac": return "🎵"
            case "mp4": case "avi": case "mkv": case "mov": case "wmv": return "🎬"
            case "zip": case "rar": case "7z": case "tar": case "gz": return "📦"
            case "exe": case "msi": case "bat": case "cmd": return "⚙️"
            case "html": case "htm": return "🌐"
            case "css": return "🎨"
            case "js": return "📜"
            case "json": case "xml": return "🔣"
            case "py": return "🐍"
            case "java": return "☕"
            case "cpp": case "c": case "h": return "🔧"
            case "psd": case "ai": case "sketch": return "🎨"
            case "ttf": case "otf": case "woff": return "🔤"
            default: return "📄"
        }
    }

    // 获取文件图标背景颜色
    function getFileColor(fileName) {
        if (!fileName) return "#95a5a6"

        var ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
        switch(ext) {
            case "txt": case "log": case "ini": case "conf": return "#3498db"
            case "pdf": return "#e74c3c"
            case "doc": case "docx": return "#2980b9"
            case "xls": case "xlsx": return "#27ae60"
            case "ppt": case "pptx": return "#e67e22"
            case "jpg": case "jpeg": case "png": case "gif": case "bmp": case "svg": return "#9b59b6"
            case "mp3": case "wav": case "flac": case "aac": return "#f39c12"
            case "mp4": case "avi": case "mkv": case "mov": case "wmv": return "#d35400"
            case "zip": case "rar": case "7z": case "tar": case "gz": return "#16a085"
            case "exe": case "msi": case "bat": case "cmd": return "#2c3e50"
            case "html": case "htm": return "#e74c3c"
            case "css": return "#3498db"
            case "js": return "#f39c12"
            case "json": case "xml": return "#7f8c8d"
            case "py": return "#3572A5"
            case "java": return "#ED8B00"
            case "cpp": case "c": case "h": return "#00599C"
            case "psd": case "ai": case "sketch": return "#8E44AD"
            case "ttf": case "otf": case "woff": return "#E74C3C"
            default: return "#95a5a6"
        }
    }

    // 显示错误消息
    function showError(message) {
        console.log("FilePicker Error: " + message)
        // 可以扩展为显示错误对话框
    }

    // 获取父目录
    property string parentDirectory: {
        if (currentPath === "") {
            return ""
        } else {
            return fileSystem.getParentDirectory(currentPath)
        }
    }

    // 文件类型输入定时器 - 延迟刷新文件列表
    Timer {
        id: fileTypeTimer
        interval: 300 // 300ms 延迟
        onTriggered: {
            navigateTo(currentPath)
        }
    }

    // 连接文件系统的错误信号
    Connections {
        target: fileSystem
        function onErrorOccurred(errorMessage) {
            showError(errorMessage)
        }
    }

    // 组件完成时显示驱动器列表
    Component.onCompleted: {
        navigateTo("") // 默认显示磁盘选择界面
    }
}
