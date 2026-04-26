import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import ZiyanOS.SystemUtils 1.0
import ZiyanOS.VersionManager 1.0

ApplicationWindow {
    id: powerWindow
    width: Screen.width
    height: Screen.height
    // visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen                             // 全屏模式
    title: "电源菜单"

    signal windowClosing()
    signal requestDesktopClose()
    signal cancelled()

    SystemUtils { id: systemUtils }

    // 固定背景色
    property string powerBackground: "#1a1a1a"
    property bool hasPecmdIni: systemUtils.hasPecmdIni()

    // 标志：是否由取消按钮触发关闭
    property bool __cancelledByUser: false

    Rectangle {
        anchors.fill: parent
        color: powerBackground

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
        }
    }

    // 顶部标题
    Text {
        anchors { top: parent.top; topMargin: 60; horizontalCenter: parent.horizontalCenter }
        text: "电源菜单"
        color: "white"
        font.pixelSize: 36
        font.bold: true
    }

    // 底部按钮区域
    Column {
        anchors { bottom: parent.bottom; bottomMargin: 40; horizontalCenter: parent.horizontalCenter }
        spacing: 20

        Text {
            text: "关机、重启将丢失未保存数据"
            color: "white"
            font.pixelSize: 14
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            // 重启按钮
            Rectangle {
                width: 120; height: 45
                color: "#f39c12"
                radius: 8
                Text { text: "重启"; color: "white"; font.pixelSize: 16; font.bold: true; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#d68910"
                    onExited: parent.color = "#f39c12"
                    onClicked: {
                        systemUtils.rebootWithCommand()
                    }
                }
            }

            // 关机按钮
            Rectangle {
                width: 120; height: 45
                color: "#e74c3c"
                radius: 8
                Text { text: "关机"; color: "white"; font.pixelSize: 16; font.bold: true; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#c0392b"
                    onExited: parent.color = "#e74c3c"
                    onClicked: {
                        systemUtils.shutdownWithCommand()
                    }
                }
            }

            // 退出按钮（根据配置决定是否显示）
            Rectangle {
                width: 120; height: 45
                color: "#3498db"
                radius: 8
                visible: VersionManager.showExitButton
                Text { text: "退出"; color: "white"; font.pixelSize: 16; font.bold: true; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#2980b9"
                    onExited: parent.color = "#3498db"
                    onClicked: {
                        Qt.quit()
                    }
                }
            }

            // 取消按钮
            Rectangle {
                width: 120; height: 45
                color: "#95a5a6"
                radius: 8
                Text { text: "取消"; color: "white"; font.pixelSize: 16; font.bold: true; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#7f8c8d"
                    onExited: parent.color = "#95a5a6"
                    onClicked: {
                        __cancelledByUser = true
                        cancelled()
                        powerWindow.close()
                    }
                }
            }
        }
    }

    Component.onCompleted: {}

    onClosing: (close) => {
        // 如果不是由取消按钮触发的关闭（例如 Alt+F4），也视为取消
        if (!__cancelledByUser) {
            cancelled()
        }
        windowClosing()
        close.accepted = true
    }
}
