import QtQuick 2.12

ListModel {
    ListElement {
        menu_option_text: "People"
        menu_option_icon_path: "qrc:/qml/icons/people.png"
        loader_path: "qrc:/qml/main_pages/people_page/People_page.qml"
    }
    ListElement {
        menu_option_text: "Recognition"
        menu_option_icon_path: "qrc:/qml/icons/recognition.png"
        loader_path: "qrc:/qml/main_pages/recognition_page/Recognition_page_stack_view.qml"
    }
    ListElement {
        menu_option_text: "Exit"
        menu_option_icon_path: "qrc:/qml/icons/exit.png"
        loader_path: "Qt.quit()"
    }
    ListElement {
        menu_option_text: "Help"
        menu_option_icon_path: "qrc:/qml/icons/help.jpg"
        loader_path: "qrc:/qml/main_pages/help_page/Help_page.qml"
    }
}
