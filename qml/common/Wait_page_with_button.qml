import QtQuick 2.12
import QtQuick.Controls 2.15

//import Image_handler_qml 1.0
import Add_new_person_image_handler_qml 1.0

Rectangle {
    id: root

    property Add_new_person_image_handler add_new_person_image_handler: null
    property Image processed_img

    Component.onDestruction: {
        console.log("Wait_page_with_button destroyed. id = " + root)
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
            if(add_new_person_image_handler !== null) {
                add_new_person_image_handler.cancel()
            }
            processed_img.source = ""
            root.visible = false
        }
    }
}
