import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Selected_images_model_qml 1.0
import Image_handler_qml 1.0
import People_manager_qml 1.0

Item {
    id: root

//    focus: true

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
            console.log("Canceled")
            file_dialog.close()
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            selected_photos_list_view.incrementCurrentIndex()
        }
    }
    Shortcut {
        sequence: "Up"
        onActivated: {
            selected_photos_list_view.decrementCurrentIndex()
        }
    }
//    Keys.onShortcutOverride: {
//        console.log("HERE 1")
//        if (event.key === Qt.Key_Escape) {
//            console.log("HERE 2")
//            event.accepted = true
//        }
//    }
//    Keys.onEscapePressed: {
//        console.log("Keys.onEscapePressed in Add new person page.qml")
//    }
    Shortcut {
        sequence: "Esc"
        onActivated: {
            console.log("Add new person qml Esc")
            cancel_btn_m_area.clicked(null)
        }
    }

    Selected_images_model {
        id: selected_images_model
    }
    Image_handler {
        id: image_handler
        onImg_source_changed: {
            console.log("SOURCE CHANGED = " + source)
            processed_img.source = ""
            processed_img.source = source
            console.log("New source = " + processed_img.source)
            block_ui_rect.visible = false
        }
    }
    People_manager {
        id: people_manager
        onMessage: {
            console.log("Message in QML: " + message)
        }
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
                width: 200
                height: 30
                placeholderText: "Enter person nickname"
            }

            Custom_button {
                id: add_new_person_btn
                anchors {
                    left: new_person_nickname_input.right
                    leftMargin: 10
                    verticalCenter: new_person_nickname_input.verticalCenter
                }
                width: height * 4
                height: new_person_nickname_input.height
                enabled: new_person_nickname_input.text === "" ? false : true

                default_color: "#ffffff"
                disabled_color: "#808080"
                hovered_color: "#cccccc"
                pressed_color: "#79ff4d"

                border_default_color: "#000000"
                border_pressed_color: "#0099cc"

                text_color: "#000000"
                text_pressed_color: "#ffffff"
                text: "Create new person"

                m_area.onClicked: {
                    if(people_manager.create_individual_dir(new_person_nickname_input.text)) {
                        add_new_person_btn.visible = false
                        new_person_nickname_input.focus = false
                        new_person_nickname_input.enabled = false
                        image_handler.set_current_individual_name(new_person_nickname_input.text)
                    }
                }
            }
            Custom_button {
                id: select_photos_btn
                anchors {
                    left: new_person_nickname_input.right
                    leftMargin: 10
                    top: new_person_nickname_input.top
                }
                visible: !add_new_person_btn.visible
                width: height * 4
                height: new_person_nickname_input.height

                default_color: "#ffffff"
                hovered_color: "#cccccc"
                pressed_color: "#79ff4d"

                border_default_color: "#000000"
                border_pressed_color: "#0099cc"

                text_color: "#000000"
                text_pressed_color: "#ffffff"
                text: "Select photos"

                m_area.onClicked: {
                    file_dialog.open()
                }
            }
            Custom_button {
                id: cancel_btn
                anchors {
                    left: select_photos_btn.right
                    leftMargin: 10
                    top: select_photos_btn.top
                }
                visible: !add_new_person_btn.visible
                width: height * 4
                height: new_person_nickname_input.height

                default_color: "#ffaf99"
                hovered_color: "#ff4000"
                pressed_color: "#e63900"

                border_default_color: "#000000"
                border_pressed_color: "#661400"

                text_color: "#000000"
                text_pressed_color: "#ffffff"
                text: "Cancel"

                m_area.onClicked: {
                    if(new_person_nickname_input.text !== "") {
                        people_manager.cancel_individual_creation()
                    }
                    people_page_item.loader.source = ""
                    main_qml.main_qml_sc.enabled = true
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
                visible: !add_new_person_btn.visible
                property int space_between_frames: 10
                width: (parent.width - anchors.leftMargin - processed_photos.anchors.rightMargin - space_between_frames) / 2
                height: parent.height - new_person_nickname_input.height - new_person_nickname_input.anchors.topMargin -
                        selected_photos_frame.anchors.topMargin - space_between_frames

                ListView {
                    id: selected_photos_list_view
                    anchors.fill: parent
//                    cacheBuffer: 0
                    model: selected_images_model
                    clip: true
                    currentIndex: -1
                    onCurrentIndexChanged: {
                        image_handler.cancel()
                        processed_img.source = ""
                    }
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
                                    image_handler.cancel()
                                    processed_img.source = ""
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
                visible: !add_new_person_btn.visible
                width: selected_photos_frame.width
                height: selected_photos_frame.height
            }
        }
        Rectangle {
           color: "yellow"
           visible: !add_new_person_btn.visible
           Image {
               id: selected_img
               anchors {
                   left: parent.left
                   leftMargin: 10
                   top: parent.top
                   topMargin: 30
                   bottom: hog_btn.top
                   bottomMargin: 10
               }
               width: height
               asynchronous: true
               mipmap: true
               fillMode: Image.PreserveAspectFit
               source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview.source
               onSourceChanged: {
                   image_handler.update_selected_img_path(source)
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       var comp = Qt.createComponent("Full_screen_img.qml")
                       var win = comp.createObject(root, { img_source: selected_img.source, window_type: true })
                       win.show()
                   }
               }
           }
           Text {
               id: selected_img_info
               anchors {
                   top: parent.top
                   horizontalCenter: selected_img.horizontalCenter
               }
               width: 100
               height: 20
               fontSizeMode: Text.Fit
               minimumPointSize: 1
               font.pointSize: 10
               elide: Text.ElideRight
               wrapMode: Text.WordWrap
               text: String(selected_img.sourceSize.width + " - " + selected_img.sourceSize.height)
               visible: selected_img.source.toString() === "" ? false : true
           }
           Image {
               id: processed_img
               anchors {
                   right: parent.right
                   rightMargin: 10
                   top: parent.top
                   topMargin: 30
                   bottom: parent.bottom
                   bottomMargin: 10
               }
               width: height
               asynchronous: true
               mipmap: true
               fillMode: Image.PreserveAspectFit
               cache: false
//               source: "image://Processed_images_provider/" + selected_img.source
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       var comp = Qt.createComponent("Full_screen_img.qml")
                       var win = comp.createObject(root, { img_source: processed_img.source, window_type: false })
                       win.show()
                   }
               }
           }
           Text {
               id: processed_img_info
               anchors {
                   top: parent.top
                   horizontalCenter: processed_img.horizontalCenter
               }
               width: 100
               height: 20
               fontSizeMode: Text.Fit
               minimumPointSize: 1
               font.pointSize: 10
               elide: Text.ElideRight
               wrapMode: Text.WordWrap
//               text: selected_photos_list_view.count !== 0 ? String(processed_img.sourceSize.width + " - " + processed_img.sourceSize.height) : ""
               text: String(processed_img.sourceSize.width + " - " + processed_img.sourceSize.height)
               visible: processed_img.source.toString() === "" ? false : true
//               visible: processed_img.sourceSize.width === 0 ? false : true
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
               enabled: selected_img.source === "" ? false : true
               Text {
                   anchors.centerIn: parent
                   text: "HOG"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       block_ui_rect.visible = true
                       image_handler.hog()
                   }
               }
           }
           Rectangle {
               id: cnn_btn
               anchors {
                   bottom: parent.bottom
                   left: hog_btn.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "CNN"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       block_ui_rect.visible = true
                       image_handler.cnn()
                   }
               }
           }
           Rectangle {
               id: pyr_up
               anchors {
                   bottom: parent.bottom
                   left: cnn_btn.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Pyr up"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       block_ui_rect.visible = true
                       image_handler.pyr_up()
                   }
               }
           }
           Rectangle {
               id: pyr_down
               anchors {
                   bottom: parent.bottom
                   left: pyr_up.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Pyr down"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       block_ui_rect.visible = true
                       image_handler.pyr_down()
                   }
               }
           }
           Rectangle {
               id: extract_face
               anchors {
                   bottom: parent.bottom
                   left: pyr_down.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Extract face"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       block_ui_rect.visible = true
                       image_handler.extract_face()
                   }
               }
           }
           Rectangle {
               id: delete_pyramided_imgs
               anchors {
                   bottom: parent.bottom
                   left: extract_face.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Cancel"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       processed_img.source = ""
                       image_handler.cancel()
                   }
               }
           }
           Rectangle {
               id: save
               anchors {
                   bottom: parent.bottom
                   left: delete_pyramided_imgs.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Save"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       processed_img.source = ""
                   }
               }
           }
           Rectangle {
               id: resize
               anchors {
                   bottom: parent.bottom
                   left: save.right
               }
               enabled: selected_img.source === "" ? false : true
               width: parent.w
               height: parent.h
               Text {
                   anchors.centerIn: parent
                   text: "Resize"
               }
               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                   }
               }
           }
        }
    }
    Rectangle {
        id: block_ui_rect
        anchors.fill: parent
        color: "gray"
        visible: false
        opacity: 0.5
        BusyIndicator {
            anchors.centerIn: parent
            running: block_ui_rect.visible
        }
        MouseArea {
            id: block_ui_rect_m_area
            anchors.fill: parent
        }
        Rectangle {
            anchors {
                right: parent.right
            }
            width: 200
            height: 50
            color: "red"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    block_ui_rect.visible = false
                }
            }
        }
    }
}
