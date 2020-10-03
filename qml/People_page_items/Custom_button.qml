import QtQuick 2.12

Rectangle {
    id: btn

    property alias m_area: m_area
    property string text: text.text

    property color border_default_color: "#000000"
    property color border_pressed_color: "#0099cc"

    property color default_color: "#ffffff"
    property color disabled_color: "#808080"
    property color hovered_color: "#cccccc"
    property color pressed_color: "#79ff4d"

    property color text_color: "#000000"
    property color text_pressed_color: "#ffffff"

    border.width: 1
    border.color: m_area.containsPress ? border_pressed_color : border_default_color
    radius: 3
    color: enabled ? m_area.containsPress ? pressed_color : m_area.containsMouse ? hovered_color : default_color : disabled_color

    Text {
        id: text
        width: parent.width
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        minimumPointSize: 1
        font.pointSize: 10
        font.weight: Font.Medium
        color: m_area.containsPress ? text_pressed_color : text_color
        text: btn.text
    }

    MouseArea {
        id: m_area
        anchors.fill: parent
        hoverEnabled: true
    }
}
