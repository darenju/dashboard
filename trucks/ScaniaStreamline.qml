import QtQuick 2.15
import "./components"

Item {
    anchors.fill: parent
    id: root

    FontLoader { id: digital; source: "qrc:/fonts/digital-7.ttf" }

    property string needleColor: "white"
    property string needleBorder: lowBeam ? "red" : "gray"
    property string yellow: "#fec844"

    Image {
        source: "qrc:/images/scania.streamline/dashboard.png"
        width: parent.width
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit
    }

    GenericGauge {
        x: 55
        y: 113
        width: 288
        value: rpm
        animate: mode == "debug"
        maximum: 27
        startAngle: -118
        spanAngle: 235
    }
}
