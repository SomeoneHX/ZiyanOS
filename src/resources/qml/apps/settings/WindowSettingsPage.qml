import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: windowSettingsPage
    implicitHeight: windowSettingsContent.height

    property string currentWindowMode: "auto"
    property string currentWindowColor: "#3498db"
    signal windowSettingsChanged(string mode, string color)

    Column {
        id: windowSettingsContent
        width: parent.width
        spacing: 20  // 统一垂直间距
        padding: 20

        // 页面标题
        Text {
            text: "窗口设置"
            font.pixelSize: 18
            font.bold: true
            color: "#2c3e50"
        }

        // 警告文本（保留原样，间距由外层 spacing 控制）
        Text {
            text: "警告：该设置存在未知Bug会导致系统崩溃。"
            font.pixelSize: 15
            font.bold: true
            color: "Red"
        }

        // 窗口模式选择（不再使用内部 Column 的 spacing，完全依赖外层）
        Column {
            width: parent.width
            // 内部不再设置 spacing，由外层统一控制

            Text {
                text: "窗口标题栏颜色模式"
                font.pixelSize: 14
                color: "#2c3e50"
            }

            Row {
                spacing: 20
                width: parent.width

                Rectangle {
                    width: 120
                    height: 40
                    color: currentWindowMode === "auto" ? "#3498db" : "#ecf0f1"
                    radius: 5

                    Text {
                        text: "自动模式"
                        color: currentWindowMode === "auto" ? "white" : "#2c3e50"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentWindowMode = "auto"
                            windowSettingsPage.windowSettingsChanged(currentWindowMode, currentWindowColor)
                        }
                    }
                }

                Rectangle {
                    width: 120
                    height: 40
                    color: currentWindowMode === "custom" ? "#3498db" : "#ecf0f1"
                    radius: 5

                    Text {
                        text: "自定义模式"
                        color: currentWindowMode === "custom" ? "white" : "#2c3e50"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentWindowMode = "custom"
                            windowSettingsPage.windowSettingsChanged(currentWindowMode, currentWindowColor)
                        }
                    }
                }
            }

            Text {
                text: currentWindowMode === "auto" ?
                      "窗口标题栏颜色与内容区域背景色相同" :
                      "为所有窗口设置统一的标题栏颜色"
                color: "#7f8c8d"
                font.pixelSize: 12
                width: parent.width
                wrapMode: Text.Wrap
            }
        }

        // 自定义颜色设置（仅自定义模式显示）
        Column {
            width: parent.width
            visible: currentWindowMode === "custom"
            // 内部不再设置 spacing，由外层统一控制

            Text {
                text: "自定义颜色"
                font.pixelSize: 14
                color: "#2c3e50"
            }

            Row {
                spacing: 15
                width: parent.width

                Rectangle {
                    width: 40
                    height: 40
                    color: currentWindowColor
                }

                Rectangle {
                    width: 200
                    height: 40
                    color: "white"

                    TextInput {
                        id: colorInput
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 5
                        rightPadding: 5
                        font.pixelSize: 14
                        text: currentWindowColor

                        onTextChanged: {
                            if (colorTimer.running) {
                                colorTimer.restart()
                            } else {
                                colorTimer.start()
                            }
                        }

                        onAccepted: {
                            currentWindowColor = text
                            windowSettingsPage.windowSettingsChanged(currentWindowMode, currentWindowColor)
                        }
                    }

                    Text {
                        text: "输入十六进制颜色"
                        color: "#95a5a6"
                        font.pixelSize: 14
                        anchors {
                            left: parent.left
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        visible: colorInput.text === ""
                    }
                }
            }

            // 常用颜色选择
            Column {
                width: parent.width
                // 内部不再设置 spacing，由外层统一控制

                Text {
                    text: "常用颜色"
                    color: "#7f8c8d"
                    font.pixelSize: 12
                }

                Flow {
                    width: parent.width
                    spacing: 10  // 保持内聚区域的小间距

                    Repeater {
                        model: [
                            "#3498db", "#2ecc71", "#e74c3c", "#f39c12",
                            "#9b59b6", "#1abc9c", "#34495e", "#7f8c8d"
                        ]

                        Rectangle {
                            width: 30
                            height: 30
                            color: modelData

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    currentWindowColor = modelData
                                    colorInput.text = modelData
                                    windowSettingsPage.windowSettingsChanged(currentWindowMode, currentWindowColor)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: colorTimer
        interval: 500
        onTriggered: {
            currentWindowColor = colorInput.text
            windowSettingsPage.windowSettingsChanged(currentWindowMode, currentWindowColor)
        }
    }

    Component.onCompleted: {
        console.log("窗口设置页面加载完成（边距已优化）")
    }
}
