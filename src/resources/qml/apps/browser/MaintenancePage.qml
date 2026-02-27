import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: maintenancePage
    color: "#f5f7fa"
    anchors.fill: parent

    Column {
        spacing: 20
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 500)

        Text {
            text: "🔧"
            font.pixelSize: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "浏览器维护中"
            color: "#2c3e50"
            font.pixelSize: 28
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "浏览器内核炸了awa，之后可能修也可能不修。"
            color: "#7f8c8d"
            font.pixelSize: 16
            wrapMode: Text.Wrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
