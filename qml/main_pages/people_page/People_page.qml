import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import Available_people_model_qml 1.0

import "../../delegates"
import "../../common"

Item {
    id: people_page_qml
    objectName: "qrc:/qml/main_pages/people_page/People_page.qml"
    visible: false

    property alias available_people_model: available_people_model
    property alias people_list_view: people_list_view

    property var default_page: null
    property var default_page_comp: Qt.createComponent("qrc:/qml/common/Default_page.qml", people_page_qml);

    property var edit_page: null
    property var edit_page_comp: Qt.createComponent("qrc:/qml/main_pages/people_page/Edit_individual_page.qml", people_page_qml)

    property var wait_page: null
    property var wait_page_comp: Qt.createComponent("qrc:/qml/common/Wait_page.qml", people_page_qml)

    property var add_new_person_page: null
    property var add_new_person_page_comp: Qt.createComponent("qrc:/qml/main_pages/people_page/Add_new_person_page.qml", people_page_qml)

    Component.onDestruction: {
        console.log("People_page destroyed. id = " + people_page_qml)
        main_qml.esc_sc.enabled = true
    }

    Component.onCompleted: {
        search_people_input.forceActiveFocus()
        default_page = default_page_comp.createObject(split_view,
                                                {
                                                    "x": Qt.binding(function(){ return people_list.width}),
                                                    "y": Qt.binding(function(){ return 0}),
                                                    "width": Qt.binding(function(){ return people_page_qml.width - people_list.width}),
                                                    "height": Qt.binding(function(){ return people_page_qml.height})
                                                });
        wait_page = wait_page_comp.createObject(split_view,
                                                {
                                                    "x": Qt.binding(function(){ return people_list.width}),
                                                    "y": Qt.binding(function(){ return 0}),
                                                    "width": Qt.binding(function(){ return people_page_qml.width - people_list.width}),
                                                    "height": Qt.binding(function(){ return people_page_qml.height})
                                                });
    }

    Available_people_model { id: available_people_model }

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
                width: parent.width - anchors.leftMargin - add_new_person_btn.width - add_new_person_btn.anchors.rightMargin - space_between_items
                placeholderText: "Search"
                background: Rectangle {
                    color: search_people_input.activeFocus ? "white" : "#e6e6e6"
                    border.color: search_people_input.activeFocus ? "steelblue" : "transparent"
                    border.width: 2
                    radius: 5
                }
            }
            Button {
                id: add_new_person_btn
                anchors {
                    topMargin: search_people_input.anchors.topMargin
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: search_people_input.verticalCenter
                }
                height: search_people_input.height
                width: height
                icon.source: "qrc:/qml/icons/add.png"
                display: AbstractButton.IconOnly
                hoverEnabled: true
                background: Rectangle {
                    radius: 5
                    color: add_new_person_btn.hovered ? add_new_person_btn.pressed ? "#00ff00" : "#bbbbbb" : "#cfcfcf"
                }
                onClicked: {
                    people_list_view.currentIndex = -1
                    if(edit_page !== null) {
                        edit_page.object.visible = false
                        edit_page.object.destroy(1000)
                        edit_page = null
                        default_page.visible = true
                    }
                    if(add_new_person_page !== null) {
                        return
                    }
                    else {
                        default_page.visible = false
                        wait_page.visible = true

                        add_new_person_page = add_new_person_page_comp.incubateObject(split_view,
                                                                      {
                                                                          "x": Qt.binding(function(){ return people_list.width}),
                                                                          "y": Qt.binding(function(){ return 0}),
                                                                          "width": Qt.binding(function(){ return people_page_qml.width - people_list.width}),
                                                                          "height": Qt.binding(function(){ return people_page_qml.height})
                                                                      });
                        if(add_new_person_page.status !== Component.Ready) {
                            add_new_person_page.onStatusChanged = function(status) {
                                if(status === Component.Ready) {
                                    wait_page.visible = false
                                    add_new_person_page.object.visible = true
                                    esc_sc.enabled = false
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
                model: available_people_model
                clip: true
                currentIndex: -1
                delegate: People_list {
                    width: people_list_view.width - people_list_view_scroll_bar.implicitWidth
                    avatar_path: "file://" + model.avatar_path
                    individual_name: model.individual_name
                    color: (ListView.isCurrentItem ? highlighted_color :
                                                    individual_avatar_m_area.containsMouse ?
                                                    individual_avatar_m_area.pressed ?
                                                    highlighted_color : hovered_color :
                                                    default_color)
                    delete_individual_btn_m_area.onClicked: {
                        var old_index = people_list_view.currentIndex
                        people_list_view.currentIndex = index
                        if(edit_page !== null) {
                            if(edit_page.object.edited_individual_name === people_list_view.currentItem.individual_name) {
                                edit_page.object.visible = false
                                edit_page.object.destroy(1000)
                                edit_page = null
                                default_page.visible = true
                                people_list_view.currentIndex = -1
                                available_people_model.delete_individual(index)
                                return
                            }
                        }
                        available_people_model.delete_individual(index)
                        if(people_list_view.currentIndex < old_index) {
                            people_list_view.currentIndex = old_index - 1
                        }
                        else {
                            people_list_view.currentIndex = old_index
                        }
                    }
                    individual_avatar_m_area.onDoubleClicked: {

                        if(add_new_person_page !== null) {
                            add_new_person_page.object.visible = false
                            add_new_person_page.object.destroy(1000)
                            add_new_person_page = null
                            default_page.visible = true
                        }

                        people_list_view.currentIndex = index

                        if(edit_page !== null) {
                            if(edit_page.object.edited_individual_name === people_list_view.currentItem.individual_name) {
                                return
                            }
                            else {
                                edit_page.object.x = Qt.binding(function(){ return people_list.width})
                                edit_page.object.y = Qt.binding(function(){ return 0})
                                edit_page.object.width = Qt.binding(function(){ return people_page_qml.width - people_list.width})
                                edit_page.object.height = Qt.binding(function(){ return people_page_qml.height})
                                edit_page.object.edited_individual_name = people_list_view.currentItem.individual_name
                                return
                            }
                        }
                        else {
                            default_page.visible = false
                            wait_page.visible = true
                            edit_page = edit_page_comp.incubateObject(split_view,
                                                            {
                                                                "x": Qt.binding(function(){ return people_list.width}),
                                                                "y": Qt.binding(function(){ return 0}),
                                                                "width": Qt.binding(function(){ return people_page_qml.width - people_list.width}),
                                                                "height": Qt.binding(function(){ return people_page_qml.height}),
                                                                edited_individual_name: people_list_view.currentItem.individual_name,
                                                            });
                            if(edit_page.status !== Component.Ready) {
                                edit_page.onStatusChanged = function(status) {
                                    if(status === Component.Ready) {
                                        wait_page.visible = false
                                        edit_page.object.visible = true
                                        esc_sc.enabled = false
                                    }
                                }
                            }
                        }
                    }
                }
                ScrollBar.vertical: Scroll_bar { id: people_list_view_scroll_bar }
            }
        }
    }
}
