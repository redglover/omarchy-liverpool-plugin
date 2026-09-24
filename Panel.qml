import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "io.github.redglover.liverpool-news"
  ipcTarget: "io.github.redglover.liverpool-news"

  property var anchorItem: null

  // The bar tracks BarWidget.qml, not this nested panel, so popout
  // coordination has to identify as that widget (see omarchy.weather).
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  // Latest good parse per feed, keyed by source, so one flaky outlet keeps
  // its previous headlines instead of vanishing.
  property var feedItems: ({})
  property var items: []
  property int feedIndex: -1
  property real now: Date.now()

  // Newest headline time the user has seen. Starts at whatever the first
  // fetch returns, so the dot means "new since the shell started".
  property real seenTime: 0
  readonly property bool hasUnseen: items.length > 0 && items[0].time > seenTime

  readonly property int refreshMinutes: Math.max(5, parseInt(setting("refreshMinutes", 15), 10) || 15)

  function open() {
    root.controller.show()
    now = Date.now()
    markSeen()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function markSeen() {
    if (items.length > 0) seenTime = Math.max(seenTime, items[0].time)
  }

  function refresh() {
    if (feedIndex !== -1) return
    fetchFeed(0)
  }

  // Feeds are fetched one after another through a single Process.
  function fetchFeed(index) {
    if (index >= Model.FEEDS.length) {
      feedIndex = -1
      var lists = []
      for (var i = 0; i < Model.FEEDS.length; i++) lists.push(feedItems[Model.FEEDS[i].source] || [])
      items = Model.merge(lists)
      now = Date.now()
      if (seenTime === 0 || root.opened) markSeen()
      return
    }
    feedIndex = index
    feedProc.command = ["curl", "-fsSL", "--max-time", "10", Model.FEEDS[index].url]
    feedProc.running = true
  }

  function openLink(link) {
    Qt.openUrlExternally(link)
    root.close()
  }

  Process {
    id: feedProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var feed = Model.FEEDS[root.feedIndex]
        var parsed = Model.parseRss(text, feed.source)
        if (parsed.length > 0) {
          var next = Object.assign({}, root.feedItems)
          next[feed.source] = parsed
          root.feedItems = next
        }
        Qt.callLater(root.fetchFeed, root.feedIndex + 1)
      }
    }
  }

  Timer {
    interval: root.refreshMinutes * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(460))
    contentHeight: panel.fittedContentHeight(newsColumn.implicitHeight, Style.space(520))
    focusTarget: keyCatcher

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: newsScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: newsColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: newsColumn
          width: newsScroll.width
          spacing: Style.space(2)

          Text {
            text: "LIVERPOOL NEWS"
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.letterSpacing: 1
            leftPadding: Style.space(10)
            bottomPadding: Style.space(6)
          }

          Text {
            visible: root.items.length === 0
            text: root.feedIndex === -1 ? "No headlines — middle-click the icon to retry." : "Fetching headlines…"
            color: Qt.darker(root.bar.foreground, 1.5)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.italic: true
            leftPadding: Style.space(10)
          }

          Repeater {
            model: root.items

            Rectangle {
              required property var modelData
              width: newsColumn.width
              height: headline.implicitHeight + Style.space(12)
              radius: Style.cornerRadius
              color: rowArea.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

              Column {
                id: headline
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  textFormat: Text.PlainText
                  text: modelData.title
                  wrapMode: Text.Wrap
                  maximumLineCount: 2
                  elide: Text.ElideRight
                  color: rowArea.containsMouse ? Style.hoverStateColor(root.bar.foreground, Color.accent) : root.bar.foreground
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.body
                }
                Text {
                  textFormat: Text.PlainText
                  text: modelData.source + (modelData.time ? " · " + Model.relativeAge(modelData.time, root.now) : "")
                  color: Qt.darker(root.bar.foreground, 1.5)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                }
              }

              MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openLink(modelData.link)
              }
            }
          }
        }
      }
    }
  }
}
