# ec_outfitbag — Konfiguration

Release-Server nutzen **`shared/config.lua`** aus dem Release-Build (`dist/` → `live/`).

Wichtige Optionen:

| Option | Werte | Beschreibung |
| --- | --- | --- |
| `Config.Framework` | `ESX`, `QBCore`, `QBox` | Framework-Bridge |
| `Config.Inventory` | `ESX`, `OX` | Inventar-Bridge |
| `Config.Target` | `ESX`, `OX` | Target-Bridge |
| `Config.Language` | `DE`, `EN`, … | Sprache in `locales/` |
| `Config.RequiredItem` | Tabelle | Item `outfitbag`, `ConsumeOnPlace` |
| `Config.DefaultSlots` | number | Standard-Slots |
| `Config.Hologram` | Tabelle | 3D-Vorschau neben der Tasche |
| `Config.Progress` | Tabelle | ox_lib Progress-Bars |
| `Config.Animations` | Tabelle | Anziehen / Ablegen / Strip |

Vollständige Doku: **`README.md`** im Repo.
