import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Qt5Compat.GraphicalEffects

Window {
    id: ziyanWindow
    width: 400
    height: 300
    flags: Qt.FramelessWindowHint
    color: "transparent"
    visible: false
    minimumWidth: 200
    minimumHeight: 150

    // 公共属性
    property bool isWayland: platformName === "wayland"
    property string windowTitle: "窗口"
    property color titleBarColor: contentBackground
    property alias contentItem: contentContainer.data
    property color contentBackground: "#ecf0f1"
    property bool allowClose: true

    // 标题栏颜色透明度
    property real titleBarColorOpacity: 1.0
    // 计算标题栏文本颜色
    property color titleTextColor: calculateTextColor(titleBarColor)

    // 任务栏高度
    property int taskbarHeight: 50

    // 窗口调节相关属性
    property int borderWidth: 5
    property bool isResizing: false
    property point resizeStartPos: Qt.point(0, 0)
    property size resizeStartSize: Qt.size(0, 0)

    // 动画属性
    property real windowOpacityValue: 0.0
    property real windowScaleValue: 0.8
    property bool isClosing: false
    property bool isAnimating: false
    property bool isMinimized: false
    property point originalPosition: Qt.point(0, 0)
    property size originalSize: Qt.size(0, 0)
    property bool isMaximized: false

    // 控制按钮显示
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true

    // 信号
    signal windowClosing()
    signal windowActivated()
    signal windowMinimized()
    signal windowMaximized()
    signal windowRestored()

    // ========== 主容器 ==========
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: ziyanWindow.color
        radius: 8
        clip: true
        opacity: windowOpacityValue
        scale: windowScaleValue
        transformOrigin: Item.Center

        // ---------- 标题栏（三层结构） ----------
        Rectangle {
            id: titleBar
            width: parent.width
            height: 35
            color: "transparent"
            z: 1000
            topLeftRadius: 8
            topRightRadius: 8
            bottomLeftRadius: 0
            bottomRightRadius: 0

            // ---- 1. 标题栏背景层 ----
            Rectangle {
                anchors.fill: parent
                color: ziyanWindow.titleBarColor
                opacity: ziyanWindow.titleBarColorOpacity
                z: 0
            }

            // ---- 2. 文字和按钮层（上层） ----
            Text {
                text: ziyanWindow.windowTitle
                color: titleTextColor
                font.pixelSize: 16
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                z: 2
            }

            Row {
                id: windowControls
                spacing: 5
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                z: 2

                // 最小化按钮
                Rectangle {
                    id: minimizeBtn
                    width: 25
                    height: 25
                    color: "transparent"
                    radius: 4
                    visible: showMinimizeButton

                    Text {
                        text: "−"
                        color: titleTextColor
                        font.pixelSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: minimizeBtn.color = (titleTextColor === "white" ? "#34495e" : "#95a5a6")
                        onExited: minimizeBtn.color = "transparent"
                        onClicked: minimizeWindow()
                    }
                }

                // 最大化/恢复按钮
                Rectangle {
                    id: maximizeBtn
                    width: 25
                    height: 25
                    color: "transparent"
                    radius: 4
                    visible: showMaximizeButton

                    Text {
                        text: isMaximized ? "⧉" : "⛶"
                        color: titleTextColor
                        font.pixelSize: 14
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: maximizeBtn.color = (titleTextColor === "white" ? "#34495e" : "#95a5a6")
                        onExited: maximizeBtn.color = "transparent"
                        onClicked: toggleMaximize()
                    }
                }

                // 关闭按钮
                Rectangle {
                    id: closeBtn
                    width: 25
                    height: 25
                    color: "transparent"
                    radius: 4
                    visible: showCloseButton

                    Text {
                        text: "×"
                        color: titleTextColor
                        font.pixelSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: closeBtn.color = "#e74c3c"
                        onExited: closeBtn.color = "transparent"
                        onClicked: startCloseAnimation()
                    }
                }
            }

            // 拖动区域
            MouseArea {
                anchors.left: parent.left
                anchors.right: windowControls.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                property point clickPos: "0,0"
                onPressed: (mouse) => {
                    ziyanWindow.raise()
                    ziyanWindow.requestActivate()
                    if (isWayland) {
                        ziyanWindow.startSystemMove()
                    } else {
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }
                }
                onPositionChanged: (mouse) => {
                    if (!isMaximized && !isWayland) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        ziyanWindow.x += delta.x
                        ziyanWindow.y += delta.y
                    }
                }
                onDoubleClicked: toggleMaximize()
                z: 2
            }
        }

        // ---------- 内容区域 ----------
        Item {
            id: contentArea
            width: parent.width
            height: parent.height - titleBar.height
            anchors.top: titleBar.bottom
            clip: true

            Rectangle {
                id: contentSolidBackground
                anchors.fill: parent
                color: ziyanWindow.contentBackground
            }

            Item {
                id: contentContainer
                anchors.fill: parent
                clip: true
            }
        }
    }

    // ---------- 右下角调节区域 ----------
    Rectangle {
        width: 20
        height: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "transparent"
        z: 1001
        opacity: windowOpacityValue
        scale: windowScaleValue
        transformOrigin: Item.Center
        visible: !isAnimating && !isClosing && windowOpacityValue > 0.9 && !isMaximized

        Rectangle {
            width: 12
            height: 12
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: "transparent"

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = "#95a5a6";
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    ctx.moveTo(width, height - 5);
                    ctx.lineTo(width - 5, height);
                    ctx.moveTo(width, height - 10);
                    ctx.lineTo(width - 10, height);
                    ctx.moveTo(width, height - 15);
                    ctx.lineTo(width - 15, height);
                    ctx.stroke();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            onPressed: {
                isResizing = true
                resizeStartPos = Qt.point(mouse.x, mouse.y)
                resizeStartSize = Qt.size(ziyanWindow.width, ziyanWindow.height)
            }
            onPositionChanged: {
                if (isResizing && pressed && !isMaximized) {
                    var deltaX = mouse.x - resizeStartPos.x
                    var deltaY = mouse.y - resizeStartPos.y
                    var newWidth = Math.max(ziyanWindow.minimumWidth, resizeStartSize.width + deltaX)
                    var newHeight = Math.max(ziyanWindow.minimumHeight, resizeStartSize.height + deltaY)
                    ziyanWindow.width = newWidth
                    ziyanWindow.height = newHeight
                }
            }
            onReleased: {
                isResizing = false
            }
        }
    }

    // ---------- 动画定义 ----------
    ParallelAnimation {
        id: showAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "windowOpacityValue"
            from: 0.0
            to: 1.0
            duration: 200
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "windowScaleValue"
            from: 0.8
            to: 1.0
            duration: 200
            easing.type: Easing.OutQuad
        }
        onStarted: { isAnimating = true }
        onFinished: { isAnimating = false }
    }

    ParallelAnimation {
        id: closeAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "windowOpacityValue"
            from: 1.0
            to: 0.0
            duration: 150
            easing.type: Easing.InQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "windowScaleValue"
            from: 1.0
            to: 0.8
            duration: 150
            easing.type: Easing.InQuad
        }
        onStarted: { isAnimating = true }
        onFinished: {
            isAnimating = false
            if (isClosing) {
                ziyanWindow.windowClosing()
                ziyanWindow.close()
            }
        }
    }

    ParallelAnimation {
        id: minimizeAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "y"
            to: ziyanWindow.y + 100
            duration: 150
            easing.type: Easing.InQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "windowOpacityValue"
            from: 1.0
            to: 0.0
            duration: 150
            easing.type: Easing.InQuad
        }
        onStarted: { isAnimating = true }
        onFinished: {
            isAnimating = false
            ziyanWindow.visible = false
            isMinimized = true
            windowMinimized()
        }
    }

    ParallelAnimation {
        id: restoreAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "y"
            from: ziyanWindow.y
            to: originalPosition.y
            duration: 150
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "windowOpacityValue"
            from: 0.0
            to: 1.0
            duration: 150
            easing.type: Easing.OutQuad
        }
        onStarted: {
            isAnimating = true
            ziyanWindow.visible = true
        }
        onFinished: {
            isAnimating = false
            isMinimized = false
            windowRestored()
        }
    }

    ParallelAnimation {
        id: maximizeAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "x"
            to: 0
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "y"
            to: 0
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "width"
            to: Screen.width
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "height"
            to: Screen.height - taskbarHeight
            duration: 250
            easing.type: Easing.OutQuad
        }
        onStarted: { isAnimating = true }
        onFinished: {
            isAnimating = false
            isMaximized = true
            windowMaximized()
        }
    }

    ParallelAnimation {
        id: restoreFromMaximizeAnimation
        PropertyAnimation {
            target: ziyanWindow
            property: "x"
            to: originalPosition.x
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "y"
            to: originalPosition.y
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "width"
            to: originalSize.width
            duration: 250
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ziyanWindow
            property: "height"
            to: originalSize.height
            duration: 250
            easing.type: Easing.OutQuad
        }
        onStarted: { isAnimating = true }
        onFinished: {
            isAnimating = false
            isMaximized = false
            windowRestored()
        }
    }

