import QtQuick 2.12

ListModel {
    ListElement {
        menu_option_text: "People"
        menu_option_icon_path: "qrc:/left_vertical_menu_bar_icons/people.png"
        loader_path: "qrc:/qml/People_page.qml"
    }
    ListElement {
        menu_option_text: "Recognition"
        menu_option_icon_path: "qrc:/left_vertical_menu_bar_icons/recognition.png"
        loader_path: ""
    }
    ListElement {
        menu_option_text: "Exit"
        menu_option_icon_path: "qrc:/left_vertical_menu_bar_icons/exit.png"
        loader_path: "Qt.quit()"
    }
    ListElement {
        menu_option_text: "Help"
        menu_option_icon_path: "qrc:/left_vertical_menu_bar_icons/help.jpg"
        loader_path: "qrc:/qml/Help_page.qml"
    }
}
