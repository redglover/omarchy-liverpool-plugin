# Development notes

## Feeds (checked 2026-09-24)

All four feeds in `Model.js` returned HTTP 200. Quirks:

- **Sky Sports** stamps `pubDate` with `BST`. Neither V8 nor QML's V4
  `Date.parse` understands that zone, so `Model.parseDate` parses RFC 822 by
  hand with a small zone table. Sky's CDATA also contains numeric entities
  (`Mbapp&#233;`), so entities are decoded after CDATA is unwrapped.
- **BBC Sport** only carries a few BBC Sounds clips, and every one is titled
  just "Liverpool FC". The description is the real headline there.
- **liverpoolfc.com** has no working RSS (`/rss/news` returns 404).
- **The Athletic** (James Pearce) is paywalled and has no public Liverpool feed.

## X / Twitter (not yet implemented)

### Cost

There is no free way to read X. As of September 2026 the official API is
pay-per-use only: **$0.005 per post read**, capped at 3M reads a month. The
legacy Basic and Pro tiers were migrated to this model in June and September
2026. Nitter-style scrapers and RSS bridges break too often to depend on.

Planned approach: put the accounts below in one X List, and poll the list
timeline with `since_id` so each post is billed only once. At roughly 10–30
posts a day per account, that is about $10–40 a month. The bearer token would
be a widget setting. If it is unset, the plugin should say so and fall back to
RSS only.

### Accounts

Handles are unverified. Confirm each with the API's user lookup before relying
on them.

Reputable Liverpool journalists:

| Name | Outlet | Handle |
|---|---|---|
| James Pearce | The Athletic | `@JamesPearceLFC` |
| Paul Joyce | The Times | `@_pauljoyce` |
| Neil Jones | Independent / Substack | `@neiljonesftbl` |
| Ian Doyle | Liverpool Echo | `@IanDoyleSport` |
| Chris Bascombe | Telegraph | `@Chris_Bascombe` |
| Dominic King | Daily Mail | `@DominicKing_DM` |
| Melissa Reddy | Sky | `@MelissaReddy_` |

Wider transfer news (not Liverpool-only):

| Name | Handle |
|---|---|
| David Ornstein | `@David_Ornstein` |
| Fabrizio Romano | `@FabrizioRomano` |

Official and large fan accounts:

| Account | Handle |
|---|---|
| Liverpool FC (official) | `@LFC` |
| Anfield Watch | `@AnfieldWatch` |
| The Anfield Talk | `@TheAnfieldTalk` |

Fan accounts mostly repost the journalists above. They are big but noisy, so
they should be opt-in.

## Icon

`LiverBirdIcon.qml` draws the bird natively with `Shape` + `PathSvg`, the same
approach as omarchy's `DropboxIcon`, so it tints with the theme and avoids Qt
SVG quirks in small bar slots. The path is an original drawing on a 24×24 grid.
The Wikimedia Commons "Liver bird.svg" was rejected: it is CC BY-SA 4.0
(incompatible with an MIT-only repo) and too detailed at 13px.
