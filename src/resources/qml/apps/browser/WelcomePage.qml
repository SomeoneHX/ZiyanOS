import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: welcomePage
    color: "#f5f7fa"
    anchors.fill: parent

    // 信号：当点击链接或按钮时触发
    signal openUrl(string url)

    // 属性：可以自定义标题和副标题
    property string pageTitle: "欢迎使用字研浏览器"
    property string subtitle: "基于全新字研内核的现代化浏览器"

    Column {
        spacing: 20
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 600)

        // 标题
        Text {
            text: welcomePage.pageTitle
            color: "#27ae60"
            font.pixelSize: 28
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 副标题
        Text {
            text: welcomePage.subtitle
            color: "#7f8c8d"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 使用说明
        Text {
            text: "在地址栏输入网址开始浏览，或点击右上角的\"+\"按钮新建窗口"
            color: "#7f8c8d"
            font.pixelSize: 13
            wrapMode: Text.Wrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
