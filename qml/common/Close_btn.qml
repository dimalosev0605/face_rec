import QtQuick 2.12
import QtQuick.Controls 2.15

Rectangle {
    id: root

    width: 25
    height: width

    property alias m_area: m_area

    property color hovered_color: "#cfcfcf"
    property color pressed_color: "#00ff00"

    color: m_area.containsMouse ? m_area.pressed ? pressed_color : hovered_color : "transparent"
    radius: 2

    Image {
        id: img
        anchors {
            fill: parent
            margins: 2
        }
        mipmap: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        source: "qrc:/qml/icons/cross.png"
    }
    MouseArea {
        id: m_area
        anchors.fill: parent
        hoverEnabled: true
    }
}
