import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import People_manager_qml 1.0

Item {
    id: people_page_item
    property alias loader: loader
    property alias wait_loader: wait_loader
    objectName: "People_page"
//    focus: true

    People_manager {
        id: people_manager
    }

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
            SplitView.maximumWidth: 450
            implicitWidth: 400
//            color: "lightblue"
//            color: "red"
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
                        wait_loader.source = "qrc:/qml/Wait_page.qml"
                        loader.source = "qrc:/qml/People_page_items/Add_new_person_page.qml"
//                        main_qml.main_qml_sc.enabled = false
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
                model: people_manager
                clip: true
                delegate: Rectangle {
                    id: delegate
                    width: people_list_view.width - people_list_view_scroll_bar.implicitWidth
                    height: 60
                    radius: 2
                    property color hovered_color: "#d4d4d4"
                    property color default_color: "#ffffff"
                    property color highlighted_color: "#999999"
                    color: individual_avatar_m_area.containsMouse ?
                               individual_avatar_m_area.pressed ?
                               highlighted_color : hovered_color : default_color
                    Image {
                        id: individual_avatar
                        anchors {
                            left: parent.left
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        property int space_between_top_and_bottom_of_delegate: 10
                        height: parent.height - space_between_top_and_bottom_of_delegate
                        width: height
                        asynchronous: true
                        mipmap: true
                        fillMode: Image.PreserveAspectCrop
                        source: "file://" + model.avatar_path
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: individual_avatar.width
                                height: individual_avatar.height
                                radius: 5
                            }
                        }
                    }
                    Text {
                        anchors {
                            left: individual_avatar.right
                        }
                        width: delegate.width - individual_avatar.width - individual_avatar.anchors.leftMargin
                        height: delegate.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPointSize: 1
                        font.pointSize: 10
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        text: String(model.individual_name)
                    }
                    MouseArea {
                        id: individual_avatar_m_area
                        anchors.fill: parent
                        hoverEnabled: true
                    }
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
        Loader {
            id: loader
            asynchronous: true
            height: parent.height
            visible: false
            onStatusChanged: {
                if(loader.status === Loader.Ready) {
                    wait_loader.visible = false
                    loader.visible = true
                    main_qml.main_qml_sc.enabled = false
                }
            }
        }
        Loader {
            id: wait_loader
            height: parent.height
            visible: true
        }
    }
}
