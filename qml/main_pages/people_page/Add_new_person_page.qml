import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Selected_images_model_qml 1.0
import Add_new_face_image_handler_qml 1.0
import Individual_manager_qml 1.0

import "../../delegates"
import "../../common"

Item {
    id: root

    objectName: "qrc:/qml/main_pages/people_page/Add_new_person_page.qml"
    visible: false

    property var wait_page: null

    Component.onCompleted: {
        console.log("Add_new_person completed!")
        new_person_nickname_input.forceActiveFocus()

        var wait_page_component = Qt.createComponent("qrc:/qml/common/Wait_page_with_button.qml")
        wait_page = wait_page_component.createObject(root,
                                                   {
                                                       "x": Qt.binding(function(){ return 0}),
                                                       "y": Qt.binding(function(){ return 0}),
                                                       "width": Qt.binding(function() { return root.width}),
                                                       "height": Qt.binding(function() { return root.height}),
                                                       add_new_face_image_handler: add_new_face_image_handler,
                                                       processed_img: processed_img
                                                   });
        main_qml.esc_sc.enabled = false
    }

    property bool update_people_list_flag: true
    Component.onDestruction: {
        console.log("Add_new_person_page destroyed. id = " + root)
        if(processed_photos_list_view.count === 0 && new_person_nickname_input.text !== "") {
            individual_manager.cancel_creation()
        }
        if(processed_photos_list_view.count !== 0 && new_person_nickname_input.text !== "") {
            // it works, but people_page destroyed firstly if user click on help page.
            if(update_people_list_flag) {
                people_page_qml.available_people_model.update()
                people_page_qml.people_list_view.currentIndex = -1
            }
        }
        if(people_page_qml.edit_page === null) {
            main_qml.esc_sc.enabled = true
        }
    }
    Connections {
        id: file_dialog_connections
        target: main_qml.file_dialog
        function onAccepted(fileUrls) {
            selected_images_model.accept_images(file_dialog.fileUrls)
            file_dialog.close()
        }
        function onRejected() {
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
            console.log("Add_new_person_page.qml Short cut")
            close_btn.m_area.clicked(null)
        }
    }

    Add_new_face_image_handler {
        id: add_new_face_image_handler
        onImg_source_changed: {
            processed_img.source = ""
            processed_img.source = source
            wait_page.visible = false
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
                    top: parent.top
                    topMargin: 10
                    left: parent.left
                    leftMargin: 10
                }
                width: 200
                height: 30
                placeholderText: "Enter person nickname"
                Keys.onReturnPressed: {
                    add_new_person_btn.clicked(null)
                }
            }

            property int space_between_btns: 10
            Custom_btn {
                id: add_new_person_btn
                anchors {
                    top: new_person_nickname_input.top
                    left: new_person_nickname_input.right
                    leftMargin: parent.space_between_btns
                }
                width: height * 2
                height: new_person_nickname_input.height
                enabled: new_person_nickname_input.text === "" ? false : true
                text: "Add"
                onClicked: {
                    if(individual_manager.add_new(new_person_nickname_input.text)) {
                        add_new_person_btn.visible = false
                        new_person_nickname_input.enabled = false
                        add_new_face_image_handler.set_current_individual_name(new_person_nickname_input.text)
                    }
                }
            }
            Custom_btn {
                id: select_photos_btn
                anchors {
                    top: new_person_nickname_input.top
                    left: new_person_nickname_input.right
                    leftMargin: parent.space_between_btns
                }
                visible: !add_new_person_btn.visible
                width: height * 2
                height: new_person_nickname_input.height
                text: "Open"
                onClicked: {
                    main_qml.file_dialog.open()
                }
            }
            Custom_btn {
                id: finish_person_creation_btn
                anchors {
                    top: new_person_nickname_input.top
                    left: select_photos_btn.right
                    leftMargin: parent.space_between_btns
                }
                width: height * 2
                height: new_person_nickname_input.height
                text: "Save"
                visible: processed_photos_list_view.count === 0 ? false : true
                onClicked: {
                    people_page_qml.available_people_model.update()
                    update_people_list_flag = false
                    people_page_qml.add_new_person_page.object.visible = false
                    people_page_qml.add_new_person_page.object.destroy(1000)
                    people_page_qml.add_new_person_page = null
                    people_page_qml.default_page.visible = true
                }
            }
            Close_btn {
                id: close_btn
                anchors {
                    top: parent.top
                    topMargin: new_person_nickname_input.anchors.topMargin
                    right: parent.right
                    rightMargin: new_person_nickname_input.anchors.leftMargin
                }
                m_area.onClicked: {
                    individual_manager.cancel_creation()
                    people_page_qml.add_new_person_page.object.visible = false
                    people_page_qml.add_new_person_page.object.destroy(1000)
                    people_page_qml.add_new_person_page = null
                    people_page_qml.default_page.visible = true
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
                        add_new_face_image_handler.cancel()
                        extract_face_btn.enabled = false
                        save_btn.enabled = false
                        processed_img.source = ""
                    }
                    delegate: Selected_photos {
                        width: selected_photos_list_view.width - selected_photos_list_view_scroll_bar.implicitWidth
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
                        delete_from_selected_imgs_btn_m_area.onClicked: {
                            add_new_face_image_handler.cancel()
                            extract_face_btn.enabled = false
                            processed_img.source = ""
                            selected_images_model.delete_image(index)
                        }
                    }
                    ScrollBar.vertical: Scroll_bar { id: selected_photos_list_view_scroll_bar }
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
                    delegate: Processed_photos {
                        width: processed_photos_list_view.width - processed_photos_list_view_scroll_bar.implicitWidth
                        source_img_src: "file://" + String(model.src_img_path)
                        extracted_face_img_src: "file://" + String(model.extracted_face_img_path)
                        extracted_face_img_file_name: String(model.file_name)
                        delete_from_processed_imgs_btn_m_area.onClicked: {
                            individual_manager.delete_face(index)
                        }
                    }
                    ScrollBar.vertical: Scroll_bar { id: processed_photos_list_view_scroll_bar }
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
            Item {
                height: parent.height
                implicitWidth: parent.width / 2

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
                        add_new_face_image_handler.set_selected_img_path(source)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(selected_img.source.toString() === "") return
                            var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
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
                        Custom_btn {
                            id: hog_btn
                            text: "HOG"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            onClicked: {
                                wait_page.visible = true
                                add_new_face_image_handler.hog()
                            }
                        }
                        Custom_btn {
                            id: cnn_btn
                            text: "CNN"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            onClicked: {
                                wait_page.visible = true
                                add_new_face_image_handler.cnn()
                            }
                        }
                    }
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_btn {
                            id: pyr_up_btn
                            text: "Pyr up"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            onClicked: {
                                wait_page.visible = true
                                add_new_face_image_handler.pyr_up()
                            }
                        }
                        Custom_btn {
                            id: pyr_down_btn
                            text: "Pyr down"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            onClicked: {
                                wait_page.visible = true
                                add_new_face_image_handler.pyr_down()
                            }
                        }
                    }
                    Column {
                        height: parent.height
                        width: (parent.width - (selected_img_row_buttons.number_of_cols - 1) * parent.spacing) / selected_img_row_buttons.number_of_cols
                        spacing: 3
                        Custom_btn {
                            id: resize_btn
                            text: "Resize"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: selected_photos_list_view.currentItem === null ? false : save_btn.enabled ? false : true
                            onClicked: {
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
                                    Custom_btn {
                                        height: col.item_h
                                        width: parent.width
                                        text: "Ok"
                                        onClicked: {
                                            if(width_input.acceptableInput && height_input.acceptableInput) {
                                                wait_page.visible = true
                                                add_new_face_image_handler.resize(width_input.text, height_input.text)
                                                new_size_popup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Custom_btn {
                            id: cancel_btn
                            text: "Cancel"
                            width: parent.width
                            height: (parent.height - parent.spacing) / selected_img_row_buttons.number_of_rows
                            enabled: processed_img.source.toString() === "" ? false : true
                            pressed_color: "#ff0000"
                            onClicked: {
                                processed_img.source = ""
                                add_new_face_image_handler.cancel()
                                extract_face_btn.enabled = false
                                save_btn.enabled = false
                            }
                        }
                    }
                }
            }
            Item {
                height: parent.height
                implicitWidth: parent.width / 2

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
                            var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
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
                    Custom_btn {
                        id: extract_face_btn
                        text: "Extract face"
                        height: parent.height
                        width: (parent.width - parent.spacing) / 2
                        enabled: false
                        onClicked: {
                            wait_page.visible = true
                            add_new_face_image_handler.extract_face()
                            save_btn.enabled = true
                        }
                    }
                    Custom_btn {
                        id: save_btn
                        text: "Save"
                        height: parent.height
                        width: (parent.width - parent.spacing) / 2
                        enabled: false
                        onClicked: {
                            if(individual_manager.add_face(selected_img.source.toString(),
                                                               processed_img.source.toString())) {
                                add_new_face_image_handler.cancel()
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
