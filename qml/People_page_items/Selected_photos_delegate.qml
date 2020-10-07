import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

Rectangle {
    id: delegate
    height: 60
    radius: 2

    property color hovered_color: "#d4d4d4"
    property color default_color: "#ffffff"
    property color highlighted_color: "#999999"

//    property alias selected_img_preview: selected_img_preview
    property alias selected_img_preview_src: selected_img_preview.source
    property alias selected_img_preview_file_name: selected_img_preview_file_name.text

    property alias delegate_body_m_area: delegate_body_m_area
    property alias delete_from_selected_imgs_btn_m_area: delete_from_selected_imgs_btn_m_area

//    property string selected_img_src // for full screen window.
    Image {
        id: selected_img_preview
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        property int space_between_top_and_bottom: 10
        height: parent.height - space_between_top_and_bottom
        width: height
        asynchronous: true
        mipmap: true
        fillMode: Image.PreserveAspectCrop
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
                selected_photos_list_view.currentIndex = index
                var comp = Qt.createComponent("Full_screen_img.qml")
                var win = comp.createObject(root, { img_source: selected_img_preview.source, window_type: true })
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
               delete_btn_pressed_color : delete_from_selected_imgs_btn_m_area.containsMouse ?
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
        }
    }
}
