import QtQuick 2.15
import QtQuick.Layouts

RowLayout {
    anchors.top: parent.top
    height: 70
    width: parent.width
    spacing: 15
    visible: connected || displayIcons

    property bool connected: false
    property bool displayIcons: false
    property bool leftBlinker: false
    property bool pressureWarning: false
    property bool gearbox: false
    property bool checkWarning: false
    property bool rightBlinker: false
    property real maximumIconWidth: 50

    Item {
        Layout.fillWidth: true
    }

    Image {
        id: left
        source: "qrc:/images/left.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: leftBlinker || displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/engine.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/oil.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/pressure.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons || pressureWarning ? 1 : 0
    }

    Rectangle {
        Layout.minimumWidth: maximumIconWidth
        Layout.maximumWidth: maximumIconWidth
        color: "transparent"
    }

    Image {
        source: "qrc:/images/temperature.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/key.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/info.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/battery.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Rectangle {
        Layout.minimumWidth: maximumIconWidth
        Layout.maximumWidth: maximumIconWidth
        color: "transparent"
    }

    Image {
        source: "qrc:/images/gearbox.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons || gearbox ? 1 : 0
    }

    Image {
        source: "qrc:/images/airbag.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons ? 1 : 0
    }

    Image {
        source: "qrc:/images/check.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons || checkWarning ? 1 : 0
    }

    Image {
        source: "qrc:/images/right.png"
        Layout.maximumWidth: maximumIconWidth
        fillMode: Image.PreserveAspectFit
        opacity: displayIcons || rightBlinker ? 1 : 0
    }

    Item {
        Layout.fillWidth: true
    }
}
