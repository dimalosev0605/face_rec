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
                width: parent.width - anchors.leftMargin - add_new_people_btn_canvas.width - add_new_people_btn_canvas.anchors.rightMargin - space_between_items
                placeholderText: "Search"
                background: Rectangle {
                    color: search_people_input.activeFocus ? "white" : "gray"
                    border.color: search_people_input.activeFocus ? "steelblue" : "transparent"
                    border.width: 2
                    radius: 5
                }
            }
            Canvas {
                id: add_new_people_btn_canvas
                anchors {
                    topMargin: search_people_input.anchors.topMargin
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: search_people_input.verticalCenter
                }
                height: search_people_input.height * 0.9
                width: height
                onPaint: {
                    var ctx = getContext("2d")
                    var lw = 1.5;
                    var delta = 3
                    ctx.lineWidth = lw
                    ctx.strokeStyle = add_new_people_btn_m_area.containsMouse ? "#ffffff" : parent.color
                    ctx.fillStyle = add_new_people_btn_m_area.containsMouse ? "#00ff00" : "#ffffff"
                    ctx.beginPath()
                    ctx.ellipse(lw, lw, width - lw * 2, height - lw * 2)
                    ctx.moveTo(lw + (width - lw * 2) / 2, lw + delta)
                    ctx.lineTo(lw + (width - lw * 2) / 2, lw + height - lw * 2 - delta)
                    ctx.moveTo(lw + delta, lw + (height - lw * 2) / 2)
                    ctx.lineTo(lw + width - lw * 2 - delta, lw + (height - lw * 2) / 2)
                    ctx.fill()
                    ctx.stroke()
                }
                MouseArea {
                    id: add_new_people_btn_m_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        add_new_people_btn_canvas.requestPaint()
                    }
                    onClicked: {
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
//            asynchronous: true
//            visible: status == Loader.Ready
            height: parent.height
        }
    }
}
