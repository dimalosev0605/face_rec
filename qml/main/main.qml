import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15


Window {
    id: main_qml
    visible: true
    width: 1400
    height: 800

    property alias main_qml_sc: main_qml_sc
    property var main_default_page_obj: null
    property var main_page_obj: null
    property var main_wait_page_obj: null

    Component.onCompleted: {
        var component = Qt.createComponent("qrc:/qml/main/Default_page.qml");
        main_default_page_obj = component.createObject(main_qml,
                                                  {
                                                      "x": Qt.binding(function(){return left_vertical_menu_bar.width}),
                                                      y: 0,
                                                      "width": Qt.binding(function(){ return main_qml.width - left_vertical_menu_bar.width}),
                                                      "height": Qt.binding(function(){ return main_qml.height})
                                                  });
        component = Qt.createComponent("qrc:/qml/common/Wait_page.qml")
        main_wait_page_obj = component.createObject(main_qml,
                                           {
                                               "x": Qt.binding(function(){return left_vertical_menu_bar.width}),
                                               y: 0,
                                               "width": Qt.binding(function(){ return main_qml.width - left_vertical_menu_bar.width}),
                                               "height": Qt.binding(function(){ return main_qml.height}),
                                               visible: false
                                           });
    }
    Shortcut {
        id: main_qml_sc
        sequence: "Esc"
        onActivated: {
            main_wait_page_obj.visible = true
            if(main_page_obj !== null) {
                main_page_obj.object.destroy()
                main_page_obj = null
            }
            main_wait_page_obj.visible = false
            main_default_page_obj.visible = true
        }
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
            model: Left_vertical_menu_bar_model { id: left_vertical_menu_bar_model }
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
                           m_area.containsMouse ? left_vertical_menu_bar.mouse_hovered_color :
                                                  left_vertical_menu_bar.default_color
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
                           m_area.containsMouse ? left_vertical_menu_bar.mouse_hovered_color :
                                                  left_vertical_menu_bar.default_color
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
                        if(model.loader_path === "Qt.quit()") {
                            Qt.quit()
                            return
                        }

                        if(main_page_obj !== null) {
                            if(main_page_obj.object.objectName.toString() === model.loader_path) return
                        }

                        main_default_page_obj.visible = false
                        main_wait_page_obj.visible = true
                        if(main_page_obj !== null) {
                            main_page_obj.object.visible = false
                            main_page_obj.object.destroy(1000)
                            main_page_obj = null
                        }

                        var component = Qt.createComponent(model.loader_path);
                        main_page_obj = component.incubateObject(main_qml,
                                                        {
                                                            "x": Qt.binding(function(){return left_vertical_menu_bar.width}),
                                                            y: 0,
                                                            "width": Qt.binding(function(){ return main_qml.width - left_vertical_menu_bar.width}),
                                                            "height": Qt.binding(function(){ return main_qml.height})
                                                        });
                        if(main_page_obj.status !== Component.Ready) {
                            main_page_obj.onStatusChanged = function(status) {
                                if(status === Component.Ready) {
                                    main_wait_page_obj.visible = false
                                    main_page_obj.visible = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
