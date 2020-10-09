import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

Rectangle {
    id: processed_imgs_delegate
    height: 60
    radius: 2

    property color hovered_color: "#d4d4d4"
    property color default_color: "#ffffff"
    property color highlighted_color: "#999999"

    color: processed_imgs_delegate_m_area.containsMouse ? processed_imgs_delegate_m_area.pressed ? highlighted_color : hovered_color : default_color

    property alias source_img_src: src_img.source
    property alias extracted_face_img_src: extracted_face_img.source
    property alias extracted_face_img_file_name: extracted_face_img_file_name.text

    property alias delete_from_processed_imgs_btn_m_area: delete_from_processed_imgs_btn_m_area

    Image {
        id: src_img
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
        cache: false
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: src_img.width
                height: src_img.height
                radius: 5
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var comp = Qt.createComponent("qrc:/qml/Full_screen_img.qml")
                var win = comp.createObject(root, { img_source: src_img.source, window_type: false })
                win.show()
            }
        }
    }
    Rectangle {
        id: delete_from_processed_imgs_btn
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: parent.height * 0.5
        width: height * 0.85
        radius: 4
        property color delete_btn_pressed_color: "#9c0303"
        color: delete_from_processed_imgs_btn_m_area.containsPress ?
               delete_btn_pressed_color : delete_from_processed_imgs_btn_m_area.containsMouse ?
                                          "gray" : processed_imgs_delegate.color
        Image {
            id: delete_from_processed_imgs_btn_img
            anchors.fill: parent
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/qml/icons/trash.png"
        }
        MouseArea {
            id: delete_from_processed_imgs_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
    Image {
        id: extracted_face_img
        anchors {
            right: delete_from_processed_imgs_btn.left
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: src_img.height
        width: height
        asynchronous: true
        mipmap: true
        cache: false
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: extracted_face_img.width
                height: extracted_face_img.height
                radius: 5
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var comp = Qt.createComponent("qrc:/qml/Full_screen_img.qml")
                var win = comp.createObject(root, { img_source: extracted_face_img.source, window_type: false })
                win.show()
            }
        }
    }
    Text {
        id: extracted_face_img_file_name
        anchors {
            left: src_img.right
            right: extracted_face_img.left
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        height: parent.height
        width: parent.width - src_img.width - src_img.anchors.leftMargin -
               delete_from_processed_imgs_btn.width - delete_from_processed_imgs_btn.anchors.rightMargin -
               extracted_face_img.width - extracted_face_img.anchors.rightMargin
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }
    MouseArea {
        id: processed_imgs_delegate_m_area
        anchors {
            left: src_img.right
            right: extracted_face_img.left
        }
        height: parent.height
        hoverEnabled: true
    }
}
