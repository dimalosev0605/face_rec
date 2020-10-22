import QtQuick 2.12
import QtQuick.Controls 2.15

Button {
    property int border_width: 1
    property int radius: 3
    property color pressed_color: "#00ff00"
    hoverEnabled: true
    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
        border.width: parent.border_width
        border.color: "#000000"
        color: parent.enabled ? parent.hovered ? parent.pressed ? pressed_color : "#cfcfcf" : "transparent" : "#cfcfcf"
        radius: parent.radius
    }
}
