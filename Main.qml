import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "./trucks"

Window {
    id: root
    width: 1024
    height: 600
    color: "#000000"
    title: "Car Gauge Qt6"
    flags: Qt.Window | Qt.WindowDoesNotAcceptFocus

    property bool connected: false
    property bool electricityOn: true
    property bool displayIcons: false
    property real speed: 0
    property real rpm: 0
    property string displayedGear: "N"
    property bool retarder: false
    property bool engineBrake: false
    property real speedLimit: 0
    property real fuelPercentage: 1.0
    property real adbluePercentage: 1.0

    property bool leftBlinker: false
    property bool pressureWarning: false
    property bool gearbox: false
    property bool checkWarning: false
    property bool rightBlinker: false
    property bool lowBeam: false
    property bool highBeam: false
    property bool parkingBrake: false
    property string time: "0:0"
    property string restTime: "0:0"
    property string deliveryTime: "0"
    property int odometer: 0

    property real maximumIconWidth: 50

    MANTGX {

    }

    Text {
        visible: !connected
        color: "#ffffff"
        text: "Not connected"
        anchors.centerIn: parent
    }
}
