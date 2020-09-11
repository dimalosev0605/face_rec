import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2

import Selected_images_model_qml 1.0

Item {

    FileDialog {
        id: file_dialog
        title: "Please choose files"
        folder: shortcuts.home
        visible: false
        selectMultiple: true
        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
        onAccepted: {
            selected_images_model.accept_images(file_dialog.fileUrls)
            console.log("You chose: " + file_dialog.fileUrls)
            file_dialog.close()
        }
        onRejected: {
            console.log("Canceled")
            file_dialog.close()
        }
    }

    Selected_images_model {
        id: selected_images_model
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical
        handle: Rectangle {
            color: "#000000"
            width: parent.width
            implicitHeight: 1
        }

        Item {
            implicitHeight: parent.height / 2
            TextField {
                id: new_person_nickname_input
                anchors {
                    left: parent.left
                    leftMargin: 10
                    top: parent.top
                    topMargin: 10
                }
                width: 150
                height: 30
                placeholderText: "Enter person name"
            }

            Rectangle {
                id: select_photos_btn
                anchors {
                    left: new_person_nickname_input.right
                    leftMargin: 10
                    top: new_person_nickname_input.top
                }
                width: height * 3
                height: new_person_nickname_input.height
                color: m_area.pressed ? "green" : "blue"
                Text {
                    anchors.centerIn: parent
                    fontSizeMode: Text.Fit
                    text: "Select photo"
                }
                MouseArea {
                    id: m_area
                    anchors.fill: parent
                    onClicked: {
                        file_dialog.open()
                    }
                }
            }

            Rectangle {
                id: cancel_btn
                anchors {
                    left: select_photos_btn.right
                    leftMargin: 10
                    top: select_photos_btn.top
                }
                width: height * 3
                height: new_person_nickname_input.height
                color: "red"
                Text {
                    anchors.centerIn: parent
                    fontSizeMode: Text.Fit
                    text: "Cancel"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        people_page_item.loader.source = ""
                    }
                }
            }


            Rectangle {
                id: selected_photos_frame
                anchors {
                    top: new_person_nickname_input.bottom
                    topMargin: 10
                    left: parent.left
                    leftMargin: 5
                }
                border.width: 1
                border.color: "#000000"
                radius: 5
                property int space_between_frames: 10
                width: (parent.width - anchors.leftMargin - processed_photos.anchors.rightMargin - space_between_frames) / 2
                height: parent.height - new_person_nickname_input.height - new_person_nickname_input.anchors.topMargin -
                        selected_photos_frame.anchors.topMargin - space_between_frames

                ListView {
                    id: selected_photos_list_view
                    anchors.fill: parent
                    cacheBuffer: 0
                    model: selected_images_model
                    spacing: 3
                    clip: true
                    currentIndex: -1
                    delegate: Rectangle {
                        id: delegate
                        width: selected_photos_list_view.width
                        height: 50
                        color: ListView.isCurrentItem ? "blue" : delegate_body_m_area.containsMouse ? delegate_body_m_area.pressed ? "blue" : "gray" : "white"
                        property alias img: img
                        Image {
                            id: img
                            height: parent.height
                            width: height
                            asynchronous: true
                            mipmap: true
                            fillMode: Image.PreserveAspectCrop
                            source: model.file_path
                        }
                        Text {
                            id: img_filename
                            anchors {
                                left: img.right
                                top: img.top
                            }
                            height: parent.height
                            width: parent.width - img.width - delete_btn.width
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            fontSizeMode: Text.Fit
                            minimumPointSize: 1
                            font.pointSize: 10
                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                            text: String(model.file_name)
                        }
                        MouseArea {
                            id: delegate_body_m_area
                            anchors {
                                left: parent.left
                                right: img_filename.right
                            }
                            height: parent.height
                            hoverEnabled: true
                            onClicked: {
                                selected_photos_list_view.currentIndex = index
                            }
                        }
                        Rectangle {
                            id: delete_btn
                            anchors {
                                right: parent.right
                                top: parent.top
                            }
                            height: parent.height
                            width: height
                            color: delete_btn_m_area.pressed ? "red" : "green"
                            MouseArea {
                                id: delete_btn_m_area
                                anchors.fill: parent
                                onClicked: {
                                    selected_images_model.delete_image(index)
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: processed_photos
                anchors {
                    top: selected_photos_frame.top
                    right: parent.right
                    rightMargin: selected_photos_frame.anchors.leftMargin
                }
                border.width: selected_photos_frame.border.width
                border.color: selected_photos_frame.border.color
                radius: selected_photos_frame.radius
                width: selected_photos_frame.width
                height: selected_photos_frame.height
            }
        }
        Rectangle {
           color: "yellow"
           Image {
               id: selected_img
               anchors {
                   left: parent.left
                   leftMargin: 10
                   top: parent.top
                   topMargin: 10
                   bottom: parent.bottom
                   bottomMargin: 10
               }
               width: height
               asynchronous: true
               mipmap: true
               fillMode: Image.PreserveAspectFit
               source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.img.source
           }
        }
    }
}
