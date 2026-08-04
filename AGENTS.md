# AGENTS.md

## Repository Overview

Fork of **Hardened** (a submod for the Battle Brothers overhaul mod **Reforged**). This codespace is now a **QoL-only fork**: Reforged perk/mechanic overhauls and Hardened's world/contract/faction scaling subsystem are removed; QoL improvements and bug fixes are retained. Identity: **`mod_hardened_qol_fork`** (distinct ID/folder from upstream so both can coexist in a Mods folder).

- Working branch: `develop` (most commits land here).
- Upstream reference: `https://github.com/Darxo/Hardened`; this fork tracks its `develop` (base upstream release `1.22.0`, incorporates upstream `1.22.1` null-guard fixes).
- Code is **Squirrel (.nut)** for game hooks + **JavaScript** for UI hooks.
- Transformation state/triage: `tasks/triage.md`, `tasks/apply_triage.ps1`, `tasks/todo.md`, `tasks/lessons.md`.

## Hook classification (IMPORTANT for the QoL-only mission)

Every hook file begins with a comment labeling its purpose. Use these to sort balance churn vs QoL:

- `Feat:` — feature/behavior change (often a Hardened balance rework; review before keeping)
- `Vanilla Fix:` / `Cheese Fix:` / `Fix:` — bug/correctness repairs (usually keep-worthy)
- `QoL:` / `QOL:` — quality-of-life (keep)
- `Vanilla Adjustments:` — balance-ish tweaks (review before keeping)

When removing a hook, delete the whole `.nut` file and prune the MSU setting in `msu/msu_settings.nut` that gates it (and any `::Hardened.Global` constants it relies on).

## Load / Architecture

- **Bootstrap:** `scripts/!mods_preload/main_hardened_qol_fork.nut` defines `::Hardened` (ID `mod_hardened_qol_fork`, Name, Version), registers `::Hardened.HooksMod = ::Hooks.register(...)`, declares requirements (`mod_reforged >= 0.9.0`, `mod_dynamic_spawns >= 0.5.0`) and conflicts, and queues hook buckets. Filename is fork-suffixed so it never collides with upstream `main_hardened.nut` when both zips are installed.
- **Entry include:** `mod_hardened_qol_fork/load.nut` includes, in order: `msu` → `api/hooks/mods` → `namespaces` → `const`/`global` (from `scripts/mods/mod_hardened_qol_fork/`) → `hooks/config/strings` → `reforged` → `api` → `hooks`. Order matters (perk defs build on strings).
- **Hook buckets** (queued via `HooksMod.queue(...)`): `mod_hardened_qol_fork/hooks/` (default), plus `hooks_early/`, `hooks_late/`, `hooks_last/`, `hooks_afterhooks/`, `hooks_first_world_init/`.
- **Globals:** `scripts/mods/mod_hardened_qol_fork/const.nut` defines `::Hardened.Const` (now only `AmmoType` + `getAmmoType()` + `CaravanBannerOffset`); `global.nut` defines `::Hardened.Global` (now only `LabelBackgroundAlpha`). **World/contract/faction scaling scalars were removed** — do not re-add.
- **Balance churn removed.** Remaining hooks are QoL + fixes only. Notable kept infra: `hd_retreat_skill`, arena-collar restore, reload/ammo wiring, hitchance overlay + auto-camera, `HD_*` API helpers on `actor`/`skill`/`item`, `::Hardened.Temp.RootSkillCounter`.
- **QoL lives in:** `hooks/ui/**`, `hooks/states/`, `hooks/root/`, `api/hooks_early/`, `msu/msu_settings.nut`.

## Coding Conventions

- Register hooks via `::Hardened.HooksMod.hook("scripts/<vanilla path>", function(q){ ... })`; use `hookTree(...)` when the vanilla script is inherited by many leaf scripts. Override pattern: `q.create = @(__original) function() { __original(); ... }`. Never call `::Hooks.register` in hook files (bootstrap only).
- Gate QoL features behind settings: `if (::Hardened.Mod.ModSettings.getSetting("<SettingID>").getValue())`.
- Define settings in `mod_hardened_qol_fork/msu/msu_settings.nut`: `addPage(...)`, `addBooleanSetting("<ID>", default, label, desc).addAfterChangeCallback(func)`.
- Whole-directory includes: `::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/<dir>"))`. `enumerateFiles` on an empty dir throws; keep dirs non-empty.
- Helper utilities defined in `main_hardened.nut`: `wipeClass`, `snipeHook`, `controlledRound`, `getFunctionCaller`, `mockFunction`, `removeTooClosePenalty`.

## Build / Packaging

- **Build script: `build.ps1`** (repo root). Run `pwsh ./build.ps1` to zip `mod_hardened_qol_fork` + `scripts` + `ui` + `gfx` + `sounds` into `mod_hardened_qol_fork_<version>.zip` (version read from `main_hardened_qol_fork.nut`). Excludes `doc/`, `unpacked_brushes/`, `.bbbuilder/`, `tasks/`, `.git/`. Output zip is gitignored (`*.zip`). Verified: builds clean after the QoL purge.
- `doc/` = read-only MSU wiki dump; **never package** into the submod zip.
- `.gitignore` excludes: `*.zip`, `brushes/`, `gfx/*.png`, `.bbbuilder/`.

## Lessons

- Session logs in `tasks/lessons.md`. Key ones: purge over-deletes KEEP files (restore files whose consumers are kept — e.g. arena_collar_item, drum_item); removed `::Hardened.Global/Const` members referenced by kept hooks crash on load (sweep after every strip); `::MSU.Mod.ModSettings.getSetting("ExpandedSkillTooltips")` is MSU-core, not ours; `enumerateFiles` only throws on truly empty dirs (subdir-only dirs are fine); `scripts/entity/world/party.nut` etc. were never tracked — verify restore claims against `git log --all`.

## Reference

- MSU API: `doc/msuteam-msu.wiki-8a5edab282632443.txt` (read-only; not packaged).
- Mod-internal docs: `mod_hardened_qol_fork/documentation.txt` (API vs non-API split, known issues). Upstream brainstorming.txt was removed — it described balance/AI/content plans outside fork scope.
