import QtQuick 2.12

ListModel {
    ListElement {
        menu_option_text: "People"
        menu_option_icon_path: "qrc:/qml/icons/people.png"
        loader_path: "qrc:/qml/People_page.qml"
    }
    ListElement {
        menu_option_text: "Recognition"
        menu_option_icon_path: "qrc:/qml/icons/recognition.png"
        loader_path: ""
    }
    ListElement {
        menu_option_text: "Exit"
        menu_option_icon_path: "qrc:/qml/icons/exit.png"
        loader_path: "Qt.quit()"
    }
    ListElement {
        menu_option_text: "Help"
        menu_option_icon_path: "qrc:/qml/icons/help.jpg"
        loader_path: "qrc:/qml/Help_page.qml"
    }
}
