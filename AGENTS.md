# AGENTS.md

## Repository Overview

Fork of **Hardened** (a submod for the Battle Brothers overhaul mod **Reforged**). This codespace is currently a plain clone of upstream Hardened. End goal: **remove Reforged perk/mechanic overhauls, retain & curate QoL improvements.**

- Working branch: `develop` (most commits land here).
- Upstream reference: `https://github.com/Darxo/Hardened`; this fork tracks its `develop`.
- Code is **Squirrel (.nut)** for game hooks + **JavaScript** for UI hooks.

## Hook classification (IMPORTANT for the QoL-only mission)

Every hook file begins with a comment labeling its purpose. Use these to sort balance churn vs QoL:

- `Feat:` — feature/behavior change (often a Hardened balance rework; review before keeping)
- `Vanilla Fix:` / `Cheese Fix:` / `Fix:` — bug/correctness repairs (usually keep-worthy)
- `QoL:` / `QOL:` — quality-of-life (keep)
- `Vanilla Adjustments:` — balance-ish tweaks (review before keeping)

When removing a hook, delete the whole `.nut` file and prune the MSU setting in `msu/msu_settings.nut` that gates it (and any `::Hardened.Global` constants it relies on).

## Load / Architecture

- **Bootstrap:** `scripts/!mods_preload/main_hardened.nut` defines `::Hardened` (ID `mod_hardened`, Version), registers `::Hardened.HooksMod = ::Hooks.register(...)`, declares requirements (`mod_reforged >= 0.9.0`, `mod_dynamic_spawns >= 0.5.0`) and conflicts, and queues hook buckets.
- **Entry include:** `mod_hardened/load.nut` includes, in order: `msu` → `api/hooks/mods` → `namespaces` → `const`/`global` → `hooks/config/strings` → `reforged/reach` → `reforged` → `api` → `hooks` → `crock_pot_hooks`. Order matters (perk defs build on strings; reach loads first).
- **Hook buckets** (queued via `HooksMod.queue(...)`): `mod_hardened/hooks/` (default), plus `hooks_early/`, `hooks_late/`, `hooks_last/`, `hooks_afterhooks/`, `hooks_first_world_init/`.
- **Globals:** `scripts/mods/mod_hardened/const.nut` (`::Hardened.Const`, e.g. faction balance tables) and `global.nut` (`::Hardened.Global`; world/contract scaling). Heavy balance knife here.
- **Balance churn lives in:** `hooks/skills/{perks,actives}/`, `hooks/items/{weapons,armor,helmets,shields}/`, `reforged/`, `hooks/mods/mod_reforged/perk_*`.
- **QoL lives in:** `hooks/ui/**`, `hooks/states/`, `hooks/root/`, `api/hooks_early/`, `msu/msu_settings.nut`.

## Coding Conventions

- Register hooks via `::Hardened.HooksMod.hook("scripts/<vanilla path>", function(q){ ... })`; use `hookTree(...)` when the vanilla script is inherited by many leaf scripts. Override pattern: `q.create = @(__original) function() { __original(); ... }`. Never call `::Hooks.register` in hook files (bootstrap only).
- Gate QoL features behind settings: `if (::Hardened.Mod.ModSettings.getSetting("<SettingID>").getValue())`.
- Define settings in `mod_hardened/msu/msu_settings.nut`: `addPage(...)`, `addBooleanSetting("<ID>", default, label, desc).addAfterChangeCallback(func)`.
- Whole-directory includes: `::includeFiles(::IO.enumerateFiles("mod_hardened/<dir>"))`. `enumerateFiles` on an empty dir throws; keep dirs non-empty.
- Helper utilities defined in `main_hardened.nut`: `wipeClass`, `snipeHook`, `controlledRound`, `getFunctionCaller`, `mockFunction`, `removeTooClosePenalty`.

## Build / Packaging

- **Build script: `build.ps1`** (repo root). Run `pwsh ./build.ps1` to zip `mod_hardened` + `scripts` + `ui` + `gfx` + `sounds` into `mod_hardened_<version>.zip` (version read from `main_hardened.nut`). Excludes `doc/`, `unpacked_brushes/`, `.bbbuilder/`, `tasks/`, `.git/`. Output zip is gitignored (`*.zip`).
- `doc/` = read-only MSU wiki dump; **never package** into the submod zip.
- `.gitignore` excludes: `*.zip`, `brushes/`, `gfx/*.png`, `.bbbuilder/`.

## Reference

- MSU API: `doc/msuteam-msu.wiki-8a5edab282632443.txt` (read-only; not packaged).
- Mod-internal docs: `mod_hardened/documentation.txt` (API vs non-API split, known issues), `mod_hardened/brainstorming.txt`.
