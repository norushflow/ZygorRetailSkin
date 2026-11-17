# Zygor Retail Skin

Dark bronze skin for Zygor Guide Viewer on World of Warcraft Retail, matching the Forever skin. Requires the separately installed `ZygorGuidesViewer`. Independent of AzerothBuddy and AzerothBuddyUI.

## Installation

Extract `ZygorRetailSkin` into `_retail_/Interface/AddOns/`. Enable Zygor Retail Skin and Zygor Guide Viewer (Retail), then `/reload`. Disable the skin and reload to restore Zygor’s original appearance.

## Appearance

Styles the guide viewer, guide selection, tabs, menus, progress bars and supported option panels. Original navigation colours, protected buttons, settings and guide behaviour remain intact. Uses a locally installed AzerothBuddy/AzerothBuddyUI Expressway font when available, otherwise the client font. No fonts, Zygor code or guides are bundled.

## Development

Checked against the installed Retail Zygor 9.6, interface 120105. Run `./tools/check-local.sh` for Lua checks and lifecycle tests using the installed Zygor styles; `./tools/build.sh` builds a checked ZIP. Both accept a custom WoW path (build: `--wow-dir`).

From the parent workspace run `./tools/spieltest.sh ZygorRetailSkin`, then `/reload` in Retail. The initial Retail client test was confirmed on 2026-11-17. Publish only on explicit request.

## Release

Run `./tools/build.sh` once for changed code; reuse a checked ZIP of the same source. Commit and push to `main`, tag the matching TOC version, then create a GitHub release with the ZIP and `RELEASE_NOTES.md`. Verify the tag commit and attached ZIP. CurseForge and Wago require separate Retail projects before enabling uploads; never reuse the Forever project IDs.

Downloads: https://github.com/norushflow/ZygorRetailSkin/releases

Independent, unofficial project; not affiliated with or endorsed by Zygor Guides.
