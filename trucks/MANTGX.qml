import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../"

Item {
    anchors.fill: parent
    opacity: connected && electricityOn ? 1 : 0.1

    TopIcons {
        connected: root.connected
        displayIcons: root.displayIcons
        leftBlinker: root.leftBlinker
        pressureWarning: root.pressureWarning
        gearbox: root.gearbox
        checkWarning: root.checkWarning
        rightBlinker: root.rightBlinker
        maximumIconWidth: root.maximumIconWidth
    }

    Image {
        source: "qrc:/images/dash_bcg.png"
        width: parent.width
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit

        RowLayout {
            anchors.top: parent.top
            anchors.topMargin: 10
            width: root.width

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.maximumWidth: 260

                // Temperature
                Text {
                    text: "25,0°C"
                    color: "#ffffff"
                    font.pointSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 80
                }

                Item {
                    Layout.fillWidth: true
                }

                // Game time
                Text {
                    text: time
                    color: "#ffffff"
                    font.pointSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 80
                }

                Item {
                    Layout.fillWidth: true
                }

                // Time remaining on the job
                RowLayout {
                    Layout.preferredWidth: 100
                    spacing: 10
                    opacity: deliveryTime != "0" ? 1 : 0

                    Image {
                        source: "qrc:/images/chrono.png"
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: deliveryTime
                        color: "#ffffff"
                        font.pointSize: 14
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // Feux de croisement
        Image {
            source: "qrc:/images/lowbeam.png"
            width: 25
            fillMode: Image.PreserveAspectFit
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
            x: 130
            visible: displayIcons || lowBeam
        }

        // Feux de route
        Image {
            source: "qrc:/images/highbeam.png"
            width: 25
            fillMode: Image.PreserveAspectFit
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            x: 200
            visible: displayIcons || highBeam
        }

        // Frein de parking
        Image {
            source: "qrc:/images/parking.png"
            width: 30
            fillMode: Image.PreserveAspectFit
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 260
            visible: displayIcons || parkingBrake
        }

        RowLayout {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            x: 260
            opacity: 0.8
            spacing: 15

            Image {
                source: "qrc:/images/wheel.png"
                Layout.maximumWidth: 20
                fillMode: Image.PreserveAspectFit
            }

            Text {
                color: "#ffffff"
                font.pixelSize: 18
                text: restTime
            }
        }

        // Odomètre
        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: -350
            horizontalAlignment: Text.AlignRight
            color: "#ffffff"
            font.pixelSize: 18
            opacity: 0.8
            text: odometer.toString() + " km"
            width: 200
        }

        // Carburant
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: -105
            width: fuelPercentage * 100
            height: 15
            color: "#ffffff"
            opacity: 0.6
        }

        // Ad blue
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: 35
            width: adbluePercentage * 100
            height: 15
            color: "#ffffff"
            opacity: 0.6
        }

        // Limitation de vitesse
        Rectangle {
            anchors.centerIn: parent
            color: "#ffffff"
            width: 60
            height: 60
            radius: width / 2
            border.color: "#ff0000"
            border.width: 6
            // visible: speedLimit > 0

            Text {
                text: speedLimit.toString()
                font.pixelSize: 30
                anchors.centerIn: parent
            }
        }

        CarGauge {
            id: speedometer
            objectName: "speedometer"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 7
            width: 365
            height: 365
            needleOffset: 0.5
            value: speed

            Text {
                text: "km/h"
                color: "#ffffff"
                opacity: 0.6
                x: (parent.width - width) / 2 + 20
                y: (parent.height - height) / 2 + 40
            }
        }

        CarGauge {
            id: tachometer
            objectName: "tachometer"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 7
            width: 365
            height: 365
            minimum: 0
            maximum: 30
            startAngle: 180
            spanAngle: -180
            needleOffset: -0.5
            value: rpm
            customDisplay: true
            displayValue: displayedGear

            // Indicateur de retarder
            Image {
                source: "qrc:/images/retarder.png"
                visible: displayIcons || retarder
                width: 25
                fillMode: Image.PreserveAspectFit
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2 + 40
            }

            // Indicateur de frein moteur
            Image {
                source: "qrc:/images/engine-brake.png"
                visible: displayIcons || engineBrake
                width: 25
                fillMode: Image.PreserveAspectFit
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2 + 65
            }
        }
    }
}
