import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.FileSystem
import ZiyanOS

ZiyanWindow {
    id: textEditor
    width: 800
    height: 600
    windowTitle: "未命名 - 文本编辑器"

    // 新增：只读模式属性，可由外部传入
    property bool readOnly: false

    property string currentFilePath: ""
    property bool isModified: false

    property var fileSystem: FileSystem {}

    property var filePicker: null
    property var contextMenu: null

    contentItem: Item {
        anchors.fill: parent

        // 工具栏
        Rectangle {
            id: toolbar
            width: parent.width
            height: 40
            color: "#ecf0f1"

            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10

                // 新建按钮
                Rectangle {
                    width: 70
                    height: 25
                    color: enabled ? "#3498db" : "#bdc3c7"  // 根据 enabled 状态变色
                    radius: 3
                    enabled: !readOnly  // 只读模式下禁用

                    Text {
                        text: "新建"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.enabled
                        onClicked: newFile()
                    }
                }

                // 打开按钮
                Rectangle {
                    width: 70
                    height: 25
                    color: enabled ? "#3498db" : "#bdc3c7"
                    radius: 3
                    enabled: !readOnly

                    Text {
                        text: "打开"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.enabled
                        onClicked: showOpenFilePicker()
                    }
                }

                // 保存按钮（已正确变色）
                Rectangle {
                    width: 70
                    height: 25
                    color: (!readOnly && currentFilePath !== "") ? "#3498db" : "#bdc3c7"
                    radius: 3
                    enabled: !readOnly && currentFilePath !== ""

                    Text {
                        text: "保存"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.enabled
                        onClicked: saveFile(currentFilePath)
                    }
                }

                // 另存为按钮（始终可用）
                Rectangle {
                    width: 70
                    height: 25
                    color: "#3498db"
                    radius: 3

                    Text {
                        text: "另存为"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: showSaveFilePicker()
                    }
                }

                // 分隔线
                Rectangle {
                    width: 1
                    height: 20
                    color: "#bdc3c7"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 撤销按钮
                Rectangle {
                    width: 70
                    height: 25
                    color: (!readOnly && textArea.canUndo) ? "#3498db" : "#bdc3c7"
                    radius: 3
                    enabled: !readOnly && textArea.canUndo

                    Text {
                        text: "撤销"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.enabled
                        onClicked: textArea.undo()
                    }
                }

                // 重做按钮
                Rectangle {
                    width: 70
                    height: 25
                    color: (!readOnly && textArea.canRedo) ? "#3498db" : "#bdc3c7"
                    radius: 3
                    enabled: !readOnly && textArea.canRedo

                    Text {
                        text: "重做"
                        color: "white"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.enabled
                        onClicked: textArea.redo()
                    }
                }

                // 分隔线
                Rectangle {
                    width: 1
                    height: 20
                    color: "#bdc3c7"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 状态指示器
                Text {
                    text: readOnly ? "只读" : (isModified ? "已修改" : "已保存")
                    color: readOnly ? "#7f8c8d" : (isModified ? "#e74c3c" : "#27ae60")
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // 文本编辑区域
        ScrollView {
            width: parent.width
            height: parent.height - toolbar.height
            anchors.top: toolbar.bottom

            TextArea {
                id: textArea
                width: parent.width
                placeholderText: "在此输入文本..."
                wrapMode: TextArea.Wrap
                font.pixelSize: 14
                selectByMouse: true
                focus: true

                // 只读模式由外部属性控制
                readOnly: textEditor.readOnly

                onTextChanged: {
                    if (!isModified && !readOnly) {
                        isModified = true
                        updateTitle()
                    }
                }

                // 右键菜单
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: Qt.IBeamCursor
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            showContextMenu(mouse.x, mouse.y)
                        }
                    }
                }

                // 快捷键处理（仅保留默认没有的快捷键）
                Keys.onPressed: (event) => {
                    handleKeyEvent(event)
                }
            }
        }
    }

    // 右键菜单组件
    Component {
        id: contextMenuComponent

        Menu {
            id: contextMenu

            MenuItem {
                text: "撤销\tCtrl+Z"
                enabled: !readOnly && textArea.canUndo
                onTriggered: textArea.undo()
            }

            MenuItem {
                text: "重做\tCtrl+Y"
                enabled: !readOnly && textArea.canRedo
                onTriggered: textArea.redo()
            }

            MenuSeparator {}

            MenuItem {
                text: "剪切\tCtrl+X"
                enabled: !readOnly && textArea.selectedText !== ""
                onTriggered: textArea.cut()
            }

            MenuItem {
                text: "复制\tCtrl+C"
                enabled: textArea.selectedText !== ""  // 只读模式下也可复制
                onTriggered: textArea.copy()
            }

            MenuItem {
                text: "粘贴\tCtrl+V"
                enabled: !readOnly  // 只读模式下禁用粘贴
                onTriggered: textArea.paste()
            }

            MenuItem {
                text: "删除\tDel"
                enabled: !readOnly && textArea.selectedText !== ""
                onTriggered: {
                    textArea.remove(textArea.selectionStart, textArea.selectionEnd)
                }
            }

            MenuSeparator {}

            MenuItem {
                text: "全选\tCtrl+A"
                enabled: true  // 始终可用
                onTriggered: textArea.selectAll()
            }
        }
    }

    // 显示右键菜单
    function showContextMenu(x, y) {
        if (contextMenu) {
            contextMenu.destroy()
            contextMenu = null
        }
        contextMenu = contextMenuComponent.createObject(textEditor)
        contextMenu.popup(textArea, x, y)
    }

    // 处理快捷键（只处理默认没有的，让默认快捷键生效）
    function handleKeyEvent(event) {
        if (event.modifiers & Qt.ControlModifier) {
            switch (event.key) {
                case Qt.Key_N: // 新建
                    event.accepted = true
                    if (!readOnly) newFile()
                    break
                case Qt.Key_O: // 打开
                    event.accepted = true
                    if (!readOnly) showOpenFilePicker()
                    break
                case Qt.Key_S: // 保存
                    event.accepted = true
                    if (event.modifiers & Qt.ShiftModifier) {
                        // Ctrl+Shift+S 另存为（始终可用）
                        showSaveFilePicker()
                    } else {
                        // Ctrl+S 保存（仅可写时）
                        if (!readOnly && currentFilePath) {
                            saveFile(currentFilePath)
                        }
                    }
                    break
                // Ctrl+Z/Y/X/C/V/A 等由默认快捷键处理，这里不再拦截
            }
        } else {
            switch (event.key) {
                case Qt.Key_F5: // 刷新/重新加载
                    event.accepted = true
                    if (currentFilePath) {
                        loadFile(currentFilePath)
                    }
                    break
                case Qt.Key_F12: // 开发者工具（调试用）
                    event.accepted = true
                    console.log("文本编辑器调试信息:")
                    console.log("文件路径:", currentFilePath)
                    console.log("文本长度:", textArea.length)
                    console.log("选中文本:", textArea.selectedText)
                    console.log("可撤销:", textArea.canUndo)
                    console.log("可重做:", textArea.canRedo)
                    break
            }
        }
    }

    // 显示打开文件选择器
    function showOpenFilePicker() {
        if (readOnly) return  // 只读模式下不允许打开新文件

        filePicker = filePickerComponent.createObject(textEditor, {
            "selectFolder": false,
            "fileFilters": [".txt", ".log", ".ini", ".conf", ".xml", ".json", ".js", ".css", ".html", ".htm"],
            "fileMode": "open"
        })

        filePicker.fileSelected.connect(function(path) {
            loadFile(path)
            filePicker.destroy()
        })

        filePicker.canceled.connect(function() {
            filePicker.destroy()
        })

        filePicker.showWindow()
    }

    // 显示保存文件选择器
    function showSaveFilePicker() {
        filePicker = filePickerComponent.createObject(textEditor, {
            "selectFolder": false,
            "fileFilters": [".txt"],
            "defaultFileName": currentFilePath ? getFileName(currentFilePath) : "新文档.txt",
            "fileMode": "save"
        })

        filePicker.fileSelected.connect(function(path) {
            saveFile(path)
            filePicker.destroy()
        })

        filePicker.canceled.connect(function() {
            filePicker.destroy()
        })

        filePicker.showWindow()
    }

    // 新建文件
    function newFile() {
        if (readOnly) return
        if (isModified) {
            console.log("有未保存的更改，但继续新建文件")
        }
        textArea.text = ""
        currentFilePath = ""
        isModified = false
        updateTitle()
        textArea.forceActiveFocus()
    }

    // 加载文件
    function loadFile(filePath) {
        if (!filePath || typeof filePath !== 'string') {
            console.log("无效的文件路径")
            return
        }

        console.log("加载文件: " + filePath)

        var content = fileSystem.readFile(filePath)
        if (content !== "") {
            textArea.text = content
            currentFilePath = filePath
            isModified = false
            updateTitle()
            textArea.forceActiveFocus()
        }
    }

    // 保存文件
    function saveFile(filePath) {
        if (readOnly) return  // 只读模式下禁止保存
        if (!filePath) {
            showSaveFilePicker()
            return
        }

        if (filePath.indexOf('.') === -1) {
            filePath += ".txt"
        }

        console.log("保存文件到: " + filePath)

        var success = fileSystem.writeFile(filePath, textArea.text)
        if (success) {
            currentFilePath = filePath
            isModified = false
            updateTitle()
            textArea.forceActiveFocus()
        }
    }

    // 显示消息
    function showMessage(message) {
        var messageBox = messageBoxComponent.createObject(textEditor, {
            "message": message
        })
        messageBox.showWindow()
        messageTimer.start()
    }

    // 更新标题
    function updateTitle() {
        var title = currentFilePath ? getFileName(currentFilePath) : "未命名"
        if (isModified) {
            title += " *"
        }
        if (readOnly) {
            title += " (只读)"
        }
        textEditor.windowTitle = title + " - 文本编辑器"
    }

    // 获取文件名
    function getFileName(path) {
        var lastSlash = Math.max(path.lastIndexOf('\\'), path.lastIndexOf('/'))
        return path.substring(lastSlash + 1)
    }

    // 公共方法：打开文件（供外部调用）
    function openFile(path) {
        if (path && typeof path === 'string') {
            loadFile(path)
        } else {
            console.log("无效的文件路径参数")
        }
    }

    // 文件选择器组件
    Component {
        id: filePickerComponent
        FilePicker {}
    }

    // 消息框组件
    Component {
        id: messageBoxComponent
        ZiyanWindow {
            id: messageBox
            width: 300
            height: 150
            windowTitle: "消息"
            titleBarColor: "#27ae60"

            property string message: ""

            contentItem: Item {
                anchors.fill: parent

                Text {
                    text: messageBox.message
                    color: "#2c3e50"
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    anchors.centerIn: parent
                    anchors.margins: 20
                }
            }
        }
    }

    // 消息定时器
    Timer {
        id: messageTimer
        interval: 3000
        onTriggered: {
            var children = textEditor.children
            if (children && children.length) {
                for (var i = 0; i < children.length; i++) {
                    var child = children[i]
                    if (child && child !== textEditor && child.windowTitle === "消息") {
                        child.close()
                    }
                }
            }
        }
    }

    // 连接文件系统的信号
    Connections {
        target: fileSystem
        function onFileOperationCompleted(message) {
            showMessage(message)
        }
        function onErrorOccurred(errorMessage) {
            showMessage(errorMessage)
        }
    }

    Component.onCompleted: {
        updateTitle()
        textArea.forceActiveFocus()
    }
}
