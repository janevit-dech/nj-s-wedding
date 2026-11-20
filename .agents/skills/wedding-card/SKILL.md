---
name: wedding-card
description: Collaborate on edits to the Naneen & JameJame wedding e-card (this repo) — change copy/text, dates, venue, RSVP link, program times, dress code, colors, palette/theme, fonts, decorations, photos, spacing, or mobile/desktop layout. Use whenever the user asks to edit, restyle, retheme, recolor, translate, or fill in placeholders on the card.
---

# Wedding e-card — collaborative editing

Static one-page invitation. **No build step, no dependencies, no framework.**
Runtime files are exactly two: `index.html` + `styles.css`. Everything else is reference.

## Ground rules

1. **Never invent wedding facts.** Dates, venue name, address, times, parking, RSVP URL, nicknames
   stay as `[...]` placeholders until the user gives the real value. Ask, don't guess.
2. **Never add tooling.** No npm, bundler, Tailwind, React, CSS preprocessor, or extra stylesheet.
   Mirror the existing plain-CSS + inline-SVG style.
3. **`base/` is a read-only mockup** exported from a design tool. Never edit it, never link to it,
   never copy its generated class names into `index.html`.
4. **Thai is the primary language** (`<html lang="th">`). Thai copy must stay Thai; English lines are
   secondary accents (`.en`, `.kicker`, `.sub`, `.label`). Keep both when a block has both.
5. **Every visual change is dual-viewport.** One breakpoint only: `@media (min-width: 900px)`.
   Mobile rules are the default (top of `styles.css`); desktop overrides live inside the 900px blocks.
   A change that only touches the mobile rule is an unfinished change — check the desktop block too.
6. Reply to the user in the language they used.

## Working protocol

- One change set at a time; restate what will change before editing if the request is vague
  ("make it warmer", "ใส่สีใหม่") and offer 2–3 concrete options.
- Edit in place with `edit`. Don't rewrite whole files for a local change.
- After editing, **verify in a browser at both widths** (see Verify). Describe what you saw.
- If the user supplies real data (date, venue, link), replace the placeholder *and* every related
  spot in the map below — e.g. a venue name appears in 3 places (name, 2 Maps links).

## File map

| File | Role |
| --- | --- |
| `index.html` | All content + all inline SVG `<symbol>`/`<pattern>` artwork in `<defs>` at the top |
| `styles.css` | `:root` tokens, mobile layout, `@media (min-width:900px)` desktop, decoration placement |
| `base/mobile`, `base/desktop` | Design-tool mockups — reference only |
| `README.md` | Thai docs; update it when structure, placeholders, or tokens change |

Sections in `index.html`, in order, each preceded by a `<!-- ============ name ============ -->`
banner comment (locate with `grep -n '<!-- =' index.html`):

| Section | Element | Key classes |
| --- | --- | --- |
| hero | `<header class="band band-white hero">` | `.kicker` `.names` `.hero-lines` `.hero-arch` |
| love + RSVP | `<section class="band band-sky love">` | `.love-copy` `.ticket` `.rsvp-block` `.btn-rose` |
| venue | `<section class="band band-white venue">` | `.venue-name` `.venue-addr` `.parking` `.btn-golden` |
| program + details | `<div class="band band-pd">` | `.program-card` `.program-row` `.details-card` `.dresscode` `.swatches` |
| footer | `<footer class="band band-sky footer">` | `.footer-head` `.photo-frame` `.logo` `.footer-names` |

## Content edits — request → target

| User asks | Edit |
| --- | --- |
| Couple names (big script) | `.names .name-a` / `.name-b` in hero; also `<title>`, `og:title`, `meta description` |
| Nicknames at the bottom | `.footer-names` → `[A] &amp; [B]` |
| Wedding date | `.ticket .date` (`[DD] . [MM] . [YY]`) **and** `.ticket .full-date` (Thai long form) |
| RSVP deadline | `.rsvp-block p` → `รบกวนตอบรับภายในวันที่ [DD เดือน YYYY]` |
| RSVP button link | `a.btn.btn-rose href="#"` → Google Form / LINE URL (keep `target="_blank" rel="noopener"`) |
| Venue name / address | `.venue-name`, `.venue-addr` |
| Parking info | `.parking .text` |
| Google Maps | **two** links: `a.venue-photo-link` and `a.btn.btn-golden`; replace `query=VENUE+NAME+Bangkok` in both |
| Program times / items | `.program-row` → `.time` + `.what` (+ `.en` accent). Adding a row: copy a whole `.program-row` and pick a heart class (`heart-rose`, `heart-mustard`, `heart-coral`, `heart-golden`) |
| Dress code wording | `.dresscode .text` |
| Dress-code swatches | `.swatches > span` — inline `style="background:#XXXXXX"` + `aria-label` (keep them in sync with the palette) |
| Closing message | `.footer-head` (EN, uses `<br>`) and `.footer-thai` |
| Invitation line | `.hero-lines .invite` (desktop-visible) |

