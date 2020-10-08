import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Selected_images_model_qml 1.0
import Image_handler_qml 1.0
import Individual_manager_qml 1.0

Item {
    id: root

    Component.onCompleted: {
        people_page_item.wait_loader.source = "qrc:/qml/Wait_page_2.qml"
        people_page_item.wait_loader.item.image_handler = image_handler
        new_person_nickname_input.forceActiveFocus()
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
    Shortcut {
        sequence: "Esc"
        enabled: !people_page_item.wait_loader.visible
        onActivated: {
            cancel_individual_creation_btn.m_area.clicked(null)
        }
    }

    Image_handler {
        id: image_handler
        onImg_source_changed: {
            processed_img.source = ""
            processed_img.source = source
            people_page_item.wait_loader.visible = false
            extract_face_btn.enabled = false
        }
        onEnable_extract_face_btn: {
            extract_face_btn.enabled = true
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
                Keys.onReturnPressed: {
                    add_new_person_btn.m_area.clicked(null)
                }
            }

            property int space_between_btns: 10
            Custom_button {
                id: add_new_person_btn
                anchors {
                    left: new_person_nickname_input.right
                    leftMargin: parent.space_between_btns
                    verticalCenter: new_person_nickname_input.verticalCenter
                }
                width: height * 4
                height: new_person_nickname_input.height
                enabled: new_person_nickname_input.text === "" ? false : true
                text: "Create new person"
                m_area.onClicked: {
                    if(individual_manager.create_individual_dir(new_person_nickname_input.text)) {
                        add_new_person_btn.visible = false
                        new_person_nickname_input.enabled = false
                        image_handler.set_current_individual_name(new_person_nickname_input.text)
                    }
                }
            }
            Custom_button {
                id: select_photos_btn
                anchors {
                    left: new_person_nickname_input.right
                    leftMargin: parent.space_between_btns
                    top: new_person_nickname_input.top
                }
                visible: !add_new_person_btn.visible
                width: height * 4
                height: new_person_nickname_input.height
                text: "Select photos"
                m_area.onClicked: {
                    file_dialog.open()
                }
            }
            Custom_button {
                id: cancel_individual_creation_btn
                anchors {
                    left: select_photos_btn.right
                    leftMargin: parent.space_between_btns
                    top: select_photos_btn.top
                }
                visible: true
                width: height * 4
                height: new_person_nickname_input.height
                default_color: "#ffaf99"
                hovered_color: "#ff4000"
                pressed_color: "#e63900"
                border_pressed_color: "#661400"
                text: "Cancel"
                m_area.onClicked: {
                    individual_manager.cancel_individual_creation()
                    people_page_item.loader.source = ""
                    main_qml.main_qml_sc.enabled = true
                }
            }
            Custom_button {
                id: finish_person_creation_btn
                anchors {
                    left: cancel_individual_creation_btn.right
                    leftMargin: parent.space_between_btns
                    verticalCenter: new_person_nickname_input.verticalCenter
                }
                width: height * 4
                height: new_person_nickname_input.height
                text: "Add person"
                visible: processed_photos_list_view.count === 0 ? false : true
                m_area.onClicked: {
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
                width: (parent.width - anchors.leftMargin - processed_photos_frame.anchors.rightMargin - space_between_frames) / 2
                height: parent.height - new_person_nickname_input.height - new_person_nickname_input.anchors.topMargin -
                        selected_photos_frame.anchors.topMargin - space_between_frames

                ListView {
                    id: selected_photos_list_view
                    anchors.fill: parent
                    model: Selected_images_model { id: selected_images_model }
                    clip: true
                    currentIndex: -1
                    onCurrentIndexChanged: {
                        image_handler.cancel()
                        extract_face_btn.enabled = false
                        save_btn.enabled = false
                        processed_img.source = ""
                    }
                    delegate: Selected_photos_delegate {
                        width: selected_photos_list_view.width
                        color: (ListView.isCurrentItem ? highlighted_color :
                                                        delegate_body_m_area.containsMouse ?
                                                        delegate_body_m_area.pressed ?
                                                        highlighted_color : hovered_color :
                                                        default_color)
                        selected_img_preview_src: model.file_path
                        selected_img_preview_file_name: model.file_name
                        delegate_body_m_area.onClicked: {
                            selected_photos_list_view.currentIndex = index
                        }
                        delete_from_selected_imgs_btn_m_area.onClicked: {
                            image_handler.cancel()
                            extract_face_btn.enabled = false
                            processed_img.source = ""
                            selected_images_model.delete_image(index)
                        }
                    }
                }
            }
            Item {
                id: processed_photos_frame
                anchors {
                    top: selected_photos_frame.top
                    right: parent.right
                    rightMargin: selected_photos_frame.anchors.leftMargin
                }
                visible: !add_new_person_btn.visible
                width: selected_photos_frame.width
                height: selected_photos_frame.height
                ListView {
                    id: processed_photos_list_view
                    anchors.fill: parent
                    model: Individual_manager {
                        id: individual_manager
                        onMessage: {
                            console.log("Message in QML: " + message)
                        }
                    }
                    clip: true
                    currentIndex: -1
                    delegate: Processed_photos_delegate {
                        width: processed_photos_list_view.width
                        source_img_src: "file://" + String(model.src_img_path)
                        extracted_face_img_src: "file://" + String(model.extracted_face_img_path)
                        extracted_face_img_file_name: String(model.file_name)
                        delete_from_processed_imgs_btn_m_area.onClicked: {
                            individual_manager.delete_individual_face(index)
                        }
                    }
                }
            }
        }

        SplitView {
            orientation: Qt.Horizontal
            handle: Rectangle {
                color: "#000000"
                width: parent.width / 2
                implicitWidth: 1
            }
            Rectangle {
                height: parent.height
                implicitWidth: parent.width / 2
                color: "#ffb3b3"

                Text {
                    id: selected_img_info
                    anchors {
                        top: parent.top
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width
                    height: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: selected_photos_list_view.currentItem !== null ?
                          String(selected_photos_list_view.currentItem.selected_img_preview_file_name +
                          "   " +
                          "(" +
                          selected_img.sourceSize.width + " x " + selected_img.sourceSize.height +
                          ")") : ""
                }
                Image {
                    id: selected_img
                    anchors {
                        top: selected_img_info.bottom
                        topMargin: 10
                        bottom: selected_img_row_buttons.top
                        bottomMargin: anchors.topMargin
                        left: parent.left
                        leftMargin: 5
                        right: parent.right
                        rightMargin: anchors.leftMargin
                    }
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                    source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview_src
                    onSourceChanged: {
                        image_handler.update_selected_img_path(source)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(selected_img.source.toString() === "") return
                            var comp = Qt.createComponent("Full_screen_img.qml")
                            var win = comp.createObject(root, { img_source: selected_img.source, window_type: true })
                            win.show()
                        }
                    }
                }
                Row {
                    id: selected_img_row_buttons
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: 5
                        left: parent.left
                        leftMargin: 5
                        right: parent.right
                        rightMargin: anchors.leftMargin
                    }
                    height: 60
                    spacing: 10
                    property int number_of_cols: 3
                    property int number_of_rows: 2
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_button {
                            id: hog_btn
                            text: "HOG"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            m_area.onClicked: {
                                people_page_item.wait_loader.visible = true
                                image_handler.hog()
                            }
                        }
                        Custom_button {
                            id: cnn_btn
                            text: "CNN"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            m_area.onClicked: {
                                people_page_item.wait_loader.visible = true
                                image_handler.cnn()
                            }
                        }
                    }
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_button {
                            id: pyr_up_btn
                            text: "Pyr up"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            m_area.onClicked: {
                                people_page_item.wait_loader.visible = true
                                image_handler.pyr_up()
                            }
                        }
                        Custom_button {
                            id: pyr_down_btn
                            text: "Pyr down"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            m_area.onClicked: {
                                people_page_item.wait_loader.visible = true
                                image_handler.pyr_down()
                            }
                        }
                    }
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_button {
                            id: resize_btn
                            text: "Resize"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            m_area.onClicked: {
                                new_size_popup.open()
                            }
                            Popup {
                                id: new_size_popup
                                x: resize_btn.x
                                y: resize_btn.y - height
                                visible: false
                                background: Rectangle {
                                    id: background
                                    implicitWidth: resize_btn.width
                                    implicitHeight: col.item_h * 3 + 2 * col.spacing
                                    border.color: "#000000"
                                }
                                contentItem: Column {
                                    id: col
                                    property int item_h: 30
                                    spacing: 2
                                    TextField {
                                        id: width_input
                                        height: col.item_h
                                        width: parent.width
                                        placeholderText: "max 3840"
                                        text: processed_img.source.toString() === "" ? selected_img.sourceSize.width : processed_img.sourceSize.width
                                        validator: IntValidator{bottom: 1; top: 3840;}
                                    }
                                    TextField {
                                        id: height_input
                                        height: col.item_h
                                        width: parent.width
                                        placeholderText: "max 2160"
                                        text: processed_img.source.toString() === "" ? selected_img.sourceSize.height : processed_img.sourceSize.height
                                        wrapMode: TextInput.WrapAnywhere
                                        validator: IntValidator{bottom: 1; top: 2160;}
                                    }
                                    Custom_button {
                                        height: col.item_h
                                        width: parent.width
                                        text: "Ok"
                                        m_area.onClicked: {
                                            if(width_input.acceptableInput && height_input.acceptableInput) {
                                                people_page_item.wait_loader.visible = true
                                                image_handler.resize(width_input.text, height_input.text)
                                                new_size_popup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Custom_button {
                            id: cancel_btn
                            text: "Cancel"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: processed_img.source.toString() === "" ? false : true
                            m_area.onClicked: {
                                processed_img.source = ""
                                image_handler.cancel()
                                extract_face_btn.enabled = false
                                save_btn.enabled = false
                            }
                        }
                    }
                }
            }
            Rectangle {
                height: parent.height
                implicitWidth: parent.width / 2
                color: "#ccffff"

                Text {
                    id: processed_img_info
                    anchors {
                        top: parent.top
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width
                    height: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: String(processed_img.sourceSize.width + " x " + processed_img.sourceSize.height)
                    visible: processed_img.source.toString() === "" ? false : true
                }
                Image {
                    id: processed_img
                    anchors {
                        top: processed_img_info.bottom
                        topMargin: 10
                        bottom: processed_img_row_buttons.top
                        bottomMargin: anchors.topMargin
                        left: parent.left
                        leftMargin: 5
                        right: parent.right
                        rightMargin: anchors.leftMargin
                    }
                    mipmap: true
                    cache: false
                    source: ""
                    fillMode: sourceSize.width === 150 ? Image.Pad : Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(processed_img.source.toString() === "") return
                            var comp = Qt.createComponent("Full_screen_img.qml")
                            var win = comp.createObject(root, { img_source: processed_img.source, window_type: false })
                            win.show()
                        }
                    }
                }
                Row {
                    id: processed_img_row_buttons
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: 5
                        left: parent.left
                        leftMargin: 5
                        right: parent.right
                        rightMargin: anchors.leftMargin
                    }
                    height: 60
                    spacing: 10
                    Custom_button {
                        id: extract_face_btn
                        text: "Extract face"
                        height: parent.height
                        width: (parent.width - parent.spacing) / 2
                        enabled: false
                        m_area.onClicked: {
                            people_page_item.wait_loader.visible = true
                            image_handler.extract_face()
                            save_btn.enabled = true
                        }
                    }
                    Custom_button {
                        id: save_btn
                        text: "Save"
                        height: parent.height
                        width: (parent.width - parent.spacing) / 2
                        enabled: false
                        m_area.onClicked: {
                            if(individual_manager.add_individual_face(selected_img.source.toString(),
                                                               processed_img.source.toString())) {
                                image_handler.cancel()
                                save_btn.enabled = false
                                processed_img.source = ""
                                selected_images_model.delete_image(selected_photos_list_view.currentIndex)
                            }
                        }
                    }
                }
            }
        }
    }
}
