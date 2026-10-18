---
name: paper-maquette
description: Distilled visual language of the anatomy skill — the paper-and-ink isometric look — as a fast checklist for drawing new figures or restyling diagrams to match. Use when someone asks for "a figure in that exact style", a new blog/README figure matching an existing anatomy figure, an isometric boxes-and-arrows schematic, or to review a diagram against the anatomy house rules. For the full heavy machinery (lathe, physics audit, poses), open the anatomy skill itself.
---

# Paper maquette — the visual language in one page

This is the distillation, not a reimplementation. The machinery lives in the
anatomy skill (deep craft: [read its references/skill files when going beyond
this checklist](/Users/oresttokovenko/.agents/skills/anatomy/SKILL.md)) and in a
copyable kit. A worked island lives in the blog repo:
`src/components/figures/polaris-flow/` (react-flow restyle of the same
schematic), with the kit copy in `src/components/iso/`.

`anatomy-style` answers one question: *how should it LOOK*, and *how do I
know it still does when I'm done*.

## When to use what

| The ask | Do |
|---|---|
| New static diagram (boxes/cylinders/arrows) | kit + build.mjs pattern, static SVG artifact |
| Verb/Big complex scene, one mechanism, in-world scale | full anatomy skill |
| Make an existing svg/mermaid diagram match the anatomy look instead | reading this page + kit, rebuild as SVG (converter) |
| Quick visuals inside a React app | kit + react components (anatomy/react) |

## The grammar (non-negotiable)

1. **Flat color, shaded by one fixed light.** Every solid gets exactly four
   tone bands + a hairline outline. No gradients, no shadows on faces (a
   single soft `halo` under a slab is the one allowed shadow).
2. **Ink before chrome.** Weight is in the *drawing*: `.6px` hairlines
   (non-scaling), faint interior "crease" lines, and tone contrast carry
   everything. Zero decorative CSS: no dashed borders, no emoji, no rounded
   cards next to the art.
3. **One lit accent per figure** — the mechanism's key actor (the vended
   credential, the waybill). Everything else stays ink-tones; never light
   two things.
4. **Engraved labels only.** Small caps, mono, name-case letterspaced from
   the face they're engraved on, tone `mid`/`lo`. No floating text in the
   void: every word sits on a face, a standing sign band, or a painted floor
   label under its run.
5. **Point arrows are real solids.** A tube run (radius 1–1.2) with a flange
   disc at the source and a cone head at the target; the tube's tip lands
   exactly *on* the target face, the cone bridges the final units.
6. **Grounded.** Things sit on a rounded ground slab (corner bolts, hairline
   inset groove) or mount on each other. The audit's `support`, `terminals`,
   `loose` checkers enforce this for objects; schematic-only exceptions
   (painted floor labels, pure ink) are fine but must be documented.
7. **One frame chemistry.** `Fig N` top-left, tracked-caps title top-right,
   hint line + live readout if animated, `keys` swatch legend, plain-prose
   caption. The card is the page. The art is 55–65% of the card width.
8. **Camera.** Azimuth 42–45°, elevation 30°, `fitProjection` with ~28–40px
   pad. Rotate nothing per-object; motion is translation/rotation of *groups*
   recorded by the audit, never ad-hoc transforms.

## Palette

The kit's CSS variables are the palette — don't invent colors. Both themes:

| var | dark | light | use |
|---|---|---|---|
| `--anatomy-face/top` | `#1b1b1b`/`#1c1c1c` | `#ffffff` | solid faces |
| `--anatomy-shade-0..3` | `#0f0f0f → #181818` | `#dcdcd9 → #f4f4f1` | the four bands |
| `--anatomy-hi` | `#d4d4d4` | `#26262a` | emphasis line |
| `--anatomy-mid` | `#6a6a6a` | `#8a8a8f` | labels, structure |
| `--anatomy-lo` | `#3e3e3e` | `#b4b4b8` | default line |
| `--anatomy-faint` | `#2a2a2a` | `#d4d4d6` | creases, noise |
| `--anatomy-paper` | `#131313` | `#fbfbfa` | silhouette fill |
| `--anatomy-halo` | `#050505` | `#8a8a80` | soft drop |
| `--anatomy-lit` | `#ffffff` | `#000000` | the one accent's ink |

Site-specific accent (e.g. the blog's link blue `rgb(22,31,116)`) may stand
in for `--anatomy-lit` **only once per figure**. Hand-drawn SVG that must sit
on the blog should bake the light theme (and set `data-theme="light"` on the
standalone `figureSvg`).

## The audit mindset

The look survives because every build clears a physics + painter audit and a
line-end audit on immutable geometry — not because the author is careful.

- `recorder(P)` → `put` every item with real bounding shapes (`A.slab`,
  `A.cylinder`, body lathes) → `A.settle` → `A.audit(...)`.
- Hard-fail classes: clearance, depth order, self-overlap, wobble, seating,
  crowding, screen folds, line-ends (`lines.mjs`).
- Schematic-only figures may soften `terminals`/`support`/missing-shape
  classes to documented residuals in `concept.md` — count them, never hide
  them: the build must print `0 hard`.
- `moving` groups must have their pose swept (`sweep passed`).

## Build loop (static figure, the 80% case)

```bash
cd src/components/figures/<slug>
node build.mjs --light --audit        # audit + html + public svg artifact
node ~/.agents/skills/anatomy/scripts/lines.mjs polaris-arch.html     # line ends: 0 float
node ~/.agents/skills/anatomy/scripts/capture.mjs polaris-arch.html --out shots/fig.png --width 1280
```

Then **drive it** at the site's real column width too (drive.mjs with a
width ~830–900) and at 390 for phones, and read the captures like a hostile
reviewer: label legibility, label-vs-node collisions, floating dead space,
washed tone. Fix, re-capture, repeat until the capture reads clean at the
smallest support size — reviews happen at reading size, not at 1180px.

- Kit: `src/components/iso/` in the blog (`iso-kit`, `lathe`, `tube`,
  `audit`); copy from `~/.agents/skills/anatomy/kit` elsewhere.
- Inlining the kit for a live page: `build-kit.mjs` must strip `import`/
  `export` lines **and rename the clashing private helpers** (`runsOf`,
  `signedArea`, `oriented`, `cut`) — both kit modules define namesakes in one
  script scope. The blog's `src/components/figures/polaris-post/build-kit.mjs`
  is the working reference.

## Autorreview checklist (run before shipping)

- [ ] Audit exits 0 hard (residuals documented & counted, not suppressed)
- [ ] `lines.mjs`: 0 floating ends (or each documented)
- [ ] One accent; labels ≤ ~2 voices; every label on a surface
- [ ] 4 tone bands everywhere; no CSS decoration in the art
- [ ] Scene ≥ 55% card fill at the smallest embed width; title/caption prose
- [ ] Captures: 1280 px, column width, 390 px — all readable (text is the
      first thing to die: render text ≥ ~11px effective at the column)
- [ ] `astro build` (or repo-equivalent) green; artifact + embed updated
