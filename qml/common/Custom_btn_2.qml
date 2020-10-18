import QtQuick 2.12
import QtQuick.Controls 2.15

Button {
    property int border_width: 1
    property int radius: 3
    hoverEnabled: true
    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
        border.width: parent.border_width
        border.color: "#000000"
        color: parent.enabled ? parent.hovered ? parent.pressed ? "#00ff00" : "#cfcfcf" : "transparent" : "#cfcfcf"
        radius: parent.radius
    }
}
