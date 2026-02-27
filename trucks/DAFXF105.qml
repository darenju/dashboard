import QtQuick 2.15
import QtQuick.Layouts 2.15
import "../"

Item {
    anchors.fill: parent
    id: root

    FontLoader { id: digital; source: "qrc:/fonts/digital-7.ttf" }

    property string needleColor: "white"
    property string needleBorder: lowBeam ? "red" : "gray"
    property string yellow: "#fec844"

    Image {
        source: lowBeam ? "qrc:/images/daf-xf105/dashboard-on.jpg" : "qrc:/images/daf-xf105/dashboard-off.jpg"
        width: parent.width
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit
    }

    CarGauge {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 365
        startAngle: -180
        spanAngle: 270
        maximum: 125
        value: speed
        hideText: true
        needleOffsetY: -10
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 150
    }

    // RPM
    CarGauge {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 365
        startAngle: -90
        spanAngle: 270
        maximum: 25
        value: rpm
        hideText: true
        needleOffset: 4
        needleOffsetY: -10
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 150

        mappingTable: [
            { v: 0,  a: -90 },
            { v: 5,  a: -75 },
            { v: 10, a: -23 },
            { v: 15, a: 34 },
            { v: 20, a: 110 },
            { v: 25, a: 180 }
        ]
    }

    // Fuel
    CarGauge {
        anchors.top: parent.top
        anchors.topMargin: 121
        anchors.left: parent.left
        anchors.leftMargin: 222
        width: 154
        startAngle: -40
        spanAngle: 80
        maximum: 100
        value: fuelPercentage * 100
        hideText: true
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 70
    }

    // Oil
    CarGauge {
        anchors.top: parent.top
        anchors.topMargin: 121
        anchors.right: parent.right
        anchors.rightMargin: 222
        width: 154
        startAngle: -30
        spanAngle: 60
        maximum: 100
        value: 50
        hideText: true
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 70
        needleOffset: 4
    }

    // AdBlue
    CarGauge {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -25
        anchors.left: parent.left
        anchors.leftMargin: 365
        width: 140
        startAngle: -40
        spanAngle: 80
        maximum: 100
        value: adbluePercentage * 100
        hideText: true
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 70
    }

    // Pressure
    CarGauge {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -25
        anchors.right: parent.right
        anchors.rightMargin: 360
        width: 140
        startAngle: -40
        spanAngle: 80
        maximum: 100
        value: 50
        hideText: true
        needleColor: root.needleColor
        needleBorder: root.needleBorder
        needleRatio: 1
        needleHeight: 70
    }

    // Odometer
    RowLayout {
        x: 215
        y: 470
        width: 110
        height: 25
        spacing: 2
        visible: electricityOn

        Item {
            Layout.fillWidth: true
        }

        Text {
            font.family: digital.font.family
            font.pixelSize: 28
            color: yellow
            text: odometer.toString()
        }

        Text {
            font.family: digital.font.family
            font.pixelSize: 18
            color: yellow
            text: "km"
        }
    }

    // Remaning distance
    RowLayout {
        x: 215
        y: 493
        width: 97
        height: 25
        spacing: 2
        visible: electricityOn

        Item {
            Layout.fillWidth: true
        }

        Text {
            font.family: digital.font.family
            font.pixelSize: 28
            color: yellow
            text: deliveryDistance.toString()
        }

        Text {
            font.family: digital.font.family
            font.pixelSize: 18
            color: yellow
            text: "km"
        }
    }

    // Game time
    Text {
        x: 710
        y: 470
        width: 110
        height: 25
        visible: electricityOn

        font.family: digital.font.family
        font.pixelSize: 28
        color: yellow
        text: time
        horizontalAlignment: Text.AlignHCenter
    }

    // Temperature
    Text {
        x: 710
        y: 487
        width: 97
        height: 25
        visible: electricityOn

        font.family: digital.font.family
        font.pixelSize: 28
        color: yellow
        text: "25,0°C"
        horizontalAlignment: Text.AlignHCenter
    }

    // Feux de croisement
    Image {
        source: "qrc:/images/daf-xf105/lowbeam.png"
        width: 30
        fillMode: Image.PreserveAspectFit
        x: 130
        y: 460
        visible: displayIcons || lowBeam
    }

    // Retarder
    Image {
        source: "qrc:/images/daf-xf105/retarder.png"
        width: 30
        fillMode: Image.PreserveAspectFit
        x: 828
        y: 460
        visible: displayIcons || retarder
    }

    ColumnLayout {
        x: 397
        y: 125
        width: 235
        height: 180
        spacing: 5
        visible: electricityOn

        RowLayout {
            id: topRow
            width: parent.width
            spacing: 0

            Text {
                font.family: digital.font.family
                font.pixelSize: 30
                color: yellow
                text: speedLimit.toString()
                opacity: speedLimit > 0 ? 1 : 0
                Layout.fillWidth: true
                Layout.preferredWidth: topRow.width / topRow.children.length
            }

            Text {
                font.family: digital.font.family
                font.pixelSize: 35
                color: yellow
                text: displayedGear
                Layout.fillWidth: true
                Layout.preferredWidth: topRow.width / topRow.children.length
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                opacity: cruiseControl > 0 ? 1 : 0
                spacing: 5
                Layout.fillWidth: true
                Layout.preferredWidth: topRow.width / topRow.children.length

                Rectangle {
                    color: "red"
                    Layout.preferredWidth: 20
                    Layout.fillWidth: true
                }

                Image {
                    source: "qrc:/images/daf-xf105/cruise.png"
                    Layout.maximumHeight: 20
                    Layout.maximumWidth: 30
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    font.family: digital.font.family
                    font.pixelSize: 30
                    color: yellow
                    text: cruiseControl.toString()
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Rectangle {
            color: yellow
            height: 2
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 5

            // Current info
            Image {
                source: "qrc:/images/daf-xf105/info.png"
                Layout.maximumHeight: 20
                Layout.maximumWidth: 30
                fillMode: Image.PreserveAspectFit
            }

            Text {
                font.family: digital.font.family
                font.pixelSize: 25
                color: yellow
                text: "Current info"
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Text {
                font.family: digital.font.family
                font.pixelSize: 25
                color: yellow
                text: "Speed"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                font.family: digital.font.family
                font.pixelSize: 25
                color: yellow
                text: speed.toString() + " km/h"
            }
        }

        RowLayout {
            Text {
                font.family: digital.font.family
                font.pixelSize: 28
                color: yellow
                text: "Arrival"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                font.family: digital.font.family
                font.pixelSize: 28
                color: yellow
                text: deliveryTime
            }
        }

        RowLayout {
            Text {
                font.family: digital.font.family
                font.pixelSize: 28
                color: yellow
                text: "Break"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                font.family: digital.font.family
                font.pixelSize: 28
                color: yellow
                text: restTime
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Image {
        source: "qrc:/images/daf-xf105/needles-covers.png"
        width: parent.width
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit
    }
}
