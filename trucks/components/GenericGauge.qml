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
    property bool animate: false

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
    property string type: "big"

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
        }
    }

    Image {
        id: needleLayout
        source: root.type == "big" ? "qrc:/images/generic/needle-big.png" : "qrc:/images/generic/needle-small.png"
        x: root.type == "big" ? 119 : 50

        layer.enabled: true
        layer.smooth: true

        transform: Rotation {
            origin.x: root.type == "big" ? 28 : 11
            origin.y: root.type == "big" ? 145 : 52
            angle: root.needleAngle
        }
    }

    Timer {
        id: speedSim
        interval: 80
        repeat: true
        running: root.animate
        property real simulatedSpeed: 0
        property real acceleration: 0

        onTriggered: {
            // variation douce
            acceleration += (Math.random() - 0.5) * 0.6;
            if (acceleration > 2) acceleration = 2;
            if (acceleration < -2) acceleration = -2;

            simulatedSpeed += acceleration * 0.6;
            if (simulatedSpeed < root.minimum) simulatedSpeed = root.minimum;
            if (simulatedSpeed > root.maximum) simulatedSpeed = root.maximum;

            // Écris TOUJOURS dans root.value (source) — sera coalescée par onValueChanged
            root.value = simulatedSpeed;
        }
    }
}
