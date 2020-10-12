import QtQuick 2.12

Rectangle {
    id: root
    color: "#cfcfcf"
    Component.onDestruction: {
        console.log("Default_page destroyed. id = " + root)
    }
}
