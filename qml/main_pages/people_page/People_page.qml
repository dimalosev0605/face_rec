import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import People_manager_qml 1.0

import "../../delegates"

Item {
    id: people_page_item
    objectName: "qrc:/qml/main_pages/people_page/People_page.qml"

    property alias people_manager: people_manager

    property var people_page_default_page_obj: null
    property var people_page_page_obj: null
    property var people_page_wait_page_obj: null

    Component.onDestruction: {
        console.log("People_page destroyed")
    }

    Component.onCompleted: {
        search_people_input.forceActiveFocus()
        var component = Qt.createComponent("qrc:/qml/main/Default_page.qml");
        people_page_default_page_obj = component.createObject(split_view,
                                                           {
                                                               "x": Qt.binding(function(){ return people_list.width}),
                                                               y: 0,
                                                               "width": Qt.binding(function(){ return people_page_item.width - people_list.width}),
                                                               "height": Qt.binding(function(){ return people_page_item.height})
                                                           });
        component = Qt.createComponent("qrc:/qml/common/Wait_page.qml")
        people_page_wait_page_obj = component.createObject(split_view,
                                                           {
                                                               "x": Qt.binding(function(){ return people_list.width}),
                                                               y: 0,
                                                               "width": Qt.binding(function(){ return people_page_item.width - people_list.width}),
                                                               "height": Qt.binding(function(){ return people_page_item.height}),
                                                               visible: false
                                                           });
    }

    People_manager { id: people_manager }

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
            SplitView.maximumWidth: 400
            SplitView.preferredWidth: 400
            color: "#ffffff"
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
                    color: search_people_input.activeFocus ? "white" : "#e6e6e6"
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
                    ctx.strokeStyle = add_new_people_btn_m_area.pressed ? people_list.color : "#000000"
                    ctx.fillStyle = add_new_people_btn_m_area.containsMouse ?
                                    add_new_people_btn_m_area.pressed ?
                                    "#00ff00" : "#cccccc" : add_new_people_btn_m_area.pressed ? "#00ff00" : people_list.color
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
                    onPressedChanged: {
                        add_new_people_btn_canvas.requestPaint()
                    }
                    onClicked: {

                        if(people_page_page_obj !== null) {
                            if(people_page_page_obj.object.objectName.toString() === "qrc:/qml/main_pages/people_page/Add_new_person_page.qml") return
                        }

                        people_page_default_page_obj.visible = false
                        people_page_wait_page_obj.visible = true
                        if(people_page_page_obj !== null) {
                            people_page_page_obj.object.visible = false
                            people_page_page_obj.object.destroy(1000)
                            people_page_page_obj = null
                        }

                        var component = Qt.createComponent("qrc:/qml/main_pages/people_page/Add_new_person_page.qml")
                        people_page_page_obj = component.incubateObject(split_view,
                                                                      {
                                                                          "x": Qt.binding(function(){ return people_list.width}),
                                                                          y: 0,
                                                                          "width": Qt.binding(function(){ return people_page_item.width - people_list.width}),
                                                                          "height": Qt.binding(function(){ return people_page_item.height})
                                                                      });
                        if(people_page_page_obj.status !== Component.Ready) {
                            people_page_page_obj.onStatusChanged = function(status) {
                                if(status === Component.Ready) {
                                    people_page_wait_page_obj.visible = false
                                    people_page_page_obj.object.visible = true
                                    main_qml_sc.enabled = false
                                }
                            }
                        }
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
                delegate: People_list {
                    width: people_list_view.width - people_list_view_scroll_bar.implicitWidth
                    avatar_path: "file://" + model.avatar_path
                    individual_name: model.individual_name
                    delete_individual_btn_m_area.onClicked: {
                        people_list_view.currentIndex = index
                        if(people_page_page_obj !== null) {
                            if(people_page_page_obj.object.objectName.toString() === "qrc:/qml/main_pages/people_page/Edit_individual_page.qml") {
                                if(people_page_page_obj.object.edited_individual_name === people_list_view.currentItem.individual_name) {
                                    people_page_page_obj.object.visible = false
                                    people_page_page_obj.object.destroy(1000)
                                    people_page_page_obj = null
                                    people_page_default_page_obj.visible = true
                                }
                            }
                        }
                        people_manager.delete_individual(index)
                    }
                    individual_avatar_m_area.onDoubleClicked: {
                        people_list_view.currentIndex = index

                        if(people_page_page_obj !== null) {
                            if(people_page_page_obj.object.objectName.toString() === "qrc:/qml/main_pages/people_page/Edit_individual_page.qml") {
                                if(people_page_page_obj.object.edited_individual_name === people_list_view.currentItem.individual_name) {
                                    return
                                }
                                else {
                                    people_page_page_obj.object.edited_individual_name = people_list_view.currentItem.individual_name
                                    return
                                }
                            }
                        }

                        people_page_default_page_obj.visible = false
                        people_page_wait_page_obj.visible = true
                        if(people_page_page_obj !== null) {
                            people_page_page_obj.object.visible = false
                            people_page_page_obj.object.destroy(1000)
                            people_page_page_obj = null
                        }

                        var component = Qt.createComponent("qrc:/qml/main_pages/people_page/Edit_individual_page.qml")
                        people_page_page_obj = component.incubateObject(split_view,
                                                                      {
                                                                          "x": Qt.binding(function(){ return people_list.width}),
                                                                          y: 0,
                                                                          "width": Qt.binding(function(){ return people_page_item.width - people_list.width}),
                                                                          "height": Qt.binding(function(){ return people_page_item.height}),
                                                                          edited_individual_name: people_list_view.currentItem.individual_name
                                                                      });
                        if(people_page_page_obj.status !== Component.Ready) {
                            people_page_page_obj.onStatusChanged = function(status) {
                                if(status === Component.Ready) {
                                    people_page_wait_page_obj.visible = false
                                    people_page_page_obj.object.visible = true
                                    main_qml_sc.enabled = false
                                }
                            }
                        }
                    }
                }
                ScrollBar.vertical: people_list_view_scroll_bar
                ScrollBar {
                    id: people_list_view_scroll_bar
                    active: true
                    hoverEnabled: true
                    orientation: Qt.Vertical
                    size: 0.5
                    contentItem: Rectangle {
                        implicitWidth: 5
                        radius: 2
                        color: people_list_view_scroll_bar.hovered ?
                               people_list_view_scroll_bar.pressed ? "#000000" : "#999999" :
                               people_list_view_scroll_bar.pressed ? "#000000" : "#cccccc"
                    }
                }
            }
        }
    }
}
