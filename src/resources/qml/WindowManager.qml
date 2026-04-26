import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: windowManager
    width: 1; height: 1; visible: false; title: "窗口管理器"

    property var currentWindow: null
    property var desktopWindow: null
    property var taskbarWindow: null
    property Component lockScreenComponent: null
    property Component desktopComponent: null
    property Component taskbarComponent: null
    property Component powerMenuComponent: null

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
            desktopWindow = desktopComponent.createObject(null, { "windowManager": windowManager })
            if (desktopWindow) desktopWindow.visible = true
        }

        if (!taskbarComponent) taskbarComponent = Qt.createComponent("Taskbar.qml")
        if (taskbarComponent.status === Component.Ready) {
            taskbarWindow = taskbarComponent.createObject(null, { "windowManager": windowManager })
            if (taskbarWindow) taskbarWindow.visible = true
        }
    }

    function showPowerMenu() {
        closeCurrentWindow()
        if (!powerMenuComponent) powerMenuComponent = Qt.createComponent("PowerWindow.qml")
        if (powerMenuComponent.status === Component.Ready) {
            currentWindow = powerMenuComponent.createObject(null)
            if (currentWindow) {
                currentWindow.cancelled.connect(showDesktop)
                currentWindow.requestDesktopClose.connect(Qt.quit)
                currentWindow.visible = true
            }
        }
    }

    function closeCurrentWindow() {
        if (currentWindow) { currentWindow.close(); currentWindow.destroy(); currentWindow = null }
        if (desktopWindow) { desktopWindow.close(); desktopWindow.destroy(); desktopWindow = null }
        if (taskbarWindow) { taskbarWindow.close(); taskbarWindow.destroy(); taskbarWindow = null }
    }

    function switchToDesktop() { showDesktop() }
    function switchToLockScreen() { showLockScreen() }
    function switchToPowerMenu() { showPowerMenu() }

    Component.onCompleted: Qt.callLater(launch)
    onClosing: Qt.quit()
}