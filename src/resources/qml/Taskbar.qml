import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ZiyanOS.SettingsManager
import ZiyanOS.SystemUtils
import Qt5Compat.GraphicalEffects
import ZiyanOS
import ZiyanOS.Apps 1.0

ApplicationWindow {
    id: taskbar
    width: Screen.width
    height: 60
    x: 0
    y: Screen.height - height
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: "字研OS 任务栏"

    property bool allowClose: false
    property var windowManager: null

    Rectangle {
        anchors.fill: parent
        color: "#E0000000"
    }

    Row {
        id: taskbarApps
        spacing: 8
        anchors.centerIn: parent

        Repeater {
            model: AppRegistry.activeWindowsModel
            delegate: Rectangle {
                id: button
                width: 48; height: 48
                radius: 6
                color: "transparent"

                property int windowIndex: index

                Text {
                    text: model.displayIcon || "📄"
                    color: "white"
                    font.pixelSize: 28
                    anchors.centerIn: parent
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "#7f8c8d"
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: button.color = "#34495e"
                    onExited: button.color = "transparent"
                    onClicked: {
                        var window = AppRegistry.getWindowByIndex(windowIndex)
                        if (window) {
                            if (window.isMinimized)
                                window.restoreWindow()
                            else
                                window.minimizeWindow()
                        }
                    }
                }

                ToolTip {
                    visible: mouseArea.containsMouse && model.title !== ""
                    text: model.title
                    delay: 100
                    timeout: -1
                    y: -height - 5
                    x: (parent.width - width) / 2
                }
            }
        }
    }

    Row {
        id: systemTray
        spacing: 15
        anchors {
            right: parent.right
            rightMargin: 15
            verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: dateText
                color: "white"
                font.pixelSize: 12
                font.bold: true
                horizontalAlignment: Text.AlignRight
            }

            Text {
                id: timeText
                color: "white"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            width: 36
            height: 36
            radius: 4
            color: "transparent"
            border.color: "transparent"

            Rectangle {
                id: lockScreenHoverBg
                anchors.fill: parent
                radius: parent.radius
                color: "#7f8c8d"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            Text {
                text: "🔒"
                color: "white"
                font.pixelSize: 18
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: lockScreenHoverBg.opacity = 1
                onExited: lockScreenHoverBg.opacity = 0
                onClicked: {
                    if (taskbar.windowManager && taskbar.windowManager.switchToLockScreen) {
                        taskbar.windowManager.switchToLockScreen()
                    }
                }
            }
        }

        Rectangle {
            width: 36
            height: 36
            radius: 4
            color: "transparent"

            Text {
                text: "🔌"
                color: "white"
                font.pixelSize: 18
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = "#e74c3c"
                onExited: parent.color = "transparent"
                onClicked: {
                    if (taskbar.windowManager && taskbar.windowManager.switchToPowerMenu) {
                        taskbar.windowManager.switchToPowerMenu()
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentTime = new Date()
            dateText.text = currentTime.toLocaleDateString(Qt.locale(), "yyyy-MM-dd dddd")
            timeText.text = currentTime.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
        }
    }

    Component.onCompleted: {
        var currentTime = new Date()
        dateText.text = currentTime.toLocaleDateString(Qt.locale(), "yyyy-MM-dd dddd")
        timeText.text = currentTime.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
    }

    Connections {
        target: AppRegistry
        onActiveWindowsChanged: {
            taskbar.raise()
            taskbar.raise()
            taskbar.raise()
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: taskbar.raise()
    }
}