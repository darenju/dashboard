import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: width
    height: width

    // Config
    property real minimum: 0
    property real maximum: 120
    property real startAngle: 0
    property real spanAngle: 180
    property real needleOffset: 0
    property real needleOffsetY: 0
    property real needleRatio: 0.5
    property real needleHeight: width / 2 - 10
    property string needleColor: "yellow"
    property string needleBorder: ""

    // Valeur externe que l'on veut afficher (source)
    property real value: 0               // --> Ne pas binder d'opérations lourdes sur onValueChanged
    // Internal cible coalescée
    property real targetValue: value

    // affichage lissé (utilisé pour le rendu)
    property bool hideText: false
    property real displayedValue: value
    property real needleAngle: startAngle

    // réglages
    property int throttleInterval: 10    // ms : coalesce updates faster than this
    property real alpha: 0.12            // smoothing factor (0..1)
    property real minDelta: 0.5          // seuil update texte

    // timestamp pour throttling
    property real _lastAcceptTs: 0
    property int _nowMs: 0

    property var mappingTable: null

    function valueToAngle(v) {
        var clamped = Math.max(minimum, Math.min(maximum, v));

        if (!mappingTable) {
            var ratio = (clamped - minimum) / (maximum - minimum);
            return startAngle + ratio * spanAngle;
        } else {
            var t = mappingTable;

            // clamp
            if (v <= t[0].v) return t[0].a;
            if (v >= t[t.length-1].v) return t[t.length-1].a;

            // cherche le segment contenant v
            for (var i = 0; i < t.length - 1; i++) {
                var a = t[i];
                var b = t[i+1];
                if (v >= a.v && v <= b.v) {
                    // interpolation linéaire sur le segment
                    var ratio = (v - a.v) / (b.v - a.v);
                    return a.a + ratio * (b.a - a.a);
                }
            }
        }
    }

    // COALESCE / THROTTLE: ne pas appliquer chaque update immédiatement
    onValueChanged: {
        // timestamp en ms
        _nowMs = Date.now();
        // toujours stocker la dernière valeur reçue dans targetValue
        root.targetValue = value;

        // si trop récent, on coalesce : on n'applique pas de calcul coûteux maintenant
        if (_nowMs - root._lastAcceptTs < root.throttleInterval) {
            // on garde targetValue et on laisse le frameTimer l'appliquer
            return;
        }
        // sinon on "accepte" immédiatement (mise à jour du timestamp)
        root._lastAcceptTs = _nowMs;
    }

    // Timer de frame fixe (60Hz) : applique smoothing vers targetValue
    Timer {
        id: frameTimer
        interval: 16
        repeat: true
        running: true
        onTriggered: {
            // Simple exponential smoothing
            displayedValue += (root.targetValue - displayedValue) * root.alpha;

            // update angle directement sans Behavior (évite relances)
            root.needleAngle = root.valueToAngle(displayedValue);

            // mettre à jour l'affichage numérique si changement visible
            if (!gauge.customDisplay) {
                if (Math.abs(Number(gauge.displayValue) - displayedValue) >= root.minDelta) {
                    gauge.displayValue = Math.round(displayedValue).toString();
                }
            }
        }
    }

    // Grosse partie visuelle isolée
    Rectangle {
        id: gauge
        anchors.fill: parent
        radius: 12
        color: "transparent"

        property string displayValue: root.customDisplay ? root.displayValue : Math.round(root.displayedValue).toString()

        // Needle
        Rectangle {
            id: needleLayer
            width: 6
            height: root.needleHeight
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: root.needleOffset
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: root.needleOffsetY

            layer.enabled: true
            layer.smooth: true

            transform: Rotation {
                id: rot
                origin.x: needleLayer.width / 2
                origin.y: needleLayer.height
                angle: root.needleAngle
            }

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.height * root.needleRatio
                radius: 3
                color: root.needleColor
                border.color: root.needleBorder
                border.width: root.needleBorder ? 2 : 0
            }
        }

        // Texte
        Text {
            id: txt
            text: gauge.displayValue
            anchors.centerIn: parent
            font.pixelSize: root.width * 0.12
            color: "white"
            opacity: 0.95
            visible: !root.hideText
        }
    }

    // Timer {
    //     id: speedSim
    //     interval: 80
    //     repeat: true
    //     running: true
    //     property real simulatedSpeed: 0
    //     property real acceleration: 0

    //     onTriggered: {
    //         // variation douce
    //         acceleration += (Math.random() - 0.5) * 0.6;
    //         if (acceleration > 2) acceleration = 2;
    //         if (acceleration < -2) acceleration = -2;

    //         simulatedSpeed += acceleration * 0.6;
    //         if (simulatedSpeed < root.minimum) simulatedSpeed = root.minimum;
    //         if (simulatedSpeed > root.maximum) simulatedSpeed = root.maximum;

    //         // Écris TOUJOURS dans root.value (source) — sera coalescée par onValueChanged
    //         root.value = simulatedSpeed;
    //     }
    // }

    // // UI pour régler paramètres en runtime (utile pour debug)
    // Column {
    //     spacing: 6
    //     anchors {
    //         right: parent.right; rightMargin: 12
    //         top: parent.top; topMargin: 12
    //     }
    //     Rectangle { width: 200; height: 2; color: "transparent" } // spacer

    //     Text { text: "throttle(ms): " + root.throttleInterval; color: "white" }
    //     Slider {
    //         from: 0; to: 100; stepSize: 1
    //         value: root.throttleInterval
    //         onMoved: root.throttleInterval = value
    //     }

    //     Text { text: "alpha: " + Number(root.alpha).toFixed(3); color: "white" }
    //     Slider {
    //         from: 0.02; to: 0.6; stepSize: 0.01
    //         value: root.alpha
    //         onMoved: root.alpha = value
    //     }

    //     Row {
    //         spacing: 6
    //         Button { text: speedSim.running ? "Stop sim" : "Start sim"; onClicked: speedSim.running = !speedSim.running }
    //         Button {
    //             text: "Reset"
    //             onClicked: {
    //                 speedSim.simulatedSpeed = 0;
    //                 speedSim.acceleration = 0;
    //                 root.value = 0;
    //                 root.targetValue = 0;
    //                 root.displayedValue = 0;
    //                 gauge.displayValue = "0";
    //             }
    //         }
    //     }
    // }
}
