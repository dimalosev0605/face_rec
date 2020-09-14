import QtQuick.Window 2.12
import QtQuick 2.12

Window {
    visible: true
    height: Screen.desktopAvailableHeight
    width: Screen.desktopAvailableWidth
    property alias img_source: img.source
    Image {
        id: img
        anchors.fill: parent
        asynchronous: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }
}
