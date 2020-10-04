import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Selected_images_model_qml 1.0
import Image_handler_qml 1.0
import People_manager_qml 1.0

Item {
    id: root

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
        onActivated: {
            console.log("Add new person qml Esc")
            cancel_individual_creation_btn.m_area.clicked(null)
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
            extract_face_btn.enabled = false
        }
        onEnable_extract_face_btn: {
            extract_face_btn.enabled = true
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
                id: cancel_individual_creation_btn
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
                width: (parent.width - anchors.leftMargin - processed_photos_frame.anchors.rightMargin - space_between_frames) / 2
                height: parent.height - new_person_nickname_input.height - new_person_nickname_input.anchors.topMargin -
                        selected_photos_frame.anchors.topMargin - space_between_frames

                ListView {
                    id: selected_photos_list_view
                    anchors.fill: parent
                    model: selected_images_model
                    clip: true
                    currentIndex: -1
                    onCurrentIndexChanged: {
                        image_handler.cancel()
                        extract_face_btn.enabled = false
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
                        property alias selected_img_preview_file_name: selected_img_preview_file_name
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
                                top: selected_img_preview.top
                                left: selected_img_preview.right
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
                            color: delete_from_selected_imgs_btn_m_area.containsPress ?
                                       delete_btn_pressed_color :
                                       delete_from_selected_imgs_btn_m_area.containsMouse ?
                                       "gray" : delegate.color
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
                                hoverEnabled: true
                                onClicked: {
                                    image_handler.cancel()
                                    extract_face_btn.enabled = false
                                    processed_img.source = ""
                                    selected_images_model.delete_image(index)
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: processed_photos_frame
                anchors {
                    top: selected_photos_frame.top
                    right: parent.right
                    rightMargin: selected_photos_frame.anchors.leftMargin
                }
                visible: !add_new_person_btn.visible
                width: selected_photos_frame.width
                height: selected_photos_frame.height
//                color: "blue"
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
                          String(selected_photos_list_view.currentItem.selected_img_preview_file_name.text +
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
                    source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview.source
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
                            text: "HOG"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : true
                            m_area.onClicked: {
                                block_ui_rect.visible = true
                                image_handler.hog()
                            }
                        }
                        Custom_button {
                            text: "CNN"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : true
                            m_area.onClicked: {
                                block_ui_rect.visible = true
                                image_handler.cnn()
                            }
                        }
                    }
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_button {
                            text: "Pyr up"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : true
                            m_area.onClicked: {
                                block_ui_rect.visible = true
                                image_handler.pyr_up()
                            }
                        }
                        Custom_button {
                            text: "Pyr down"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : true
                            m_area.onClicked: {
                                block_ui_rect.visible = true
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
                            enabled: selected_photos_list_view.currentItem === null ? false : true
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
                                        text: selected_img.sourceSize.width
                                        validator: IntValidator{bottom: 1; top: 3840;}
                                    }
                                    TextField {
                                        id: height_input
                                        height: col.item_h
                                        width: parent.width
                                        placeholderText: "max 2160"
                                        text: selected_img.sourceSize.height
                                        wrapMode: TextInput.WrapAnywhere
                                        validator: IntValidator{bottom: 1; top: 2160;}
                                    }
                                    Custom_button {
                                        height: col.item_h
                                        width: parent.width
                                        text: "Ok"
                                        m_area.onClicked: {
                                            if(width_input.acceptableInput && height_input.acceptableInput) {
                                                console.log("Accepted!")
                                                image_handler.resize(width_input.text, height_input.text)
                                                new_size_popup.close()
                                            }
                                            else {
                                                console.log("Rejected")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Custom_button {
                            id: cancel
                            text: "Cancel"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: processed_img.source.toString() === "" ? false : true
                            m_area.onClicked: {
                                processed_img.source = ""
                                image_handler.cancel()
                                extract_face_btn.enabled = false
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
                            block_ui_rect.visible = true
                            image_handler.extract_face()
                        }
                    }
                    Custom_button {
                        text: "Save"
                        height: parent.height
                        width: (parent.width - parent.spacing) / 2
                        m_area.onClicked: {
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        block_ui_rect.visible = false
        console.log("HERE!!!")
    }
    Rectangle {
        id: block_ui_rect
        anchors.fill: parent
        color: "gray"
        visible: false
        opacity: 0.7
        BusyIndicator {
            id: busy_indicator
            anchors.centerIn: parent
            height: 100
            width: 100
            running: block_ui_rect.visible
        }
        MouseArea {
            id: block_ui_rect_m_area
            anchors.fill: parent
        }
        Custom_button {
            id: cancel_processing_btn
            anchors {
                top: busy_indicator.bottom
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            height: 40
            width: 150
            pressed_color: "#ff0000"
            text: "Cancel"
            m_area.onClicked: {
                image_handler.cancel()
                block_ui_rect.visible = false
            }
        }
    }
}
