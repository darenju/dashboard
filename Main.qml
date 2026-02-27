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

    property string truck
    property string mode
    property bool connected: false
    property bool electricityOn: false
    property bool displayIcons: false
    property int speed: 0
    property int cruiseControl: 0
    property int rpm: 0
    property string displayedGear: "N"
    property bool retarder: false
    property bool engineBrake: false
    property int speedLimit: 0
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
    property int deliveryDistance: 0
    property string cargo: "No cargo"
    property int cargoWeight: 0
    property real oilTemperature: 30
    property string truckBrand: "unknown"

    property int maximumIconWidth: 50

    MANTGX {
        visible: truck == "MAN-TGX"
    }

    DAFXF105 {
        visible: truck == "DAF-XF105"
    }

    Generic {
        visible: truck == "generic"
    }

    Text {
        visible: !connected
        color: "#ffffff"
        text: "Not connected"
        anchors.centerIn: parent
    }
}
