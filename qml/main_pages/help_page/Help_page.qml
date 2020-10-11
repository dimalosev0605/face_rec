import QtQuick 2.12

Item {
    objectName: "qrc:/qml/main_pages/help_page/Help_page.qml"
    Text {
        anchors.centerIn: parent
        text: "Here must be help message."
    }
    Component.onDestruction: {
        console.log("Help_page destroyed!")
    }
}
