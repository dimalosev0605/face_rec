import QtQuick 2.12

Rectangle {
    color: "#cfcfcf"
    Component.onDestruction: {
        console.log("Default_page destroyed!")
    }
}