// ---------- 辅助函数 ----------
    function calculateTextColor(backgroundColor) {
        var r = backgroundColor.r * 255
        var g = backgroundColor.g * 255
        var b = backgroundColor.b * 255
        var luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
        return luminance > 0.5 ? "black" : "white"
    }

    onTitleBarColorChanged: {
        titleTextColor = calculateTextColor(titleBarColor)
    }

    onActiveChanged: {
        if (active) windowActivated()
    }

    // ---------- 公共方法 ----------
    function showWindow(x, y) {
        if (x !== undefined && y !== undefined) {
            ziyanWindow.x = x
            ziyanWindow.y = y
            originalPosition = Qt.point(x, y)
        } else {
            ziyanWindow.x = (Screen.width - ziyanWindow.width) / 2
            ziyanWindow.y = 50
            originalPosition = Qt.point(ziyanWindow.x, ziyanWindow.y)
        }

        originalSize = Qt.size(ziyanWindow.width, ziyanWindow.height)

        isClosing = false
        isAnimating = false
        isMinimized = false
        isMaximized = false
        windowOpacityValue = 0.0
        windowScaleValue = 0.8

        ziyanWindow.show()
        ziyanWindow.requestActivate()
        showAnimation.start()
    }

    function startCloseAnimation() {
        if (!isClosing) {
            isClosing = true
            closeAnimation.start()
        }
    }

    function minimizeWindow() {
        if (!isMinimized && !isAnimating) {
            originalPosition = Qt.point(ziyanWindow.x, ziyanWindow.y)
            minimizeAnimation.start()
        }
    }

    function restoreWindow() {
        if (isMinimized && !isAnimating) {
            restoreAnimation.start()
        }
    }

    function toggleMaximize() {
        if (isAnimating) return

        if (isWayland) {
            if (isMaximized) {
                showNormal()
            } else {
                showMaximized()
            }
        } else {
            if (isMaximized) {
                restoreFromMaximizeAnimation.start()
            } else {
                originalPosition = Qt.point(ziyanWindow.x, ziyanWindow.y)
                originalSize = Qt.size(ziyanWindow.width, ziyanWindow.height)
                maximizeAnimation.start()
            }
        }
    }

    function updateWindowSettings() {
        // 窗口设置功能已移除
    }

    onVisibilityChanged: {
        isMaximized = (visibility === Window.Maximized)
        if (isMaximized) {
            // 记录原始位置和大小，以便恢复时使用
            originalPosition = Qt.point(x, y)
            originalSize = Qt.size(width, height)
        }
    }

    onClosing: (close) => {
        if (!ziyanWindow.allowClose) {
            close.accepted = false
            return
        }

        if (!isClosing) {
            close.accepted = false
            startCloseAnimation()
        } else {
            windowClosing()
        }
    }
}
