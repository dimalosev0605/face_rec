import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2

import Selected_images_model_qml 1.0
import "../../delegates"
import "../../common"

Item {
    id: root

    objectName: "qrc:/qml/main_pages/recognition_page/Step_2.qml"

    Component.onCompleted: {
        console.log("Step_2.qml created, id = " + root)
    }
    Component.onDestruction: {
        console.log("Step_2.qml destroyed, id = " + root)
    }

    FileDialog {
        id: file_dialog
        title: "Please choose files"
        folder: shortcuts.home
        visible: false
        selectMultiple: true
        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
        onAccepted: {
            selected_images_model.accept_images(file_dialog.fileUrls)
            file_dialog.close()
        }
        onRejected: {
            file_dialog.close()
        }
    }

    Button {
        id: back_btn
        anchors {
            left: parent.left
            leftMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        width: 120
        height: 40
        text: "Back"
        icon.source: "qrc:/qml/icons/back.png"
        hoverEnabled: true
        background: Rectangle {
            implicitWidth: parent.width
            implicitHeight: parent.height
            border.width: 1
            border.color: "#000000"
            color: parent.hovered ? parent.pressed ? "#ff0000" : "#cfcfcf" : "transparent"
            radius: 3
        }
        onClicked: {
            rec_page_stack_view.pop(StackView.Immediate).destroy(1000)
            rec_page_stack_view.pop(StackView.Immediate).destroy(500)
        }
    }

    Rectangle {
        id: curr_img_frame
        border.width: 1
        border.color: "#000000"
        radius: 3
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 30
        }
        property int space_between_frames: 200
        width: (parent.width - curr_img_frame.anchors.leftMargin - processed_img_frame.anchors.rightMargin - space_between_frames) / 2
        height: parent.height / 2 * 0.7 // TODO
        Text {
            id: current_img_frame_text
            anchors {
                top: parent.top
                topMargin: 3
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 15
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            width: parent.width
            height: 32
            text: current_img.source.toString() === "" ? "Select photos" : "Current image"
        }
        Image {
            id: current_img
            anchors {
                top: current_img_frame_text.bottom
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
            }
            width: parent.width
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview_src
        }
        Button {
            id: select_photos_btn
            anchors {
                top: parent.top
                topMargin: 3
                right: parent.right
                rightMargin: 3
            }
            height: current_img_frame_text.height - anchors.topMargin
            width: height
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: parent.hovered ? parent.pressed ? "#00ff00" : "#cfcfcf" : "transparent"
                radius: 3
            }
            Image {
                anchors.fill: parent
                source: "qrc:/qml/icons/menu.png"
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                file_dialog.open()
            }
        }
        Popup {
            id: selected_photos_popup
            x: show_selected_photos_btn.x + show_selected_photos_btn.width
            y: show_selected_photos_btn.y + show_selected_photos_btn.height
            visible: false
            background: Rectangle {
                id: background
                implicitWidth: 250
                implicitHeight: 400
                border.color: "#000000"
                border.width: 1
            }
            contentItem: ListView {
                id: selected_photos_list_view
                anchors.fill: parent
                anchors.margins: background.border.width
                model: Selected_images_model { id: selected_images_model }
                clip: true
                currentIndex: -1
                delegate: Selected_photos {
                    width: selected_photos_list_view.width
                    height: 50
                    color: (ListView.isCurrentItem ? highlighted_color :
                                                    delegate_body_m_area.containsMouse ?
                                                    delegate_body_m_area.pressed ?
                                                    highlighted_color : hovered_color :
                                                    default_color)
                    selected_img_preview_src: model.img_file_path
                    selected_img_preview_file_name: model.img_file_name
                    delegate_body_m_area.onClicked: {
                        selected_photos_list_view.currentIndex = index
                    }
                }
            }
        }

        Button {
            id: show_selected_photos_btn
            anchors {
                top: parent.top
                topMargin: select_photos_btn.anchors.topMargin
                right: select_photos_btn.left
                rightMargin: select_photos_btn.anchors.rightMargin
            }
            height: select_photos_btn.height
            width: height
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: parent.hovered ? parent.pressed ? "#00ff00" : "#cfcfcf" : "transparent"
                radius: 3
            }
            Image {
                anchors.fill: parent
                source: "qrc:/qml/icons/show_list.png"
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                selected_photos_popup.open()
            }
        }
    }
    Rectangle {
        id: processed_img_frame
        border.width: 1
        border.color: "#000000"
        radius: 3
        anchors {
            top: curr_img_frame.anchors.top
            topMargin: curr_img_frame.anchors.topMargin
            right: parent.right
            rightMargin: curr_img_frame.anchors.leftMargin
        }
        width: curr_img_frame.width
        height: curr_img_frame.height
        Text {
            id: processed_img_frame_text
            anchors {
                top: processed_img_frame.top
                topMargin: current_img_frame_text.anchors.topMargin
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: current_img_frame_text.font.pointSize
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            width: parent.width
            height: current_img_frame_text.height
            text: "Processed image"
        }
        Image {
            id: processed_img
            anchors {
                top: processed_img_frame_text.bottom
                topMargin: current_img.anchors.topMargin
                bottom: parent.bottom
                bottomMargin: curr_img_frame.anchors.bottomMargin
            }
            width: parent.width
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/qml/icons/trash.png"
        }
    }

}
