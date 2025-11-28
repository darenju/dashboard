import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Item {
    id: root
    width: 360
    height: 360

    property real minimum: 0
    property real maximum: 120
    property real value: 0
    property real startAngle: -180
    property real spanAngle: 180
    property real needleOffset: 0
    property bool customDisplay: false
    property string displayValue: Math.round(root.value).toString()

    // valeur lissée utilisée pour le rendu (mise à jour par le timer)
    property real displayedValue: value
    property real needleAngle: valueToAngle(displayedValue)

    function valueToAngle(v) {
        var clamped = Math.max(minimum, Math.min(maximum, v));
        var ratio = (clamped - minimum) / (maximum - minimum);
        return startAngle + ratio * spanAngle;
    }

    // Timer de frame-rate fixe (≈60Hz)
    Timer {
        id: frameTimer
        interval: 16           // ~60 FPS (16 ms)
        repeat: true
        running: true
        onTriggered: {
            // alpha contrôle la réactivité : 0.2 = très réactif, 0.08 = plus amorti
            var alpha = 0.12;
            // Move displayedValue toward value smoothly
            displayedValue += (root.value - displayedValue) * alpha;
            // calcule l'angle directement (évite relancer des Behaviors)
            root.needleAngle = root.valueToAngle(displayedValue);

            if (!customDisplay) {
                // mise à jour moins fréquente côté texte (arrondie)
                displayValue = Math.round(displayedValue).toString();
            }
        }
    }

    // Optimisation GPU : mettre la 'needle' en layer pour un rendu plus fluide
    Rectangle {
        id: needle
        width: 6
        height: parent.height / 2 - 11
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter

        layer.enabled: true
        layer.smooth: true
        layer.format: Qt.rgba8

        transform: Rotation {
            id: needleRot
            origin.x: needle.width / 2 + needleOffset
            origin.y: needle.height
            angle: root.needleAngle
        }

        Rectangle {
            width: parent.width
            color: "#ff3b30"
            radius: 3
            height: parent.height * 0.5    // proportionnel, évite relayout fréquents
            anchors.top: parent.top
        }
    }

    // Valeur numérique
    Text {
        text: displayValue
        font.pixelSize: root.width * 0.12
        color: "white"
        anchors.centerIn: parent
        opacity: 0.9
    }
}
