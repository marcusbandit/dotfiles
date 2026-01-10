import QtQuick

// Individual workspace dot with states: active, occupied, empty
Item {
    id: root

    property int workspaceId: 0
    property bool isActive: false
    property bool isOccupied: false
    property bool isHovered: false

    // Theme colors
    property color colActive: "#7aa2f7"
    property color colOccupied: "#565f89"
    property color colEmpty: "#24283b"
    property color colHover: "#9aa5ce"

    // Sizing
    property real fullSize: 20

    // Base size depends on state
    property real baseSize: {
        if (isActive) return fullSize;
        if (isOccupied) return fullSize * 0.6;
        return fullSize * 0.35;
    }

    // Hover adds size boost for non-active dots
    property real hoverBoost: (!isActive && isHovered) ? fullSize * 0.15 : 0

    // Final animated size
    property real animatedSize: baseSize + hoverBoost

    // Color logic
    property color dotColor: {
        if (isActive) return colActive;
        if (isHovered) return colHover;
        if (isOccupied) return colOccupied;
        return colEmpty;
    }

    // Animated color for smooth transitions
    property color animatedColor: dotColor
    Behavior on animatedColor {
        ColorAnimation { duration: 150 }
    }

    signal clicked()

    width: fullSize + 4
    height: fullSize + 4

    // Single canvas that morphs between circle and blob
    Canvas {
        id: dotCanvas
        anchors.centerIn: parent
        width: root.fullSize + 4
        height: root.fullSize + 4

        // Wobble: 0 = perfect circle, 0.18 = cookie shape
        property real wobble: (root.isActive && root.isHovered) ? 0.18 : 0
        property real animatedWobble: 0

        // Rotation for the blob
        property real rotation: 0

        // Animated size
        property real drawSize: root.animatedSize

        Behavior on animatedWobble {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Behavior on drawSize {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        onWobbleChanged: animatedWobble = wobble

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var centerX = width / 2;
            var centerY = height / 2;
            var baseRadius = drawSize / 2;
            var sides = 9;

            ctx.beginPath();

            if (animatedWobble < 0.01) {
                // Draw a simple circle when wobble is negligible
                ctx.arc(centerX, centerY, baseRadius, 0, Math.PI * 2);
            } else {
                // Draw the cookie/blob shape
                var points = sides * 2;
                for (var i = 0; i <= points; i++) {
                    var angle = (i * Math.PI / sides) + (rotation * Math.PI / 180);
                    var radiusOffset = (i % 2 === 0) ? 1 : (1 - animatedWobble);
                    var radius = baseRadius * radiusOffset;

                    var x = centerX + Math.cos(angle) * radius;
                    var y = centerY + Math.sin(angle) * radius;

                    if (i === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }
            }

            ctx.closePath();
            ctx.fillStyle = root.animatedColor.toString();
            ctx.fill();
        }

        // Repaint when properties change
        onAnimatedWobbleChanged: requestPaint()
        onDrawSizeChanged: requestPaint()
        onRotationChanged: requestPaint()

        // Slow rotation animation (only when blob is showing)
        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 8000
            loops: Animation.Infinite
            running: dotCanvas.animatedWobble > 0.01
        }
    }

    // Also repaint when color changes
    onAnimatedColorChanged: dotCanvas.requestPaint()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.isHovered = containsMouse
        onClicked: root.clicked()
    }
}
