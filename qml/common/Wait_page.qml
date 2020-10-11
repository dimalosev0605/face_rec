import QtQuick 2.12
import QtQuick.Controls 2.15

Rectangle {
    color: "gray"
    opacity: 0.7
    BusyIndicator {
        id: busy_indicator
        anchors.centerIn: parent
        height: 100
        width: 100
//        running: parent.visible
    }
    MouseArea {
        anchors.fill: parent
    }
}
