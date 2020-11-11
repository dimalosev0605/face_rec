import QtQuick 2.12

Item {
    id: root
    objectName: "qrc:/qml/main_pages/help_page/Help_page.qml"
    visible: false

    Text {
        anchors.centerIn: parent
        text: "Here must be help message."
    }
    Component.onDestruction: {
        console.log("Help_page destroyed. id = " + root)
    }
}
