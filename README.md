<h1 align="center">EC Outfit Bag</h1>

<p align="center">
  <strong>Taktische Outfit-Tasche für FiveM</strong> — Outfits speichern, 3D-Vorschau, ESX / QBCore / QBox.
</p>

<p align="center">
  <a href="https://github.com/EuroCent82/ec_outfitbag/releases"><img src="https://img.shields.io/badge/Version-0.0.1-2d6a4f?style=for-the-badge" alt="Version 0.0.1" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="MIT License" /></a>
</p>

---

Taktische **Outfit-Tasche** für FiveM — speichert Outfits pro Charakter, kann auf dem Boden platziert werden und unterstützt **ESX**, **QBCore** und **QBox**.

## Features

- NUI im geöffneten Taschen-Innenfach (PNG-Overlay)
- Outfits speichern, anziehen, bearbeiten, löschen
- Tasche auf dem Boden platzieren (Prop + Target)
- 3D-Hologramm-Vorschau neben der Tasche (ein/ausschaltbar)
- Strip-then-dress mit Kategorie-Animationen und ox_lib Progress
- Mehrsprachig: **DE** / **EN**
- Framework-Bridges für Inventar, Target, Appearance, MySQL

## Download

**[Releases](https://github.com/EuroCent82/ec_outfitbag/releases/latest)** — Asset `ec_outfitbag.zip`

## Installation

1. Resource in `[scripts]` legen
2. SQL: optional manuell `sql/install.sql` — Tabellen werden beim Start automatisch angelegt (`Config.Database.autoInstall = true`)
3. `ensure ec_outfitbag` in `server.cfg`
4. Item registrieren (`data/ox_inventory_item.lua` — **`consume = 0`** in ox_inventory!)
5. `shared/config.lua` anpassen

## Konfiguration

Siehe **`readme_config.md`** und **`shared/config.lua`**.

## Commands

Siehe **[commands.md](./commands.md)**.

## Lizenz

MIT — siehe [LICENSE](./LICENSE).
