import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.FileSystem
import ZiyanOS
import ZiyanOS.Apps 1.0

BaseAppWindow {
    id: imageViewer
    width: 800
    height: 600
    appId: "imageviewer"
    windowTitle: "图片查看器"
    contentBackground: "#2c3e50"

    property string currentImagePath: ""
    property var fileSystem: FileSystem {}
    property var filePicker: null
    

    contentItem: Item {
        anchors.fill: parent

        // 主图片显示区域
        Item {
            id: imageView
            anchors.fill: parent

            // 图片容器 - 始终居中
            Item {
                id: imageContainer
                anchors.centerIn: parent
                width: Math.min(parent.width - 40, image.sourceSize.width)
                height: Math.min(parent.height - 80, image.sourceSize.height)

                Image {
                    id: image
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectFit
                    source: currentImagePath ? "file:///" + currentImagePath : ""
                    asynchronous: true
                    cache: false

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            console.log("图片加载成功: " + image.sourceSize.width + "x" + image.sourceSize.height)
                        } else if (status === Image.Error) {
                            showError("无法加载图片")
                        }
                    }
                }
            }

            // 当没有图片时显示的提示
            Rectangle {
                anchors.centerIn: parent
                width: 400
                height: 200
                color: "transparent"
                visible: currentImagePath === ""

                Column {
                    spacing: 20
                    anchors.centerIn: parent

                    Text {
                        text: "🖼️"
                        font.pixelSize: 60
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "未打开图片"
                        font.pixelSize: 18
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "点击下方按钮打开图片"
                        font.pixelSize: 14
                        color: "#bdc3c7"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // 底部工具栏
        Rectangle {
            id: toolbar
            width: parent.width
            height: 50
            anchors.bottom: parent.bottom
            color: "#34495e"
            opacity: 0.9

            Row {
                spacing: 10
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                // 打开按钮 - 移到左侧
                Rectangle {
                    width: 120
                    height: 35
                    color: "#3498db"
                    radius: 6

                    Text {
                        text: "打开图片"
                        color: "white"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: showImagePicker()
                    }
                }
            }

            // 图片信息 - 居中显示
            Rectangle {
                width: 300
                height: 35
                anchors.centerIn: parent
                color: "transparent"

                Text {
                    text: {
                        if (currentImagePath === "") return "未打开图片"
                        var fileName = getFileName(currentImagePath)
                        var sizeText = image.status === Image.Ready ?
                            Math.round(image.sourceSize.width) + "×" + Math.round(image.sourceSize.height) + "像素" : "加载中..."
                        return fileName + " • " + sizeText
                    }
                    color: "white"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }
            }
        }
    }

    // 显示图片选择器
    function showImagePicker() {
        filePicker = filePickerComponent.createObject(imageViewer, {
            "selectFolder": false,
            "fileFilters": [".jpg", ".jpeg", ".png", ".bmp", ".gif", ".svg", ".webp"],
            "fileMode": "open"
        })

        filePicker.fileSelected.connect(function(path) {
            loadImage(path)
            filePicker.destroy()
        })

        filePicker.canceled.connect(function() {
            filePicker.destroy()
        })

        filePicker.showWindow()
    }

    // 加载图片
    function loadImage(path) {
        console.log("加载图片: " + path)
        currentImagePath = path
        imageViewer.windowTitle = "图片查看器 - " + getFileName(path)
    }

    // 显示错误
    function showError(message) {
        console.log("图片查看器错误: " + message)
        // 可以添加错误对话框
        currentImagePath = ""
        imageViewer.windowTitle = "图片查看器"
    }

    // 获取文件名
    function getFileName(path) {
        var lastSlash = Math.max(path.lastIndexOf('\\'), path.lastIndexOf('/'))
        return path.substring(lastSlash + 1)
    }

    // 公共方法：打开图片 - 修复：确保从文件管理器打开时能正确加载图片
    function openImage(path) {
        console.log("图片查看器 openImage 被调用，路径:", path)
        if (path && typeof path === 'string') {
            // 使用 Qt.callLater 确保窗口完全初始化后再加载图片
            Qt.callLater(function() {
                loadImage(path)
            })
        } else {
            console.log("无效的文件路径参数")
        }
    }

    // 文件选择器组件
    Component {
        id: filePickerComponent
        FilePicker {}
    }

    // 键盘快捷键
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_O && (event.modifiers & Qt.ControlModifier)) {
            showImagePicker()
        }
    }

    Component.onCompleted: {
        // 确保可以接收键盘事件
        forceActiveFocus()
    }
}
