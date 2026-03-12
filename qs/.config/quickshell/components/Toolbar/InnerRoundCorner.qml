import QtQuick

// Inverted/concave corner component
// Creates a quarter-circle cutout effect for seamless transitions
// cornerType: 1=topLeft, 2=topRight, 3=bottomLeft, 4=bottomRight
Item {
    id: root

    required property int cornerType  // 1, 2, 3, or 4
    required property int radius      // Size of the corner
    required property color color     // Background color (the visible part)

    width: radius
    height: radius

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            var r = root.radius;

            ctx.reset();
            ctx.fillStyle = root.color;
            ctx.beginPath();

            // Draw filled area with quarter-circle cutout
            // The arc creates the concave curve, filling the corner region
            switch(root.cornerType) {
                case 1: // topLeft - circle centered at bottom-right
                    ctx.moveTo(0, 0);
                    ctx.lineTo(r, 0);
                    ctx.arc(r, r, r, -Math.PI / 2, Math.PI, true);
                    ctx.closePath();
                    break;
                case 2: // topRight - circle centered at bottom-left
                    ctx.moveTo(0, 0);
                    ctx.lineTo(r, 0);
                    ctx.lineTo(r, r);
                    ctx.arc(0, r, r, 0, -Math.PI / 2, true);
                    ctx.closePath();
                    break;
                case 3: // bottomLeft - circle centered at top-right
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, r);
                    ctx.lineTo(r, r);
                    ctx.arc(r, 0, r, Math.PI / 2, Math.PI, false);
                    ctx.closePath();
                    break;
                case 4: // bottomRight - circle centered at top-left
                    ctx.moveTo(r, 0);
                    ctx.lineTo(r, r);
                    ctx.lineTo(0, r);
                    ctx.arc(0, 0, r, Math.PI / 2, 0, true);
                    ctx.closePath();
                    break;
            }

            ctx.fill();
        }

        // Repaint when properties change
        Connections {
            target: root
            function onCornerTypeChanged() { canvas.requestPaint(); }
            function onRadiusChanged() { canvas.requestPaint(); }
            function onColorChanged() { canvas.requestPaint(); }
        }
    }
}
