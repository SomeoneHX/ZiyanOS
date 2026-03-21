import QtQuick
import ZiyanOS.Apps 1.0

ZiyanWindow {
    id: baseWindow

    // 应用ID，应由 AppRegistry 在创建时设置，或由子窗口显式设置
    property string appId: ""

    Component.onCompleted: {
        if (appId && appId !== "") {
            AppRegistry.registerWindow(baseWindow, appId)
        }
    }

    // 当窗口关闭时自动注销
    onWindowClosing: {
        AppRegistry.unregisterWindow(baseWindow)
    }

    // 子窗口可以覆盖这些属性
    property string icon: ""
}