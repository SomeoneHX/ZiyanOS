import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.SystemUtils
import ZiyanOS.FileSystem
import ZiyanOS

ZiyanWindow {
    id: wineCompat
    width: 550
    height: 250
    windowTitle: "Windows兼容层"
    showMinimizeButton: false
    allowClose: !(compatModeActive || programRunning)

    property var systemUtils: SystemUtils {}
    property var filePicker: null
    property string selectedExePath: ""
    property bool compatModeActive: false  // 是否进入兼容模式（第二页）
    property bool programRunning: false    // 是否有程序在运行
    property var desktop: null

    // 监听程序状态
    Connections {
        target: systemUtils
        function onProgramStarted() {
            programRunning = true
        }
        function onProgramFinished() {
            programRunning = false
        }
    }

    contentItem: Item {
        anchors.fill: parent
        anchors.margins: 20

        StackLayout {
            id: stackLayout
            anchors.fill: parent
            currentIndex: compatModeActive ? 1 : 0

            // 第一页：风险提示与进入按钮
            Item {
                id: firstPage

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20

                    Text {
                        text: "⚠️ 兼容模式风险提示"
                        color: "#e74c3c"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "进入兼容模式后，桌面将完全隐藏，仅保留本窗口和您运行的程序窗口。\n" +
                              "您将无法访问桌面图标、任务栏和其他应用程序。\n" +
                              "请确保您已保存所有工作，并清楚自己在做什么。"
                        color: "#2c3e50"
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        id: enterButton
                        Layout.alignment: Qt.AlignHCenter
                        width: 150
                        height: 40
                        color: "#e67e22"
                        radius: 5

                        Text {
                            text: "进入兼容模式"
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: enterButton.color = "#d35400"
                            onExited: enterButton.color = "#e67e22"
                            onClicked: {
                                compatModeActive = true
                                if (desktop) desktop.enterCompatMode(wineCompat)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // 第二页：文件选择与运行界面
            Item {
                id: secondPage

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    Text {
                        text: "选择一个Windows可执行文件 (.exe) 并运行"
                        color: "#2c3e50"
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    // EXE 路径选择行
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: exePathField
                            Layout.fillWidth: true
                            placeholderText: "选择或输入可执行文件路径"
                            text: selectedExePath
                            selectByMouse: true
                            enabled: !programRunning
                            background: Rectangle {
                                border.color: enabled ? "#bdc3c7" : "#d0d3d4"
                                color: enabled ? "white" : "#f0f0f0"
                            }
                        }

                        Rectangle {
                            id: browseButton
                            width: 70
                            height: 30
                            color: enabled ? "#3498db" : "#bdc3c7"
                            radius: 4
                            enabled: !programRunning

                            Text {
                                text: "浏览"
                                color: "white"
                                font.pixelSize: 12
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.enabled
                                hoverEnabled: true
                                onEntered: if (parent.enabled) browseButton.color = "#2980b9"
                                onExited: if (parent.enabled) browseButton.color = "#3498db"
                                onClicked: showFilePicker()
                            }
                        }
                    }

                    // 参数输入行
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: argsField
                            Layout.fillWidth: true
                            placeholderText: "参数（可选）"
                            selectByMouse: true
                            enabled: !programRunning
                            background: Rectangle {
                                border.color: enabled ? "#bdc3c7" : "#d0d3d4"
                                color: enabled ? "white" : "#f0f0f0"
                            }
                        }
                    }

                    // 按钮行：运行 + 退出兼容模式
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // 运行/结束按钮
                        Rectangle {
                            id: runButton
                            width: 120
                            height: 35
                            color: programRunning ? "#e74c3c" : (enabled ? "#27ae60" : "#bdc3c7")
                            radius: 5
                            enabled: !programRunning ? (exePathField.text.trim() !== "") : true

                            Text {
                                text: programRunning ? "结束运行" : "运行"
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.enabled
                                hoverEnabled: true
                                onEntered: {
                                    if (!parent.enabled) return
                                    if (programRunning)
                                        runButton.color = "#c0392b"
                                    else
                                        runButton.color = "#2ecc71"
                                }
                                onExited: {
                                    if (programRunning)
                                        runButton.color = "#e74c3c"
                                    else
                                        runButton.color = "#27ae60"
                                }
                                onClicked: {
                                    if (programRunning) {
                                        systemUtils.terminateProgram()
                                    } else {
                                        startProgram()
                                    }
                                }
                            }
                        }

                        // 退出兼容模式按钮
                        Rectangle {
                            id: exitButton
                            width: 120
                            height: 35
                            color: programRunning ? "#bdc3c7" : "#e67e22"  // 直接根据运行状态变色
                            radius: 5
                            enabled: !programRunning  // 禁用时不可点击

                            Text {
                                text: "退出兼容模式"
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.enabled
                                hoverEnabled: true
                                onEntered: if (parent.enabled) exitButton.color = "#d35400"
                                onExited: if (parent.enabled) exitButton.color = "#e67e22"
                                onClicked: {
                                    compatModeActive = false
                                    if (desktop) desktop.exitCompatMode()
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    // 文件选择器
    function showFilePicker() {
        filePicker = filePickerComponent.createObject(wineCompat, {
            "selectFolder": false,
            "fileFilters": [".exe"],
            "fileMode": "open"
        })

        filePicker.fileSelected.connect(function(path) {
            selectedExePath = path
            exePathField.text = path
            filePicker.destroy()
        })

        filePicker.canceled.connect(function() {
            filePicker.destroy()
        })

        filePicker.showWindow()
    }

    // 启动程序
    function startProgram() {
        var exe = exePathField.text.trim()
        var args = argsField.text.trim()
        if (exe === "") return
        systemUtils.startProgram(exe, args)
    }

    // 添加属性变化日志
    onCompatModeActiveChanged: console.log("compatModeActive ->", compatModeActive)
    onProgramRunningChanged: console.log("programRunning ->", programRunning)

    // 窗口关闭时：如果处于兼容模式或程序运行中，则阻止关闭
    onWindowClosing: (close) => {
        console.log("WineCompatLayer 正在关闭，清理中...")
        // 如果程序正在运行，先结束它
        if (programRunning) {
            systemUtils.terminateProgram()
        }
        // 如果处于兼容模式，退出
        if (compatModeActive && desktop) {
            desktop.exitCompatMode()
        }
        // 允许立即关闭（不使用动画）
        close.accepted = true
    }

    Component {
        id: filePickerComponent
        FilePicker {}
    }
}
