import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15

import Left_vertical_menu_bar_model_qml 1.0

Window {
    visible: true
    width: 640
    height: 480

    Left_vertical_menu_bar_model {
        id: left_vertical_menu_bar_model
    }

    Rectangle {
        id: left_vertical_menu_bar
        property color default_color: "#756c62"
        property color mouse_hovered_color: "#959595"
        property color highlighted_color: "#3c3c3c"
        anchors {
            left: parent.left
        }
        height: parent.height
        width: 70
        color: default_color

        ListView {
            id: left_vertical_menu_list_view
            anchors.fill: parent
            model: left_vertical_menu_bar_model
            delegate: menu_delegate
            interactive: false
            currentIndex: -1
        }

        Component {
            id: menu_delegate
            Item {
                id: menu_delegate_body
                width: left_vertical_menu_bar.width
                height: width * 0.8
                Rectangle {
                    id: left_solid_line
                    property color highlighted_color: "#dcdcdc"

                    height: menu_delegate_body.height
                    width: 2.5
                    color: menu_delegate_body.ListView.isCurrentItem ?
                               left_solid_line.highlighted_color :
                               m_area.containsMouse ? left_vertical_menu_bar.mouse_hovered_color : left_vertical_menu_bar.default_color
                }
                Rectangle {
                    id: body_rect
                    anchors {
                        left: left_solid_line.right
                        right: menu_delegate_body.right
                    }
                    height: menu_delegate_body.height
                    color: menu_delegate_body.ListView.isCurrentItem ?
                               left_vertical_menu_bar.highlighted_color :
                               m_area.containsMouse ? left_vertical_menu_bar.mouse_hovered_color : left_vertical_menu_bar.default_color
                    Image {
                        id: icon
                        anchors {
                            top: parent.top
                            topMargin: 5
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width * 0.4
                        height: width
                        source: String(model.menu_option_icon_path)
                        antialiasing: true
                        mipmap: true
                    }
                    Text {
                        id: text
                        anchors {
                            top: icon.bottom
                            topMargin: 2
                            horizontalCenter: parent.horizontalCenter
                        }
                        height: parent.height - icon.height - icon.anchors.topMargin - anchors.topMargin
                        width: parent.width
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        minimumPointSize: 1
                        font.pointSize: 10
                        text: String(model.menu_option_text)
                    }
                }
                MouseArea {
                    id: m_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        left_vertical_menu_list_view.currentIndex = index
                    }
                }
            }
        }
    }
}
