# ZygorRetailSkin

Eigenständiges Skin für Retail. Laufzeitdateien in der TOC. Das installierte
`ZygorGuidesViewer` und die Buddy-Addons sind Referenzen für die Entwicklung.

- Mit Git-Status, TOC und relevantem Diff beginnen.
- Zygor-Optionen und Bedienlogik erhalten. Geschützte und verbotene Frames auslassen.
- Nach Änderungen `./tools/check-local.sh` oder den lokalen ZIP-Bau ausführen.
- Gemeinsame Regeln im übergeordneten `AGENTS.md` beachten. Nur auf Release-Auftrag veröffentlichen; dann den Ablauf in `README.md` lesen. Prüfungen nicht doppeln.
- `.pkgmeta` muss zur ZIP-Dateiliste passen; `RELEASE_NOTES.md` ist der CurseForge-Changelog.
- Nach jedem abgeschlossenen Testlauf die Antwort mit dem kopierbaren Fedora-Befehl abschließen. Für den Spieltest auch nach erfolgreicher Installation `cd /mnt/UserData/Dokumente/ChatGPT/wow_addon && ./tools/spieltest.sh ZygorRetailSkin` angeben. Bei geöffnetem WoW danach `/reload` im Chat ausführen.
