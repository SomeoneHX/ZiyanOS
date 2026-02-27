import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: windowManager
    width: 1; height: 1; visible: false; title: "窗口管理器"

    property var currentWindow: null
    property Component lockScreenComponent: null
    property Component desktopComponent: null
    property Component powerMenuComponent: null   // 新增

    function launch() { showLockScreen() }

    function showLockScreen() {
        closeCurrentWindow()
        if (!lockScreenComponent) lockScreenComponent = Qt.createComponent("LockScreen.qml")
        if (lockScreenComponent.status === Component.Ready) {
            currentWindow = lockScreenComponent.createObject(null)
            if (currentWindow) {
                currentWindow.loginSuccessful.connect(showDesktop)
                currentWindow.visible = true
            }
        }
    }

    function showDesktop() {
        closeCurrentWindow()
        if (!desktopComponent) desktopComponent = Qt.createComponent("Desktop.qml")
        if (desktopComponent.status === Component.Ready) {
            currentWindow = desktopComponent.createObject(null, { "windowManager": windowManager })
            if (currentWindow) currentWindow.visible = true
        }
    }

    // 新增：显示电源菜单
    function showPowerMenu() {
        closeCurrentWindow()
        if (!powerMenuComponent) powerMenuComponent = Qt.createComponent("PowerWindow.qml")
        if (powerMenuComponent.status === Component.Ready) {
            currentWindow = powerMenuComponent.createObject(null)
            if (currentWindow) {
                currentWindow.cancelled.connect(showDesktop)          // 取消 -> 返回桌面
                currentWindow.requestDesktopClose.connect(Qt.quit)   // 关机/重启 -> 退出
                currentWindow.visible = true
            }
        }
    }

    function closeCurrentWindow() {
        if (currentWindow) { currentWindow.close(); currentWindow.destroy(); currentWindow = null }
    }

    // 供外部调用的切换函数
    function switchToDesktop() { showDesktop() }
    function switchToLockScreen() { showLockScreen() }
    function switchToPowerMenu() { showPowerMenu() }

    Component.onCompleted: Qt.callLater(launch)
    onClosing: Qt.quit()
}
