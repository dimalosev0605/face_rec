import QtQuick 2.12
import QtQuick.Controls 2.15

Rectangle {
    id: root
    Component.onDestruction: {
        console.log("Wait_page destroyed. id = " + root)
    }

    visible: false
    color: "gray"
    opacity: 0.7
    BusyIndicator {
        id: busy_indicator
        anchors.centerIn: parent
        height: 100
        width: 100
    }
    MouseArea {
        anchors.fill: parent
    }
}
