import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import ZiyanOS
import ZiyanOS.Apps 1.0

BaseAppWindow {
    id: browserWindow
    width: 1024
    height: 768
    windowTitle: "浏览器"
    appId: "browser"

    // 属性：初始URL，如果为空则显示欢迎页面
    property string initialUrl: ""
    // 属性：是否将初始URL视为本地文件
    property bool isLocalFile: false
    // 存储当前加载的URL，用于在失败时保持地址栏显示
    property string currentUrl: ""
    // 当前显示模式：web / welcome / error
    property string currentMode: "welcome"

    // 错误页面相关属性
    property string lastError: ""
    property string lastFailedUrl: ""

    // 使用 contentItem 属性来设置窗口内容
    contentItem: Item {
        anchors.fill: parent

        Rectangle {
            id: toolbar
            width: parent.width
            height: 45
            anchors.top: parent.top
            color: "#ffffff"
            z: 100

            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10

                // 后退按钮
                Rectangle {
                    width: 40
                    height: 30
                    color: "#3498db"
                    radius: 4

                    Text {
                        text: "←"
                        color: "white"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: webView.goBack()
                    }
                }

                // 前进按钮
                Rectangle {
                    width: 40
                    height: 30
                    color: "#3498db"
                    radius: 4

                    Text {
                        text: "→"
                        color: "white"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: webView.goForward()
                    }
                }

                // 刷新按钮
                Rectangle {
                    width: 40
                    height: 30
                    color: "#f39c12"
                    radius: 4

                    Text {
                        text: "↻"
                        color: "white"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: webView.reload()
                    }
                }

                // 首页按钮
                Rectangle {
                    width: 40
                    height: 30
                    color: "#27ae60"
                    radius: 4

                    Text {
                        text: "🏠"
                        color: "white"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: browserWindow.showWelcomePage()
                    }
                }
            }

            // 地址栏
            Rectangle {
                id: addressBarContainer
                width: parent.width - 210
                height: 30
                anchors.left: parent.left
                anchors.leftMargin: 150
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                border.color: "#bdc3c7"
                border.width: 1
                radius: 4

                TextInput {
                    id: urlBar
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    clip: true
                    onAccepted: {
                        browserWindow.navigateToUrl(text.trim(), false)
                    }
                }

                // 自定义占位符文本
                Text {
                    text: "输入网址或搜索内容..."
                    color: "#95a5a6"
                    font.pixelSize: 14
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    visible: urlBar.text === ""
                }
            }

            // 右侧按钮区域
            Row {
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                // 新建窗口按钮
                Rectangle {
                    width: 40
                    height: 30
                    color: "#9b59b6"
                    radius: 4

                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("新建浏览器窗口")
                            browserWindow.createNewBrowserWindow("", false)
                        }
                    }
                }
            }
        }

        // WebEngineView
        WebEngineView {
            id: webView
            width: parent.width
            height: parent.height - toolbar.height
            anchors.top: toolbar.bottom
            visible: browserWindow.currentMode === "web"

            settings.javascriptEnabled: true
            settings.autoLoadImages: true
            settings.errorPageEnabled: true
            settings.pluginsEnabled: true
            settings.fullScreenSupportEnabled: true
            settings.webGLEnabled: true
            settings.autoLoadIconsForPage: true
            settings.touchIconsEnabled: true
            settings.focusOnNavigationEnabled: true
            settings.allowWindowActivationFromJavaScript: true
            settings.javascriptCanOpenWindows: true
            settings.javascriptCanAccessClipboard: true
            settings.localContentCanAccessRemoteUrls: true
            settings.localContentCanAccessFileUrls: true
            settings.hyperlinkAuditingEnabled: true
            settings.scrollAnimatorEnabled: true

            // 处理新窗口请求
            onNewWindowRequested: function(request) {
                console.log("新窗口请求:", request.url)
                var url = request.url.toString()
                AppRegistry.launchApp("browser", { "url": url, "isLocalFile": false })
                request.openInDefault()
            }

            // 处理链接点击
            onLinkHovered: function(url) {
                console.log("链接悬停: " + url)
            }

            onLoadingChanged: function(loadRequest) {
                if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                    console.log("开始加载: " + loadRequest.url)
                    browserWindow.windowTitle = "加载中..."
                    browserWindow.currentUrl = loadRequest.url.toString()
                    browserWindow.currentMode = "web"
                } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    console.log("加载成功: " + loadRequest.url)
                    urlBar.text = loadRequest.url.toString()
                    browserWindow.currentUrl = loadRequest.url.toString()
                    browserWindow.windowTitle = webView.title || "浏览器"
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    console.log("加载失败: " + loadRequest.errorString)
                    browserWindow.lastError = loadRequest.errorString
                    browserWindow.lastFailedUrl = loadRequest.url.toString()
                    browserWindow.showErrorPage(loadRequest.errorString, loadRequest.url.toString())
                }
            }

            onTitleChanged: {
                browserWindow.windowTitle = title || "浏览器"
            }
        }

        // 欢迎页面
        WelcomePage {
            id: welcomePage
            anchors.fill: parent
            visible: browserWindow.currentMode === "welcome"
            onOpenUrl: function(url) {
                browserWindow.navigateToUrl(url, false)
            }
        }

        // 错误页面
        ErrorPage {
            id: errorPage
            anchors.fill: parent
            visible: browserWindow.currentMode === "error"
            onRefreshClicked: {
                browserWindow.navigateToUrl(browserWindow.lastFailedUrl, false)
            }
            onGoHomeClicked: {
                browserWindow.showWelcomePage()
            }
        }
    }

    // 导航函数
    function navigateToUrl(input, isFile) {
        var url = input
        if (!url || url === "") {
            showWelcomePage()
            return
        }
        if (isFile) {
            if (!url.startsWith("file://")) {
                url = "file://" + url
            }
        } else {
            if (!url.match(/^[a-zA-Z]+:\/\//)) {
                url = "http://" + url
            }
        }
        console.log("导航到: " + url)
        webView.url = url
    }

    // 显示欢迎页面
    function showWelcomePage() {
        currentMode = "welcome"
        urlBar.text = ""
    }

    // 显示错误页面
    function showErrorPage(error, failedUrl) {
        lastError = error
        lastFailedUrl = failedUrl
        currentMode = "error"
    }

    // 创建新浏览器窗口
    function createNewBrowserWindow(url, isFile) {
        console.log("创建新浏览器窗口，URL:", url, "isFile:", isFile)
        AppRegistry.launchApp("browser", {
            "initialUrl": url,
            "isLocalFile": isFile
        })
    }

    // 组件初始化
    Component.onCompleted: {
        console.log("浏览器初始化，initialUrl:", initialUrl, "isLocalFile:", isLocalFile)
        if (initialUrl && initialUrl !== "") {
            navigateToUrl(initialUrl, isLocalFile)
        } else {
            showWelcomePage()
        }
    }
}