import QtQuick 2.12
import QtQuick.Controls 2.15

import Add_new_face_image_handler_qml 1.0
import Face_recognition_image_handler_qml 1.0

Rectangle {
    id: root

    property Add_new_face_image_handler add_new_face_image_handler: null
    property Face_recognition_image_handler face_recognition_image_handler: null
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
    Custom_btn {
        id: cancel_processing_btn
        anchors {
            top: busy_indicator.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: 150
        text: "Cancel"
        pressed_color: "#ff0000"
        onClicked: {
            if(add_new_face_image_handler !== null) {
                add_new_face_image_handler.cancel()
            }
            if(face_recognition_image_handler !== null) {
                face_recognition_image_handler.cancel()
            }
            processed_img.source = ""
            root.visible = false
        }
    }
}
