import QtQuick
import qs.Commons
import qs.Ui

// Shape follows omarchy's first-party weather widget: the bar button lives
// here, the popup in Panel.qml, loaded eagerly so headlines fetch in the
// background and the unseen dot works before the panel is ever opened.
BarWidget {
  id: root
  moduleName: "io.github.redglover.liverpool-news"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item) panelLoader.item.refresh()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root).
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  // Lets this widget stand in for the panel as the bar's popout identity.
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    tooltipText: ""
    iconComponent: Component {
      Item {
        LiverBirdIcon {
          anchors.centerIn: parent
          iconSize: Style.space(13)
          color: root.bar ? root.bar.foreground : Color.foreground
          badge: panelLoader.item ? panelLoader.item.hasUnseen : false
        }
      }
    }

    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }
}
