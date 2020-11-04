import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2

import Selected_images_model_qml 1.0
//import Image_handler_qml 1.0
import Face_recognition_image_handler_qml 1.0
import "../../delegates"
import "../../common"

Item {
    id: root

    objectName: "qrc:/qml/main_pages/recognition_page/Step_2.qml"

    property var wait_page: null

    Component.onCompleted: {
        console.log("Step_2.qml created, id = " + root)

        var wait_page_component = Qt.createComponent("qrc:/qml/common/Wait_page_with_button.qml")
        wait_page = wait_page_component.createObject(root,
                                                   {
                                                       "x": Qt.binding(function(){ return 0}),
                                                       "y": Qt.binding(function(){ return 0}),
                                                       "width": Qt.binding(function() { return root.width}),
                                                       "height": Qt.binding(function() { return root.height}),
                                                       face_recognition_image_handler: face_recognition_image_handler,
                                                       processed_img: processed_img
                                                   });
    }
    Component.onDestruction: {
        console.log("Step_2.qml destroyed, id = " + root)
    }

    Face_recognition_image_handler {
        id: face_recognition_image_handler
        selected_people_list: selected_people_model.get_selected_people_list()
        onImg_source_changed: {
            processed_img.source = ""
            processed_img.source = source
            recognition_img.source = ""
            wait_page.visible = false
        }
        onRecognition_finished: {
            recognition_img.source = ""
            recognition_img.source = processed_img_path
            wait_page.visible = false
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            selected_photos_list_view.incrementCurrentIndex()
        }
        enabled: !selected_photos_popup.opened
    }
    Shortcut {
        sequence: "Up"
        onActivated: {
            selected_photos_list_view.decrementCurrentIndex()
        }
        enabled: !selected_photos_popup.opened
    }
    Connections {
        id: file_dialog_connections
        target: main_qml.file_dialog
        function onAccepted(fileUrls) {
            if(selected_photos_list_view.count === 0) {
                selected_images_model.accept_images(file_dialog.fileUrls)
                selected_photos_list_view.currentIndex = 0
            }
            else {
                selected_images_model.accept_images(file_dialog.fileUrls)
            }
            file_dialog.close()
        }
        function onRejected() {
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
        height: parent.height / 2 * 0.9 // TODO
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
            height: 25
            text: selected_photos_list_view.currentItem !== null ?
                      String(selected_photos_list_view.currentItem.selected_img_preview_file_name +
                      "   " +
                      "(" +
                      current_img.sourceSize.width + " x " + current_img.sourceSize.height +
                      ")") : "Select photos --->"
        }
        Image {
            id: current_img
            anchors {
                top: current_img_frame_text.bottom
                topMargin: 5
                bottom: buttons_1_frame.top
                bottomMargin: 5
            }
            width: parent.width
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: selected_photos_list_view.currentItem === null ? "" : selected_photos_list_view.currentItem.selected_img_preview_src
            onSourceChanged: {
                face_recognition_image_handler.update_selected_img_path(source)
            }

            MouseArea {
                anchors.centerIn: parent
                width: current_img.paintedWidth
                height: current_img.paintedHeight
                onClicked: {
                    var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
                    var win = comp.createObject(root, { img_source: current_img.source, window_type: true })
                    win.show()
                }
                enabled: selected_photos_list_view.count !== 0
            }
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
                main_qml.file_dialog.open()
            }
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Select photos")
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
                onCurrentIndexChanged: {
                    face_recognition_image_handler.cancel()
                    processed_img.source = ""
                    recognition_img.source = ""
                }
                delegate: Selected_photos {
                    width: selected_photos_list_view.width - selected_photos_list_view_scroll_bar.implicitWidth
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
                    delete_from_selected_imgs_btn_m_area.onClicked: {
                        selected_images_model.delete_image(index)
                    }
                }
                ScrollBar.vertical: Scroll_bar { id: selected_photos_list_view_scroll_bar }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    width: parent.width - selected_photos_list_view_scroll_bar.implicitWidth
                    height: parent.height
                    text: "List is empty."
                    visible: selected_photos_list_view.count === 0
                }
            }
            Shortcut {
                sequence: "Down"
                enabled: selected_photos_popup.opened
                onActivated: {
                    selected_photos_list_view.incrementCurrentIndex()
                }
            }
            Shortcut {
                sequence: "Up"
                enabled: selected_photos_popup.opened
                onActivated: {
                    selected_photos_list_view.decrementCurrentIndex()
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
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Show list")
        }
        Rectangle {
            id: buttons_1_frame
            anchors {
                bottom: buttons_2_frame.top
                bottomMargin: 2
                left: curr_img_frame.left
                leftMargin: border.width + 3
                right: curr_img_frame.right
                rightMargin: border.width + 3
            }
            height: 30
            border.width: 1
            border.color: "#000000"
            radius: 5
            Row {
                id: buttons_1_row
                anchors {
                    fill: parent
                    margins: parent.border.width
                }
                spacing: 0
                property int btns_count: 4
                property real btns_width: (width - (btns_count - 1) * spacing) / btns_count
                Custom_btn {
                    id: pyr_up_btn
                    height: parent.height
                    width: parent.btns_width
                    text: "Pyr up"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        wait_page.visible = true
                        face_recognition_image_handler.pyr_up()
                    }
                }
                Custom_btn {
                    id: pyr_down_btn
                    height: parent.height
                    width: parent.btns_width
                    text: "Pyr down"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        wait_page.visible = true
                        face_recognition_image_handler.pyr_down()
                    }
                }
                Custom_btn {
                    id: resize_btn
                    height: parent.height
                    width: parent.btns_width
                    text: "Resize"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        new_size_popup.open()
                    }
                    Popup {
                        id: new_size_popup
                        x: resize_btn.width
                        y: resize_btn.height
                        background: Rectangle {
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
                                text: processed_img.source.toString() === "" ? current_img.sourceSize.width : processed_img.sourceSize.width
                                validator: IntValidator{bottom: 1; top: 3840;}
                            }
                            TextField {
                                id: height_input
                                height: col.item_h
                                width: parent.width
                                placeholderText: "max 2160"
                                text: processed_img.source.toString() === "" ? current_img.sourceSize.height : processed_img.sourceSize.height
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
                                        face_recognition_image_handler.resize(width_input.text, height_input.text)
                                        new_size_popup.close()
                                    }
                                }
                            }
                        }
                    }
                }
                Custom_btn {
                    id: cancel_btn
                    height: parent.height
                    width: parent.btns_width
                    text: "Cancel"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        face_recognition_image_handler.cancel()
                        processed_img.source = ""
                        recognition_img.source = ""
                    }
                }
            }
        }
        Rectangle {
            id: buttons_2_frame
            anchors {
                bottom: parent.bottom
                bottomMargin: 2
                horizontalCenter: buttons_1_frame.horizontalCenter
            }
            height: buttons_1_frame.height
            width: buttons_1_frame.width / 2
            border.width: buttons_1_frame.border.width
            border.color: "#000000"
            radius: buttons_1_frame.radius
            Row {
                anchors {
                    fill: parent
                    margins: buttons_1_row.anchors.margins
                }
                spacing: buttons_1_row.spacing
                property int btns_count: 2
                property real btns_width: (width - (btns_count - 1) * spacing) / btns_count
                Custom_btn {
                    id: hog_face_rec
                    height: parent.height
                    width: parent.btns_width
                    text: "HOG"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        wait_page.visible = true
                        face_recognition_image_handler.hog()
                    }
                }
                Custom_btn {
                    id: cnn_face_rec
                    height: parent.height
                    width: parent.btns_width
                    text: "CNN"
                    border_width: 1
                    radius: 0
                    enabled: current_img.source.toString() !== ""
                    onClicked: {
                        wait_page.visible = true
                        face_recognition_image_handler.cnn()
                    }
                }
            }
        }
    }


    Rectangle {
        id: processed_img_frame
        border.width: curr_img_frame.border.width
        border.color: curr_img_frame.border.color
        radius: curr_img_frame.radius
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
                top: parent.top
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
            text: "Processed image (" + String(processed_img.sourceSize.width + " x " + processed_img.sourceSize.height) + ")"
            visible: processed_img.source.toString() === "" ? false : true
        }
        Image {
            id: processed_img
            anchors {
                top: processed_img_frame_text.bottom
                topMargin: current_img.anchors.topMargin
                bottom: recognize_btn.top
                bottomMargin: current_img.anchors.bottomMargin
            }
            width: parent.width
            mipmap: true
            asynchronous: true
            cache: false
            fillMode: Image.PreserveAspectFit
            source: ""
            MouseArea {
                anchors.centerIn: parent
                width: processed_img.paintedWidth
                height: processed_img.paintedHeight
                onClicked: {
                    var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
                    var win = comp.createObject(root, { img_source: processed_img.source, window_type: false })
                    win.show()
                }
                enabled: processed_img.source.toString() !== ""
            }
        }
        Custom_btn {
            id: recognize_btn
            anchors {
                bottom: threshold_slider.top
                bottomMargin: buttons_1_frame.anchors.bottomMargin
                horizontalCenter: parent.horizontalCenter
            }
            height: buttons_1_frame.height
            width: threshold_slider.width
            text: "Recognize"
            border_width: 1
            radius: 3
            enabled: processed_img.source.toString() !== ""
            onClicked: {
                wait_page.visible = true
                face_recognition_image_handler.recognize()
            }
        }
        Slider {
            id: threshold_slider
            anchors {
                bottom: parent.bottom
                bottomMargin: buttons_2_frame.anchors.bottomMargin
                horizontalCenter: parent.horizontalCenter
            }
            onValueChanged: {
                face_recognition_image_handler.set_threshold(threshold_slider.value)
            }
            height: buttons_2_frame.height
            width: parent.width * 0.5
            from: 0
            to: 1
            value: 0.5
            stepSize: 0.01
        }
        Text {
            id: curr_slider_value
            anchors {
                left: threshold_slider.right
                top: threshold_slider.top
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 10
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            width: threshold_slider.height
            height: width
            text: threshold_slider.value.toFixed(2)
        }
    }

    Image {
        id: recognition_img
        anchors {
            top: curr_img_frame.bottom
            topMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        width: parent.width
        mipmap: true
        asynchronous: true
        cache: false
        source: ""
        fillMode: Image.PreserveAspectFit
        MouseArea {
            anchors.centerIn: parent
            width: recognition_img.paintedWidth
            height: recognition_img.paintedHeight
            enabled: parent.source.toString() !== ""
            onClicked: {
                var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
                var win = comp.createObject(root, { img_source: recognition_img.source, window_type: false })
                win.show()
            }
        }
    }
}
