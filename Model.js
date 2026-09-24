// Pure helpers for the Liverpool news panel. No QML imports, so the same file
// runs under node for tests (see test/model.test.js).

var FEEDS = [
  { source: "Sky Sports", url: "https://www.skysports.com/rss/11669" },
  { source: "BBC Sport", url: "https://feeds.bbci.co.uk/sport/football/teams/liverpool/rss.xml" },
  { source: "Guardian", url: "https://www.theguardian.com/football/liverpool/rss" },
  { source: "Echo", url: "https://www.liverpoolecho.co.uk/all-about/liverpool-fc?service=rss" }
]

var MAX_ITEMS = 30

var MONTHS = { jan: 0, feb: 1, mar: 2, apr: 3, may: 4, jun: 5, jul: 6, aug: 7, sep: 8, oct: 9, nov: 10, dec: 11 }
// Offsets in minutes. Sky Sports stamps "BST", which neither V8 nor QML's V4
// Date.parse understands, so RFC 822 dates are parsed by hand.
var ZONES = { gmt: 0, ut: 0, utc: 0, z: 0, bst: 60, cet: 60, cest: 120 }

var NAMED_ENTITIES = { amp: "&", lt: "<", gt: ">", quot: "\"", apos: "'", nbsp: " " }

function decodeEntities(s) {
  return s.replace(/&(#x[0-9a-f]+|#[0-9]+|[a-z]+);/gi, function(m, e) {
    if (e[0] === "#") {
      var code = e[1] === "x" || e[1] === "X" ? parseInt(e.slice(2), 16) : parseInt(e.slice(1), 10)
      return isNaN(code) ? m : String.fromCodePoint(code)
    }
    var named = NAMED_ENTITIES[e.toLowerCase()]
    return named === undefined ? m : named
  })
}

// Text of the first <tag>…</tag> in xml, CDATA unwrapped, entities decoded,
// any markup stripped, whitespace collapsed.
function tagText(xml, tag) {
  var m = new RegExp("<" + tag + "(?:\\s[^>]*)?>([\\s\\S]*?)</" + tag + ">", "i").exec(xml)
  if (!m) return ""
  var raw = m[1].replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
  return decodeEntities(raw).replace(/<[^>]*>/g, "").replace(/\s+/g, " ").trim()
}

// RFC 822 ("Thu, 24 Sep 2026 08:47:00 BST" / "+0000") → epoch ms, or 0.
function parseDate(s) {
  var m = /(\d{1,2})\s+([a-z]{3})[a-z]*\s+(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|[a-z]+)?/i.exec(s || "")
  if (!m) return 0
  var month = MONTHS[m[2].toLowerCase()]
  if (month === undefined) return 0
  var offset = 0
  var zone = m[7] || "GMT"
  if (/^[+-]\d{4}$/.test(zone)) {
    offset = (parseInt(zone.slice(1, 3), 10) * 60 + parseInt(zone.slice(3), 10)) * (zone[0] === "-" ? -1 : 1)
  } else if (ZONES[zone.toLowerCase()] !== undefined) {
    offset = ZONES[zone.toLowerCase()]
  }
  return Date.UTC(+m[3], month, +m[1], +m[4], +m[5], +(m[6] || 0)) - offset * 60000
}

function parseRss(xml, source) {
  var items = []
  var re = /<item[\s>][\s\S]*?<\/item>/gi
  var block
  while ((block = re.exec(String(xml || ""))) !== null) {
    var title = tagText(block[0], "title")
    var description = tagText(block[0], "description")
    // BBC's Liverpool feed titles every Sounds clip just "Liverpool FC"; the
    // description is the actual headline there.
    if (description && (!title || title.toLowerCase() === "liverpool fc")) title = description
    var link = tagText(block[0], "link")
    if (!title || !/^https?:\/\//.test(link)) continue
    items.push({ title: title, link: link, source: source, time: parseDate(tagText(block[0], "pubDate")) })
  }
  return items
}

// Newest first, one entry per link, capped.
function merge(lists) {
  var seen = {}
  var all = []
  for (var i = 0; i < lists.length; i++) {
    for (var j = 0; j < lists[i].length; j++) {
      var item = lists[i][j]
      if (seen[item.link]) continue
      seen[item.link] = true
      all.push(item)
    }
  }
  all.sort(function(a, b) { return b.time - a.time })
  return all.slice(0, MAX_ITEMS)
}

function relativeAge(time, now) {
  if (!time) return ""
  var mins = Math.max(0, Math.floor((now - time) / 60000))
  if (mins < 60) return mins + "m"
  if (mins < 60 * 24) return Math.floor(mins / 60) + "h"
  return Math.floor(mins / (60 * 24)) + "d"
}

if (typeof module !== "undefined") {
  module.exports = {
    FEEDS: FEEDS,
    MAX_ITEMS: MAX_ITEMS,
    decodeEntities: decodeEntities,
    parseDate: parseDate,
    parseRss: parseRss,
    merge: merge,
    relativeAge: relativeAge
  }
}
