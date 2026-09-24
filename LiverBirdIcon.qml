import QtQuick
import QtQuick.Shapes
import qs.Commons

// Liver bird silhouette drawn natively (like omarchy's DropboxIcon) so it
// tints with the theme and stays crisp in a tiny bar slot. Original drawing on
// a 24×24 grid; not the club crest.
Item {
  id: root

  property real iconSize: Style.font.icon
  property color color: Color.foreground
  property color badgeColor: Color.urgent
  property bool badge: false

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  Shape {
    width: 24
    height: 24
    scale: root.iconSize / 24
    transformOrigin: Item.TopLeft
    antialiasing: true
    layer.enabled: true
    layer.samples: 4

    ShapePath {
      fillColor: root.color
      strokeWidth: 0
      PathSvg {
        path: "M3.5 6.2 L6.5 5 C6.8 3.8 7.6 3.2 8.4 3.3 L8.8 1.8 L9.6 3.6 C10.4 4.4 10.4 5.8 10 7 C11 8.4 12 9 12.8 9.4 L14.2 3 L15.4 6.4 L17.6 2 L18.2 6.4 L20.6 3.4 L19.6 8.6 C19 11 17.6 12.4 16.6 13 L21 19.5 L17.6 18.6 L15.4 17.6 L14.2 18 L14.6 21.6 L15.6 22 L13 22 L13.4 18.2 L12 18 L11.4 21.6 L12.4 22 L9.8 22 L10.6 17.4 C8.6 16 8 13.6 8.6 11.4 C8.8 10 8.6 8.6 7.6 7.6 L6.6 7 Z M4.6 6.6 C3.6 8 5 9.2 3.8 10.8 C3.2 11.6 3.8 12.4 3.4 13 L4.2 13 C4.8 12 4.2 11.4 4.8 10.6 C6 9 4.6 7.8 5.4 6.9 Z"
      }
    }
  }

  // Unseen-headlines dot.
  Rectangle {
    visible: root.badge
    width: Math.max(4, root.iconSize * 0.34)
    height: width
    radius: width / 2
    color: root.badgeColor
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.rightMargin: -width * 0.3
    anchors.topMargin: -width * 0.3
  }
}
