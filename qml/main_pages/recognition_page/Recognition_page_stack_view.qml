import QtQuick 2.12
import QtQuick.Controls 2.15

StackView {
    id: rec_page_stack_view
    objectName: "qrc:/qml/main_pages/recognition_page/Recognition_page_stack_view.qml"
    visible: false

    Component.onCompleted: {
        console.log("Recognition_page_stack_view.qml created, id = " + rec_page_stack_view)
    }
    Component.onDestruction: {
        console.log("Recognition_page_stack_view.qml destroyed, id = " + rec_page_stack_view)
    }

    initialItem: Step_1 {}
}