Placeholders still open are every `[...]` literal in `index.html`; list them with
`grep -n '\[[^]]*\]' index.html` before claiming the card is ready to send.

## Color / theme edits

**Colors live in three places. Changing one alone causes drift.**

1. `styles.css :root` — the 10 tokens, used by every CSS rule:

   `--ink #2F4E73` (text/outline) · `--rose #D27681` · `--brick #C05157` · `--mustard #E6B558` ·
   `--golden #DE8948` · `--coral #E07970` · `--palm #BAAB46` (leaves) · `--sand #FBD48F` ·
   `--sky #9CC8EC` (band bg) · `--mist #E3F0FA` (band bg) ·
   plus `--card-shadow` / `--btn-shadow` (rgba of `--ink` / `--brick` — restate them if those change).

2. `index.html` inline SVG — hex literals SVG attributes can't read from CSS vars:
   - garland bulb `<pattern id="garlandPattern">`: 8 colored bulbs alternating with white (16-bulb cycle)
   - `<symbol id="bouquet">`: `stroke="#DE8948"`, flower fills brick/mustard/rose
   - `<symbol id="couple">`: `stroke="#2F4E73"`, dress `#9CC8EC`, hair `#2F4E73`, bouquet dots
   - `<meta name="theme-color" content="#9CC8EC">` (browser chrome — match the hero/first band)

3. `.swatches` inline `style="background:#..."` in the dress-code block.

**Palette change procedure**

1. Edit the tokens in `:root`.
2. Run `bash .agents/skills/wedding-card/scripts/palette-check.sh` — it prints any hex in
   `index.html` that is no longer a token (= drift) and where it is.
3. Update each reported line: garland bulbs, symbol fills/strokes, swatches, `theme-color`.
4. Re-run until only `#FFFFFF` (intentional white) remains unmatched.

**Band / wave invariant.** Each section paints a torn-paper edge whose fill must equal the
**previous** band's background, or a seam appears:

- `.band-white` → `#FFFFFF`, `.band-sky` → `var(--sky)`, `.band-mist` / `.band-pd` → `var(--mist)`
- the wave element carries `wave-white` / `wave-sky` / `wave-mist` (`.wave .fill`), and `.wave .shadow`
  is `var(--ink)` at 12% opacity
- `.footer > .wave .fill` is overridden per-viewport (`#FFFFFF` mobile, `var(--mist)` desktop) because
  the preceding band differs — if you reorder or recolor bands, fix this override too.

Decoration colors (`.deco`, `.dot`, `.leaf`, `.cloud`) are set per-class in the
"decoration placement" blocks near the bottom of `styles.css`, separately for mobile and desktop.

## Typography

Fonts load from Google Fonts in `<head>`: **Mali** (Thai + Latin body) and **Pacifico** (`.script`
headings). Swapping a font means editing the `<link href="...css2?family=...">` *and* the
`font-family` stacks (`body`, `.script`). Any replacement must ship Thai glyphs, or Thai text falls
back and the layout shifts.

## Photos

`.arch` boxes (`hero-arch`, `venue-arch`, `.photo-frame .inner .arch`) currently hold placeholder SVG
or `.photo-note` text. To use a real photo, drop files in `images/` and replace the box contents:

```html
<div class="arch hero-arch">
  <img src="./images/couple.jpg" alt="Naneen และ JameJame"
       style="width:100%;height:100%;object-fit:cover">
</div>
```

`.arch` already sets `overflow:hidden`, so the arch/rounded crop applies automatically. Keep a
meaningful `alt`. Remove the `outline` only if the user asks for a borderless look.

## Layout / spacing edits

- Mobile first: top-of-file rules target ≤899px (`.wrap` max-width 430px).
- Desktop: inside `@media (min-width: 900px)` (`.wrap` max-width 1200px); this is where the
  flex columns become rows (`.hero-grid`, `.love-grid`, `.venue-row`, `.pd-grid`, `.footer-grid`).
- Visibility helpers: `.only-m` (hidden ≥900px) and `.only-d` (hidden <900px) — used for the
  mist wave and some decorations. Don't duplicate markup where one of these does the job.
- Extra narrow-phone tweaks exist at `max-width: 420px` and `max-width: 360px`.

## Verify (required after any visual change)

```bash
python3 -m http.server 4321    # must be http://, not file://
```

Then open the page and check **both** `390px` (mobile) and `1280px` (desktop) widths — confirm:
no seam between bands, no overlapping decoration, Thai text not clipped, buttons still tappable.
Report what you observed. For color work, also re-run `palette-check.sh` and confirm it is clean.

## Finishing

- If placeholders, tokens, or section structure changed, update `README.md` (it is Thai and
  documents the placeholder checklist, palette, and breakpoint).
- Deploy is Vercel static — no framework preset, no build command, no output dir. Push to `main`
  deploys production; `vercel` / `vercel --prod` from CLI also works.
