# Omarchy Liverpool News

A liver bird in the [Omarchy](https://omarchy.org/) bar. Click it for the latest
Liverpool FC headlines from reputable outlets; click a headline to open it in
your browser.

> **Status: early development.** Built against omarchy-shell (Quickshell) on
> the `quattro` branch.

## Sources

| Outlet | Feed |
|---|---|
| Sky Sports | `https://www.skysports.com/rss/11669` |
| BBC Sport | `https://feeds.bbci.co.uk/sport/football/teams/liverpool/rss.xml` |
| The Guardian | `https://www.theguardian.com/football/liverpool/rss` |
| Liverpool Echo | `https://www.liverpoolecho.co.uk/all-about/liverpool-fc?service=rss` |

Headlines are merged, de-duplicated and sorted newest first (top 30). A dot on
the icon means new headlines since you last opened the panel.

X (journalists like James Pearce) is planned, see [`docs/NOTES.md`](docs/NOTES.md).

## Controls

| Input | Action |
|---|---|
| Left click | Open / close the headlines panel |
| Middle click | Refresh now |
| Escape | Close the panel |

The refresh interval (default 15 minutes, minimum 5) is a widget setting.

## Requirements

- Omarchy with `omarchy-shell` (Quickshell)
- `curl`

## Installation

Not yet published. For development:

```bash
git clone https://github.com/redglover/omarchy-liverpool-plugin.git \
  ~/.config/omarchy/plugins/io.github.redglover.liverpool-news
```

Plugin code under `~/.config/omarchy/plugins/` hot-reloads on save. If a change
does not apply, force it with `omarchy-shell shell rescanPlugins`.

## Development

The feed parsing lives in `Model.js`, which runs under node as well as QML:

```bash
node --test test/model.test.js
```

## Notes

The icon is an original liver bird silhouette, not the Liverpool FC crest,
which is a registered trademark. This plugin is not affiliated with Liverpool
Football Club.

## License

MIT — see [LICENSE](LICENSE).
