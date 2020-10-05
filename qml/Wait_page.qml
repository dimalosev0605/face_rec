import QtQuick 2.12
import QtQuick.Controls 2.15

Rectangle {
    id: block_ui_rect
//    anchors.fill: parent
    color: "gray"
    visible: true
    opacity: 0.7
    BusyIndicator {
        id: busy_indicator
        anchors.centerIn: parent
        height: 100
        width: 100
        running: block_ui_rect.visible
    }
    MouseArea {
        id: block_ui_rect_m_area
        anchors.fill: parent
    }
}
