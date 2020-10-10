import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../common"

Rectangle {
    id: delegate

    property alias avatar_path: individual_avatar.source
    property alias individual_name: individual_name.text
    property alias delete_individual_btn_m_area: delete_individual_btn_m_area
    property alias individual_avatar_m_area: individual_avatar_m_area

    height: 60
    radius: 2

    property color hovered_color: "#d4d4d4"
    property color default_color: "#ffffff"
    property color highlighted_color: "#999999"

    color: individual_avatar_m_area.containsMouse ?
           individual_avatar_m_area.pressed ?
           highlighted_color : hovered_color : default_color

    Image {
        id: individual_avatar
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
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: individual_avatar.width
                height: individual_avatar.height
                radius: 5
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                people_list_view.currentIndex = index
                var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
                var win = comp.createObject(people_page_item, { img_source: individual_avatar.source, window_type: false })
                win.show()
            }
        }
    }
    Text {
        id: individual_name
        anchors {
            left: individual_avatar.right
        }
        width: delegate.width - individual_avatar.width - individual_avatar.anchors.leftMargin - delete_individual_btn.width - delete_individual_btn.anchors.rightMargin
        height: delegate.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }
    MouseArea {
        id: individual_avatar_m_area
        anchors {
            right: delete_individual_btn.left
            left: individual_avatar.right
        }
        height: parent.height
        hoverEnabled: true
    }
    Rectangle {
        id: delete_individual_btn
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: parent.height * 0.35
        width: height
        color: delete_individual_btn_m_area.containsMouse ? delete_individual_btn_m_area.pressed ? "#ff0000" : "#00ff00" : parent.color
        Image {
            anchors.fill: parent
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/qml/icons/cross.png"
        }
        MouseArea {
            id: delete_individual_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
