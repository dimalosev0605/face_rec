import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15

import "../../common"
import "../../delegates"

import People_manager_qml 1.0
import Selected_people_model_qml 1.0

Item {
    id: rec_page_step_1

    objectName: "qrc:/qml/main_pages/recognition_page/Step_1.qml"

    Component.onCompleted: {
        console.log("Step_1.qml created, id = " + rec_page_step_1)
//        main_qml.esc_sc.enabled = false
    }
    Component.onDestruction: {
        console.log("Step_1.qml destroyed, id = " + rec_page_step_1)
//        main_qml.esc_sc.enabled = true
    }
//    Shortcut {
//        sequence: "Esc"
//        onActivated: {
//            console.log("Step_1.qml Esc short cut.")
//        }
//    }
    Text {
        id: title
        anchors {
            top: parent.top
            topMargin: 5
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        height: 60
        width: parent.width
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 25
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: "Select people for recognition"
    }
    Close_btn {
        id: close_btn
        anchors {
            top: parent.top
            topMargin: title.anchors.topMargin
            right: parent.right
            rightMargin: 5
        }
        m_area.onClicked: {
            main_qml.wait_page.visible = true
            if(main_qml.page !== null) {
                main_qml.page.object.visible = false
                main_qml.page.object.destroy(1000)
                main_qml.page = null
            }
            main_qml.wait_page.visible = false
            main_qml.default_page.visible = true
        }
    }

    Rectangle {
        id: people_list_frame
//        color: "red"
        border.width: 3
        border.color: "#000000"
        radius: 3
        anchors {
            top: title.bottom
            topMargin: 20
            bottom: parent.bottom
            bottomMargin: 20
            left: parent.left
            leftMargin: 50
        }
        property int space_between_frames: 120
        width: (parent.width - people_list_frame.anchors.leftMargin - selected_people_list_frame.anchors.rightMargin - space_between_frames) / 2
        Text {
            id: people_list_frame_title
            anchors {
                top: parent.top
                topMargin: 2
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 15
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            width: parent.width
            height: 25
            text: "<u>Available people list " + "(" + people_list_view.count + ")</u>"
        }
        ListView {
            id: people_list_view
            anchors {
                top: people_list_frame_title.bottom
                topMargin: 5
                bottom: parent.bottom
                leftMargin: people_list_frame.border.width
                left: parent.left
                right: parent.right
                rightMargin: people_list_frame.border.width
            }
//            width: parent.width - people_list_frame.border.width
            clip: true
            model: People_manager {
                id: people_manager
                onItem_deleted: {
                    selected_people_model.accept_item(name, avatar_path)
                }
            }
            delegate: Recognition_people_list_delegate {
                width: people_list_view.width - people_list_view_scroll_bar.implicitWidth
                avatar_src: "file://" + model.avatar_path
                nickname: model.individual_name
                type: true
                m_area.onClicked: {
                    people_manager.delete_item(index)
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
    Column {
        id: move_all_btns_col
        anchors {
            verticalCenter: people_list_frame.verticalCenter
            left: people_list_frame.right
            leftMargin: 5
            right: selected_people_list_frame.left
            rightMargin: anchors.leftMargin
        }
        width: people_list_frame.space_between_frames - anchors.leftMargin - anchors.rightMargin
        height: 100
        spacing: 5
        Button {
            width: parent.width
            height: (parent.height - spacing) / 2
            text: "Select all"
            icon.source: "qrc:/qml/icons/double_right_arrow.png"
            LayoutMirroring.enabled: true
            hoverEnabled: true
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: parent.hovered ? parent.pressed ? "#00ff00" : "#cfcfcf" : "transparent"
                radius: 3
            }
            onClicked: {
                people_manager.delete_all_items()
            }
        }
        Button {
            width: parent.width
            height: (parent.height - spacing) / 2
            text: "Delet all"
            icon.source: "qrc:/qml/icons/double_left_arrow.png"
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: parent.hovered ? parent.pressed ? "#ff0000" : "#cfcfcf" : "transparent"
                radius: 3
            }
            onClicked: {
                selected_people_model.delete_all_items()
            }
        }
    }
    Rectangle {
        id: selected_people_list_frame
//        color: "green"
        border.width: 3
        border.color: "#000000"
        radius: 3
        anchors {
            top: people_list_frame.anchors.top
            topMargin: people_list_frame.anchors.topMargin
            bottom: people_list_frame.anchors.bottom
            bottomMargin: people_list_frame.anchors.bottomMargin
            right: parent.right
            rightMargin: people_list_frame.anchors.leftMargin
        }
        width: people_list_frame.width
        Text {
            id: selected_people_list_frame_title
            anchors {
                top: parent.top
                topMargin: people_list_frame_title.anchors.topMargin
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 15
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            width: parent.width
            height: 25
            text: "<u>Selected people list " + "(" + selected_people_list_view.count + ")</u>"
        }
        ListView {
            id: selected_people_list_view
            anchors {
                top: selected_people_list_frame_title.bottom
                topMargin: people_list_view.anchors.topMargin
                bottom: parent.bottom
                leftMargin: selected_people_list_frame.border.width
                left: parent.left
                right: parent.right
                rightMargin: selected_people_list_frame.border.width
            }
            clip: true
            model: Selected_people_model {
                id: selected_people_model
                onItem_deleted: {
                    people_manager.accept_item(name, avatar_path)
                }
            }
            delegate: Recognition_people_list_delegate {
                width: selected_people_list_view.width - selected_people_list_view_scroll_bar.implicitWidth
                avatar_src: "file://" + model.avatar_path
                nickname: model.individual_name
                type: false
                m_area.onClicked: {
                    selected_people_model.delete_item(index)
                }
            }
            ScrollBar.vertical: selected_people_list_view_scroll_bar
            ScrollBar {
                id: selected_people_list_view_scroll_bar
                active: true
                hoverEnabled: true
                orientation: Qt.Vertical
                size: 0.5
                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: 2
                    color: selected_people_list_view_scroll_bar.hovered ?
                           selected_people_list_view_scroll_bar.pressed ? "#000000" : "#999999" :
                           selected_people_list_view_scroll_bar.pressed ? "#000000" : "#cccccc"
                }
            }
        }
    }
}
