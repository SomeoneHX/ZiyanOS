import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import ZiyanOS.SettingsManager

ApplicationWindow {
    id: lockScreen
    width: Screen.width
    height: Screen.height
    // visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen                             // 全屏模式
    title: "锁屏界面"

    // 信号：登录成功时触发
    signal loginSuccessful()

    // 设置管理器
    SettingsManager {
        id: settingsManager
    }

    // 壁纸属性
    property string desktopBackground: settingsManager.desktopBackground
    property string desktopWallpaper: settingsManager.desktopWallpaper

    // 模糊半径（可调整）
    property int blurRadius: 16

    // 背景（壁纸） - 支持图片高斯模糊
    Rectangle {
        anchors.fill: parent
        // 当无壁纸图片时显示纯色背景
        color: desktopWallpaper === "" ? desktopBackground : "transparent"

        // 图片壁纸层（包含模糊处理）
        Item {
            anchors.fill: parent
            visible: desktopWallpaper !== ""

            // 原始图片（仅作为模糊源，不直接显示）
            Image {
                id: wallpaperImage
                anchors.fill: parent
                source: desktopWallpaper
                fillMode: Image.PreserveAspectCrop
                visible: false  // 隐藏原始图片
            }

            // 高斯模糊效果
            GaussianBlur {
                anchors.fill: parent
                source: wallpaperImage
                radius: blurRadius
                samples: blurRadius * 2  // 采样数通常为半径的2倍
            }
        }

        // 半透明黑色遮罩层（始终显示，增强文字可读性）
        Rectangle {
            anchors.fill: parent
            color: "#80000000"
        }
    }

    // 顶部时间区域 - 固定在顶部
    Column {
        id: topClock
        anchors {
            top: parent.top
            topMargin: 60
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 10

        // 时间显示容器 - 使用Row实现小时和分钟的分离
        Row {
            id: timeRow
            spacing: 5
            anchors.horizontalCenter: parent.horizontalCenter

            // 小时显示
            Text {
                id: hourText
                color: "white"
                font.pixelSize: 80
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: 120  // 固定宽度确保居中
            }

            // 冒号分隔符
            Text {
                id: colonText
                color: "white"
                font.pixelSize: 80
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                text: ":"
                width: 40  // 固定宽度确保居中
            }

            // 分钟显示
            Text {
                id: minuteText
                color: "white"
                font.pixelSize: 80
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: 120  // 固定宽度确保居中
            }
        }

        // 日期显示
        Text {
            id: dateText
            color: "white"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            width: parent.width  // 确保文本在Column中居中
        }
    }

    // 底部登录按钮区域 - 固定在底部
    Column {
        id: bottomLogin
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 20

        // 登录按钮
        Rectangle {
            width: 60
            height: 30
            radius: 4
            color: "#3498db"

            Text {
                text: "登录"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    // 触发登录成功信号
                    lockScreen.loginSuccessful()
                }
            }
        }
    }

    // 更新时间
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentTime = new Date()

            // 获取小时和分钟
            var hours = currentTime.getHours()
            var minutes = currentTime.getMinutes()

            // 格式化小时（确保两位数显示）
            var hourStr = hours < 10 ? "0" + hours : hours.toString()
            // 格式化分钟（确保两位数显示）
            var minuteStr = minutes < 10 ? "0" + minutes : minutes.toString()

            // 更新时间显示
            hourText.text = hourStr
            minuteText.text = minuteStr

            // 更新日期显示
            dateText.text = currentTime.toLocaleDateString(Qt.locale("zh_CN"), "yyyy年MM月dd日 dddd")
        }
    }

    Component.onCompleted: {
        // 加载壁纸设置
        settingsManager.loadSettings()

        // 初始更新时间
        var currentTime = new Date()

        // 获取小时和分钟
        var hours = currentTime.getHours()
        var minutes = currentTime.getMinutes()

        // 格式化小时（确保两位数显示）
        var hourStr = hours < 10 ? "0" + hours : hours.toString()
        // 格式化分钟（确保两位数显示）
        var minuteStr = minutes < 10 ? "0" + minutes : minutes.toString()

        // 初始化时间显示
        hourText.text = hourStr
        minuteText.text = minuteStr

        // 初始化日期显示
        dateText.text = currentTime.toLocaleDateString(Qt.locale("zh_CN"), "yyyy年MM月dd日 dddd")

        // 显示窗口
        visible = true
        raise()
        requestActivate()
    }

    // 防止用户通过Alt+F4或其他方式关闭锁屏窗口
    onClosing: (close) => {
        console.log("锁屏界面收到关闭请求，阻止关闭")
        // 阻止关闭事件，不允许关闭锁屏窗口
        close.accepted = false
    }
}
