import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15

Item {
    id: rec_page_step_2

    objectName: "qrc:/qml/main_pages/recognition_page/Step_2.qml"

    Component.onCompleted: {
        console.log("Step_2.qml created, id = " + rec_page_step_2)
    }
    Component.onDestruction: {
        console.log("Step_2.qml destroyed, id = " + rec_page_step_2)
    }

    Button {
        id: back_btn
        anchors {
            left: parent.left
            leftMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        width: 120
        height: 40
        text: "Back"
        icon.source: "qrc:/qml/icons/back.png"
        hoverEnabled: true
        background: Rectangle {
            implicitWidth: parent.width
            implicitHeight: parent.height
            border.width: 1
            border.color: "#000000"
            color: parent.hovered ? parent.pressed ? "#ff0000" : "#cfcfcf" : "transparent"
            radius: 3
        }
        onClicked: {
            rec_page_stack_view.pop("qrc:/qml/main_pages/recognition_page/Step_2.qml", StackView.Immediate)
        }
    }
}
