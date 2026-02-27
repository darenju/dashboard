import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    property int throttleInterval: 10    // ms : coalesce updates faster than this
    property real alpha: 0.12            // smoothing factor (0..1)
    property real minDelta: 0.5          // seuil update texte

    // timestamp pour throttling
    property real _lastAcceptTs: 0
    property int _nowMs: 0

    property var mappingTable: null

    anchors.fill: parent
    color: "#131313"
    // opacity: connected && electricityOn ? 1 : 0.1

    FontLoader { id: digital; source: "qrc:/fonts/digital-7.ttf" }

    Image {
        source: "qrc:/images/brands/" + root.truckBrand + ".png"
        x: parent.width / 2 - width / 2
        y: 20
        width: 150
        height: 150
        fillMode: Image.PreserveAspectFit
    }

    Image {
        source: "qrc:/images/generic/background-reversed.png"
        width: parent.width
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit

        Text {
            x: 600
            height: 35
            width: 75
            text: displayedGear
            color: "green"
            // font.family: digital.font.family
            font.pixelSize: 25
            font.weight: 600
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            x: 365
            width: 220
            height: 35
            text: cargo + " (" + cargoWeight.toString() + " t)"
            color: "orange"
            opacity: cargoWeight ? 1 : 0.3
            // font.family: digital.font.family
            font.pixelSize: 20
            font.weight: 500
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        GenericGauge {
            x: 34
            y: 74
            width: 296
            value: speed
            animate: mode == "debug"
            maximum: 130
            startAngle: -140
            spanAngle: 280
            mappingTable: [
                { v: 0,  a: -140 },
                { v: 20,  a: -105 },
                { v: 40, a: -70 },
                { v: 60, a: -25 },
                { v: 80, a: 24 },
                { v: 100, a: 69 },
                { v: 120, a: 115 },
                { v: 130, a: 140 },
            ]

            Rectangle {
                x: parent.width / 2 - 98
                y: parent.height / 2 - 106
                width: 194
                height: 195
                radius: 100
                color: Qt.rgba(0, 0, 0, 0.8)

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            color: "white"
                            text: speed
                            font.family: digital.font.family
                            font.pixelSize: 60
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 110
                        }

                        Text {
                            color: "white"
                            text: "km/h"
                            font.family: digital.font.family
                            font.pixelSize: 30
                            verticalAlignment: Text.AlignBottom
                            Layout.preferredHeight: parent.height
                            Layout.maximumWidth: 70
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            color: "white"
                            text: odometer
                            font.family: digital.font.family
                            font.pixelSize: 40
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 110
                        }

                        Text {
                            color: "white"
                            text: "km"
                            font.family: digital.font.family
                            font.pixelSize: 25
                            verticalAlignment: Text.AlignBottom
                            Layout.preferredHeight: parent.height
                            Layout.maximumWidth: 70
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            color: "white"
                            text: deliveryDistance
                            font.family: digital.font.family
                            font.pixelSize: 40
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 110
                        }

                        Text {
                            color: "white"
                            text: "km"
                            font.family: digital.font.family
                            font.pixelSize: 25
                            verticalAlignment: Text.AlignBottom
                            Layout.preferredHeight: parent.height
                            Layout.maximumWidth: 70
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }

        GenericGauge {
            x: 692
            y: 74
            width: 296
            animate: mode == "debug"
            value: rpm
            maximum: 28
            startAngle: -144
            spanAngle: 282

            Rectangle {
                x: parent.width / 2 - 93
                y: parent.height / 2 - 100
                width: 197
                height: 197
                radius: 100
                color: Qt.rgba(0, 0, 0, 0.8)

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillHeight: true
                    }

                    Text {
                        color: "white"
                        text: time
                        font.family: digital.font.family
                        font.pixelSize: 60
                        horizontalAlignment: Text.Center
                        Layout.fillWidth: true
                    }

                    Text {
                        color: "white"
                        text: deliveryTime
                        font.family: digital.font.family
                        font.pixelSize: 40
                        horizontalAlignment: Text.Center
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        Item {
                            Layout.fillWidth: true
                        }

                        Image {
                            source: "qrc:/images/generic/rest.png"
                            Layout.maximumWidth: 30
                            Layout.maximumHeight: 30
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            color: "white"
                            text: restTime
                            font.family: digital.font.family
                            font.pixelSize: 40
                            horizontalAlignment: Text.Center
                            Layout.preferredWidth: 100
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }

        GenericGauge {
            x: 367
            y: 252
            width: 100
            animate: mode == "debug"
            minimum: 30
            maximum: 150
            value: oilTemperature
            startAngle: -122
            spanAngle: 240
            type: "small"
        }

        GenericGauge {
            x: 534
            y: 254
            width: 100
            animate: mode == "debug"
            maximum: 100
            value: fuelPercentage * 100
            startAngle: -118
            spanAngle: 242
            type: "small"
        }

        Image {
            source: "qrc:/images/generic/lblinker.png"
            visible: leftBlinker
            width: 75
            height: 50
            x: 251
        }

        Image {
            source: "qrc:/images/generic/rblinker.png"
            visible: rightBlinker
            width: 75
            height: 50
            x: 700
        }

        Image {
            source: "qrc:/images/highbeam.png"
            visible: highBeam
            width: 40
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -180
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
        }

        Image {
            source: "qrc:/images/parking.png"
            visible: parkingBrake
            width: 40
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
        }

        Image {
            source: "qrc:/images/generic/retarder.png"
            visible: retarder
            width: 40
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 170
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
        }

        RowLayout {
            x: 384
            y: 42
            width: 258
            height: 119

            Item { Layout.fillWidth: true }

            RowLayout {
                Item { Layout.fillWidth: true }

                Rectangle {
                    color: "white"
                    radius: width / 2
                    border.color: "red"
                    border.width: 8
                    opacity: speedLimit ? 1 : 0.3
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80

                    Text {
                        x: parent.width / 2 - width / 2
                        y: parent.height /2 - height / 2
                        text: speedLimit || "-"
                        font.pixelSize: 35
                        font.weight: 600
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                spacing: 0
                opacity: cruiseControl ? 1 : 0.3
                Layout.fillWidth: true

                Image {
                    source: "qrc:/images/generic/cruise.png"
                    Layout.maximumWidth: 25
                    Layout.maximumHeight: 25
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    // font.family: digital.font.family
                    font.pixelSize: 50
                    font.weight: 600
                    text: cruiseControl ? cruiseControl : "-"
                    color: "white"
                }

                Item { Layout.fillWidth: true }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
