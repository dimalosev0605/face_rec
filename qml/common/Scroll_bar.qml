import QtQuick 2.12
import QtQuick.Controls 2.15

ScrollBar {
    id: root
    active: true
    hoverEnabled: true
    orientation: Qt.Vertical
    size: 0.5
    contentItem: Rectangle {
        implicitWidth: 5
        radius: 2
        color: root.hovered ?
               root.pressed ? "#000000" : "#999999" :
               root.pressed ? "#000000" : "#cccccc"
    }
}
