import QtQuick 2.12
import QtQuick.Controls 2.15

Item {
    id: people_page_item
    property alias loader: loader
    objectName: "People_page"
    SplitView {
        id: split_view
        anchors.fill: parent
        orientation: Qt.Horizontal
        handle: Rectangle {
            color: "#000000"
            implicitWidth: 1
            height: parent.height
        }

        Rectangle {
            id: people_list
            height: parent.height
            SplitView.minimumWidth: 250
            implicitWidth: 400
//            color: "lightblue"
            color: "red"
            TextField {
                id: search_people_input
                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    topMargin: 5
                }
                height: 30
                property int space_between_items: 10
                width: parent.width - anchors.leftMargin - add_new_people_btn.width - add_new_people_btn.anchors.rightMargin - space_between_items
                placeholderText: "Search"
                background: Rectangle {
                    color: search_people_input.activeFocus ? "white" : "gray"
                    border.color: search_people_input.activeFocus ? "steelblue" : "transparent"
                    border.width: 2
                    radius: 5
                }
            }
            Rectangle {
                id: add_new_people_btn
                anchors {
                    topMargin: search_people_input.anchors.topMargin
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: search_people_input.verticalCenter
                }
                height: search_people_input.height * 0.9
                width: height
                radius: 5
                color: m_area.containsMouse ? "#00ff00" : parent.color
                Image {
                    anchors.fill: parent
                    source: "qrc:/qml/People_page_items/add_new_icon.png"
                    antialiasing: true
                    mipmap: true
                }
                MouseArea {
                    id: m_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
//                        people_list.visible = false
                        loader.source = "qrc:/qml/People_page_items/Add_new_person_page.qml"
                    }
                }
            }
            ListView {
                id: people_list_view
                anchors {
                    top: search_people_input.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    rightMargin: 1
                    bottom: parent.bottom
                }
                model: 25
                spacing: 3
                clip: true
                delegate: Rectangle {
                    color: "blue"
                    width: people_list_view.width - people_list_view_scroll_bar.implicitWidth
                    height: 35
                }
                ScrollBar.vertical: people_list_view_scroll_bar
                ScrollBar {
                    id: people_list_view_scroll_bar
//                    active: true
//                    hoverEnabled: true
//                    orientation: Qt.Vertical
//                    contentItem: Rectangle {
//                        implicitWidth: 3
//                        radius: 1
//                        color: "#ffffff"
//                    }
                }
            }
        }
//        Rectangle {
//            id: temp_rect
//            height: parent.height
//            color: "green"
//        }

        Loader {
            id: loader
            height: parent.height
        }
    }
}
