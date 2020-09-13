import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Selected_images_model_qml 1.0
import Image_handler_qml 1.0

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
    Image_handler {
        id: image_handler
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


            Item {
                id: selected_photos_frame
                anchors {
                    top: new_person_nickname_input.bottom
                    topMargin: 10
                    left: parent.left
                    leftMargin: 5
                }
                property int space_between_frames: 10
                width: (parent.width - anchors.leftMargin - processed_photos.anchors.rightMargin - space_between_frames) / 2
                height: parent.height - new_person_nickname_input.height - new_person_nickname_input.anchors.topMargin -
                        selected_photos_frame.anchors.topMargin - space_between_frames

                ListView {
                    id: selected_photos_list_view
                    anchors.fill: parent
                    cacheBuffer: 0
                    model: selected_images_model
                    clip: true
                    currentIndex: -1
                    delegate: Rectangle {
                        id: delegate
                        width: selected_photos_list_view.width
                        height: 60
                        radius: 2
                        property color hovered_color: "#d4d4d4"
                        property color default_color: "#ffffff"
                        property color highlighted_color: "#999999"
                        color: ListView.isCurrentItem ? highlighted_color :
                                                        delegate_body_m_area.containsMouse ?
                                                        delegate_body_m_area.pressed ? highlighted_color : hovered_color :
                                                        default_color
                        property alias selected_img_preview: selected_img_preview
                        Image {
                            id: selected_img_preview
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
                            source: model.file_path
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: selected_img_preview.width
                                    height: selected_img_preview.height
                                    radius: 5
                                }
                            }
                        }
                        Text {
                            id: selected_img_preview_file_name
                            anchors {
                                left: selected_img_preview.right
                                top: selected_img_preview.top
                            }
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            height: parent.height
                            width: parent.width - selected_img_preview.width - delete_from_selected_imgs_btn.width - delete_from_selected_imgs_btn.anchors.rightMargin
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
                                right: selected_img_preview_file_name.right
                            }
                            height: parent.height
                            hoverEnabled: true
                            onClicked: {
                                selected_photos_list_view.currentIndex = index
                            }
                        }
                        Rectangle {
                            id: delete_from_selected_imgs_btn
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            height: parent.height * 0.5
                            width: height * 0.85
                            radius: 4
                            property color delete_btn_pressed_color: "#9c0303"
                            color: delete_from_selected_imgs_btn_m_area.pressed ? delete_btn_pressed_color : delegate.color
                            Image {
                                id: delete_from_selected_imgs_btn_img
                                anchors.fill: parent
                                mipmap: true
                                asynchronous: true
                                fillMode: Image.PreserveAspectFit
                                source: "qrc:/qml/People_page_items/trash_icon.png"
                            }
                            MouseArea {
                                id: delete_from_selected_imgs_btn_m_area
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
                   bottom: hog_btn.top
                   bottomMargin: 10
               }
               width: height
               asynchronous: true
               mipmap: true
               fillMode: Image.PreserveAspectFit
               source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview.source
               onSourceChanged: {
                   image_handler.update_path(source)
               }
           }
           Image {
               id: processed_img
               anchors {
                   right: parent.right
                   rightMargin: 10
                   top: parent.top
                   topMargin: 10
                   bottom: parent.bottom
                   bottomMargin: 10
               }
               width: height
               asynchronous: true
               mipmap: true
               fillMode: Image.PreserveAspectFit
               source: "image://Processed_images_provider/" + selected_img.source
           }

           property int w: 80
           property int h: 30
           Rectangle {
               id: hog_btn
               anchors {
                   bottom: parent.bottom
                   left: parent.left
               }
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "HOG"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                   }
               }
           }
           Rectangle {
               id: cnn_btn
               anchors {
                   bottom: parent.bottom
                   left: hog_btn.right
               }
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "CNN"
               }
           }
           Rectangle {
               id: pyr_up
               anchors {
                   bottom: parent.bottom
                   left: cnn_btn.right
               }
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Pyr up"
               }
           }
           Rectangle {
               id: pyr_down
               anchors {
                   bottom: parent.bottom
                   left: pyr_up.right
               }
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Pyr down"
               }
           }
        }
    }
}
