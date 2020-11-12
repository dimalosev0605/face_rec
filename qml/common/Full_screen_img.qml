import QtQuick.Window 2.12
import QtQuick 2.12

Window {
    id: full_screen_window
    visible: true
    height: Screen.desktopAvailableHeight
    width: Screen.desktopAvailableWidth
    property alias img_source: img.source
    property bool window_type // true - window for selected images, false - window for processed image.
    property real darker_factor: 1.2

    flags: Qt.FramelessWindowHint
    color: "transparent"

    Rectangle {
        id: font_rect
        anchors.fill: parent
        color: "#333333"
        opacity: 0.9
    }
    Rectangle {
        id: close_window_btn
        anchors {
            top: parent.top
            right: parent.right
        }
        width: 90
        height: width
        color: close_window_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        MouseArea {
            id: close_window_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                full_screen_window.close()
                full_screen_window.destroy()
            }
            onContainsMouseChanged: {
                close_window_btn_canvas.requestPaint()
            }
        }
        Canvas {
            id: close_window_btn_canvas
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: width
            rotation: 45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = close_window_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width / 2, height)
                ctx.moveTo(0, height / 2)
                ctx.lineTo(width, height / 2)
                ctx.stroke()
            }
        }
    }

    Item {
        id: canvas_properties
        property color hovered_color: "#ffffff"
        property color default_color: "#bfbfbf"
        property int line_width: 5
        property int delta: 20
    }
    Rectangle {
        id: right_arrow_btn
        anchors {
            top: close_window_btn.bottom
            right: parent.right
        }
        width: close_window_btn.width
        height: parent.height - close_window_btn.height * 2
        color: right_arrow_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        visible: full_screen_window.window_type ? selected_photos_list_view.currentIndex !== (selected_photos_list_view.count - 1) : false
        MouseArea {
            id: right_arrow_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                right_arrow_canvas.requestPaint()
            }
            onClicked: {
                selected_photos_list_view.incrementCurrentIndex()
                img.source = selected_photos_list_view.currentItem.selected_img_preview_src
            }
        }
        Canvas {
            id: right_arrow_canvas
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width / 2
            height: width
            rotation: 45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = right_arrow_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width + canvas_properties.delta, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width + canvas_properties.delta, canvas_properties.line_width + canvas_properties.delta)
                ctx.stroke()
            }
        }
    }
    Rectangle {
        id: left_arrow_btn
        anchors {
            top: close_window_btn.bottom
            left: parent.left
        }
        width: right_arrow_btn.width
        height: right_arrow_btn.height
        color: left_arrow_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        visible: full_screen_window.window_type ? selected_photos_list_view.currentIndex !== 0 : false
        MouseArea {
            id: left_arrow_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                left_arrow_canvas.requestPaint()
            }
            onClicked: {
                selected_photos_list_view.decrementCurrentIndex()
                img.source = selected_photos_list_view.currentItem.selected_img_preview_src
            }
        }
        Canvas {
            id: left_arrow_canvas
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width / 2
            height: width
            rotation: -45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = left_arrow_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(canvas_properties.delta + canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width, canvas_properties.delta + canvas_properties.line_width)
                ctx.stroke()
            }
        }
    }
    Row {
        id: zoom_btns_row
        anchors {
            top: parent.top
            topMargin: close_window_btn.anchors.topMargin
            horizontalCenter: parent.horizontalCenter
        }
        width: 240
        height: 30
        Custom_btn {
            id: zoom_out_btn
            pressed_color: "gray"
            border_width: 0
            height: parent.height
            width: parent.width / 3
            onClicked: {
                if(img.zoom > img.min_zoom) {
                    img.zoom = Number((img.zoom - img.zoomStep).toFixed(1))
                }
            }
            icon.source: "qrc:/qml/icons/remove.png"
        }
        Custom_btn {
            id: set_default_zoom_btn
            pressed_color: "gray"
            border_width: 0
            height: parent.height
            width: parent.width / 3
            onClicked: {
                img.zoom = 0.0
            }
            text: "Default"
        }
        Custom_btn {
            id: zoom_in_btn
            pressed_color: "gray"
            border_width: 0
            height: parent.height
            width: parent.width / 3
            onClicked: {
                if(img.zoom < img.max_zoom) {
                    img.zoom = Number((img.zoom + img.zoomStep).toFixed(1))
                }
            }
            icon.source: "qrc:/qml/icons/add.png"
        }
    }

    Item {
        id: img_display
        anchors {
            left: left_arrow_btn.right
            leftMargin: 5
            right: right_arrow_btn.left
            rightMargin: 5
            top: zoom_btns_row.bottom
            topMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        Flickable {
            id: img_flikable
            anchors.fill: parent
            contentWidth: Math.max(img.width * img.scale, img_display.width)
            contentHeight: Math.max(img.height * img.scale, img_display.height)
            clip: true
            Image {
                id: img
                property real zoom: 0.0
                property real zoomStep: 0.1
                property real max_zoom: 5.0
                property real min_zoom: -0.5
                anchors {
                    centerIn: parent
                }
                asynchronous: true
                cache: false
                smooth: true
                antialiasing: true
                mipmap: true
                fillMode: Image.PreserveAspectFit
                scale: Math.min(img_display.width / width, img_display.height / height, 1) + zoom
                onSourceChanged: {
                    zoom = 0.0
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: {
                if(Math.abs(wheel.angleDelta.y) < 30) return;
                if(wheel.angleDelta.y > 0) {
                    if(img.zoom < img.max_zoom) {
                        img.zoom = Number((img.zoom + img.zoomStep).toFixed(1))
                    }
                }
                else {
                    if(img.zoom > img.min_zoom) {
                        img.zoom = Number((img.zoom - img.zoomStep).toFixed(1))
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            full_screen_window.close()
            full_screen_window.destroy()
        }
    }
    Shortcut {
        sequence: "Left"
        enabled: full_screen_window.window_type
        onActivated: {
            left_arrow_btn_m_area.clicked(null)
        }
    }
    Shortcut {
        sequence: "Right"
        enabled: full_screen_window.window_type
        onActivated: {
            right_arrow_btn_m_area.clicked(null)
        }
    }
}
