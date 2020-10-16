import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../common"

Rectangle {
    id: root

    property string avatar_src
    property string nickname
    property bool type
    property alias m_area: button_m_area

    height: 60
    radius: 2

    color: m_area.containsMouse ? "#d4d4d4" : "transparent"

    Image {
        id: avatar
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        property int space_between_top_and_bottom_of_delegate: 10
        height: root.height - space_between_top_and_bottom_of_delegate
        width: height
        asynchronous: true
        mipmap: true
        fillMode: Image.PreserveAspectCrop
        source: root.avatar_src
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: avatar.width
                height: avatar.height
                radius: 5
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var comp = Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
                var win = comp.createObject(null, { img_source: avatar.source, window_type: false })
                win.show()
            }
        }
    }
    Text {
        id: nickname
        anchors {
            left: avatar.right
        }
        width: root.width - avatar.width - avatar.anchors.leftMargin - button.width - button.anchors.rightMargin
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 12
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: root.nickname
    }
    MouseArea {
        id: m_area
        anchors {
            left: avatar.right
            right: button.left
        }
        height: root.height
        hoverEnabled: true
    }
    Rectangle {
        id: button
        anchors {
            right: root.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: root.height * 0.5
        width: height
        color: button_m_area.containsMouse ? button_m_area.pressed ? type ? "#00ff00" : "#ff0000" : "#cfcfcf" : "transparent"
        radius: width / 2
        Image {
            anchors.fill: parent
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: type ? "qrc:/qml/icons/add.png" : "qrc:/qml/icons/remove.png"
        }
        MouseArea {
            id: button_m_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
