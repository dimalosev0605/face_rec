import QtQuick 2.12
import QtQuick.Controls 2.15

import Image_handler_qml 1.0

Rectangle {

    property Image_handler image_handler

    color: "gray"
    opacity: 0.7
    BusyIndicator {
        id: busy_indicator
        anchors.centerIn: parent
        height: 100
        width: 100
        running: parent.visible
    }
    MouseArea {
        anchors.fill: parent
    }
    Custom_button {
        id: cancel_processing_btn
        anchors {
            top: busy_indicator.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: 150
        pressed_color: "#ff0000"
        text: "Cancel"
        m_area.onClicked: {
            image_handler.cancel()
            people_page_item.wait_loader.visible = false
        }
    }
    Shortcut {
        id: esc_sc
        sequence: "Esc"
        enabled: parent.visible
        onActivated: {
            console.log("Wait_page_2.qml Shortcut")
            cancel_processing_btn.m_area.clicked(null)
        }
    }
}
