import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ZiyanOS

ZiyanWindow {
    id: easterEggWindow
    width: 400
    height: 200
    windowTitle: "🎉 彩蛋"

    contentItem: Item {
        anchors.fill: parent

        Column {
            anchors.centerIn: parent

            Text {
                text: "恭喜你发现了彩蛋！\n但这里似乎什么都没有~\n都看到这里了，给个三连呗！"
                color: "black"
                font.pixelSize: 24
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Component.onCompleted: {
        console.log("彩蛋窗口已打开！")
    }
}
