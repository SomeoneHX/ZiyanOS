import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.Network 1.0   // 导入网络模块

Item {
    id: networkPage
    implicitHeight: networkContent.height

    // 创建 NetworkManager 实例
    NetworkManager {
        id: networkManager
        // 可添加信号处理等
    }

    Column {
        id: networkContent
        width: parent.width
        spacing: 20
        padding: 20

        Text {
            text: "网络信息"
            font.pixelSize: 18
            font.bold: true
            color: "#2c3e50"
        }

        Rectangle {
            width: parent.width - 40
            height: 100
            color: "#f8f9fa"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "本机 IP 地址"
                    color: "#7f8c8d"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    // 直接绑定 networkManager 的属性
                    text: networkManager.localIP || "无网络连接"
                    color: "#2c3e50"
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
