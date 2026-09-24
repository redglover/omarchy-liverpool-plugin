const test = require("node:test")
const assert = require("node:assert")
const fs = require("node:fs")
const path = require("node:path")
const Model = require("../Model.js")

const fixture = name => fs.readFileSync(path.join(__dirname, "fixtures", name + ".xml"), "utf8")

test("parses every fixture feed into titled, linked, dated items", () => {
  for (const [name, source] of [["sky", "Sky Sports"], ["bbc", "BBC Sport"], ["guardian", "Guardian"], ["echo", "Echo"]]) {
    const items = Model.parseRss(fixture(name), source)
    assert.ok(items.length > 0, name + " has items")
    for (const item of items) {
      assert.ok(item.title && !/<|&[a-z#0-9]+;/i.test(item.title), name + " title clean: " + item.title)
      assert.match(item.link, /^https?:\/\//)
      assert.ok(item.time > Date.UTC(2020, 0, 1), name + " dated: " + item.title)
      assert.strictEqual(item.source, source)
    }
  }
})

test("CDATA, entities and BBC's generic titles", () => {
  const xml = `<rss><item><title><![CDATA[Mbapp&#233; &amp; Klopp]]></title><link>https://a</link><pubDate>Thu, 24 Sep 2026 08:47:00 BST</pubDate></item>
    <item><title>Liverpool FC</title><description><![CDATA[Wirtz form]]></description><link>https://b</link></item>
    <item><title>No link</title></item></rss>`
  const items = Model.parseRss(xml, "X")
  assert.deepStrictEqual(items.map(i => i.title), ["Mbappé & Klopp", "Wirtz form"])
})

test("RFC 822 dates with named and numeric zones", () => {
  assert.strictEqual(Model.parseDate("Thu, 24 Sep 2026 08:47:00 BST"), Date.UTC(2026, 8, 24, 7, 47))
  assert.strictEqual(Model.parseDate("Thu, 24 Sep 2026 11:48:57 +0000"), Date.UTC(2026, 8, 24, 11, 48, 57))
  assert.strictEqual(Model.parseDate("Wed, 23 Sep 2026 17:36:00 GMT"), Date.UTC(2026, 8, 23, 17, 36))
  assert.strictEqual(Model.parseDate("Wed, 23 Sep 2026 13:00:00 -0500"), Date.UTC(2026, 8, 23, 18, 0))
  assert.strictEqual(Model.parseDate("garbage"), 0)
})

test("merge dedupes by link, sorts newest first, caps", () => {
  const a = [{ link: "1", time: 1 }, { link: "2", time: 3 }]
  const b = [{ link: "2", time: 3 }, { link: "3", time: 2 }]
  assert.deepStrictEqual(Model.merge([a, b]).map(i => i.link), ["2", "3", "1"])
  const many = Array.from({ length: 50 }, (_, i) => ({ link: String(i), time: i }))
  assert.strictEqual(Model.merge([many]).length, Model.MAX_ITEMS)
})

test("relative age", () => {
  const now = Date.UTC(2026, 8, 24, 12)
  assert.strictEqual(Model.relativeAge(now - 5 * 60000, now), "5m")
  assert.strictEqual(Model.relativeAge(now - 3 * 3600000, now), "3h")
  assert.strictEqual(Model.relativeAge(now - 50 * 3600000, now), "2d")
  assert.strictEqual(Model.relativeAge(0, now), "")
})
