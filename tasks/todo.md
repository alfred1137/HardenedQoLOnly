# TODO — QoL-Only Fork Transformation

Status: IN PROGRESS — Phase 6 rename in progress (identity `mod_hardened_qol_fork`); manual load test + Phase 7 docs still open. Crash-sweep pass complete.

## Session Log (latest first)

### Session: Identity rename to mod_hardened_qol_fork (2026-08-04)

- Renamed on disk: `mod_hardened/` → `mod_hardened_qol_fork/`, `ui/mods/mod_hardened/` → `ui/mods/mod_hardened_qol_fork/`, `scripts/mods/mod_hardened/` → `scripts/mods/mod_hardened_qol_fork/`, bootstrap `main_hardened.nut` → `main_hardened_qol_fork.nut`.
- Content regex replace `mod_hardened(?![_a-z0-9])` → `mod_hardened_qol_fork` across tracked+untracked text files (14 rewritten). Negative lookahead protects already-renamed strings + `::Hardened` namespace.
- Bootstrap: `ID = "mod_hardened_qol_fork"`, `Name = "Hardened QoL Fork"`, removed GitHubURL + Registry update-source (upstream would offer wrong-ID zips as updates).
- build.ps1: PackDirs + ZipName → fork name; bootstrap path → `main_hardened_qol_fork.nut`.
- Build verified: `mod_hardened_qol_fork_1.22.0.zip`, top-level `mod_hardened_qol_fork/` + scripts/ui/gfx/sounds, no stale old-path entries, key files present.
- GOTCHA: regex lookahead `(?![_a-z0-9])` skips `mod_hardened_$Version` in build.ps1 ZipName (underscore = identifier char) — had to fix ZipName manually.

### Session: Crash-sweep + missing-KEEP restores (2026-08-04)

Fixed load-time/runtime crash risks found via symbol sweep:

- **`perk_mastery_cleaver.nut` / `perk_mastery_throwing.nut`**: referenced removed `::Hardened.Global.WeaponSpecFatigueMult` → load-time crash. Gated to icon/description Vanilla Fix only.
- **`perk_colossus.nut` / `perk_fortified_mind.nut`**: balance reworks (flat stat conversion + NPC perk-bloat) → DELETED.
- **`perk_fast_adaption.nut`**: GATE — kept stack-count name QoL, stripped multi-hit SkillCount Feat.
- **`namespaces/util.nut`**: deleted dead `genericGenerateIdealSize` (referenced 7 removed Global scalars).
- **`hooks/factions/faction.nut`**: stripped `create` negative-relation balance + `addPlayerRelation` temporary-enemy Feat; kept `addPlayerRelationEx` relation-log QoL.
- **`api/hooks/entity/tactical/actor.nut`**: stripped `HD_StaminaMin` + Hardened stamina/initiative weight formula (getStamina/getStaminaModifierFromWeight/getInitiativeModifierFromWeight). Reverted `hooks_early/entity/tactical/actor.nut` `getInitiative` override. Kept all other API helpers.
- **Restored from HEAD** (purge over-deleted; consumers kept): `hooks/items/weapons/legendary/lightbringer_sword.nut`, `hooks/items/weapons/barbarians/drum_item.nut`, `hooks/items/weapons/legendary/obsidian_dagger.nut`, `hooks/items/accesory/special/arena_collar_item.nut` (arena_contract.nut + character_screen.nut depend on its HD_savePreviousItem/HD_reequipPreviousItem).
- **`hooks/skills/special/rf_reach.nut`**: DELETED (Hardened rework of Reforged reach mechanic; wipeClass de-coupled tooltips). Reverts to Reforged reach. Kept `reforged/actor_tooltip_functions.nut` + weapon.nut reach tooltip lines (QoL display).
- **`scripts/mods/mod_hardened_qol_fork/const.nut`**: added `CaravanBannerOffset` (kept `hooks/entity/world/party.nut` onDeserialize needs it).
- **`msu/msu_settings.nut`**: pruned dead `FullForceCameraShake` (Full Force rework deleted). Kept `ContinuousWaitKeybind` (live via after-change callback).
- **`hooks/ui/global/data_helper.nut`**: NO edits needed — all QoL (per-level XP display, angry-dismiss lock, FoodDaysLeft/RepairHours/MedicineRequired, ammo/encumbrance icons).
- **`hooks/entity/world/player_party.nut`** (camp banner) + **api** (getVisionRadius) + **hooks/.../situations/situation.nut** (situation-effect tooltip export) verified KEEP — all QoL.
- `scripts/entity/world/party.nut` etc. were NEVER in repo (summary note was wrong); hooks provide the QoL — no restore needed.

Verification sweeps (all clean):

- `::Hardened.Global.X` refs — none undefined.
- `::Hardened.Const.X` — CaravanBannerOffset now defined.
- `::Hardened.util.X`, `Temp.*`, `Private.*`, `Camera.*` — all defined.
- Settings: every `getSetting(...)` defined (ExpandedSkillTooltips is MSU-core, not ours).
- HD_* function refs vs definitions — clean (remaining 3 are namespace-defined false positives).
- `load.nut` include chain: no empty enumerateFiles targets (crock_pot block removed; api/hooks/mods + hooks have nested files).
- `build.ps1` → `mod_hardened_1.22.0.zip` builds clean.

## Context

Clone of upstream Hardened (Reforged submod, ID `mod_hardened_qol_fork`, branch `develop`).
Mission: **remove Reforged perk/mechanic overhauls + global difficulty scaling; retain & curate QoL improvements.**

User decisions:

- **Hybrid** purge: delete isolated balance files; gate files that mix QoL + balance.
- **Remove** world/contract/faction scaling (`::Hardened.Global` scalars) → revert to base Reforged scaling.
- **Stay a Reforged submod** (keep `mod_reforged >= 0.9.0`, `mod_dynamic_spawns >= 0.5.0` hard reqs).
- **Verify by zip script + manual game load** over Reforged; user reports issues.
  Mod identity decision: **rename to `mod_hardened_qol_fork`** (distinct from upstream `mod_hardened_qol_fork`, so fork can coexist in Mods folder). Decision pending implementation details below.
  Numerals decision: **keep** `namespaces/numerals.nut` numeral/hide-exact-size as QoL-gated feature (and its `world_entity`/`location`/`party`/`world_state` hooks).

## Phase 0 — Harness

- [ ] Add `build.ps1` zipping required top-level dirs (`mod_hardened_qol_fork`, `scripts`, `ui`, `gfx`, `sounds`, `fonts`, data) into `mod_hardened_<ver>.zip`; exclude `doc/`, `unpacked_brushes/`, `.bbbuilder/`, tooling. Validate layout vs upstream release zip.
- [ ] Update `AGENTS.md` build section (currently claims no build script).
- [ ] Create `tasks/lessons.md`.

## Phase 1 - Full triage (parallel read-only subagents) - DONE

Spawn one investigator per domain → `path → {KEEP, DELETE, STRIP, REVERT}` + mixed-file flags. Aggregate to `tasks/triage.md`. DONE - full inventory classified, KEEP/GATE lists recorded.
Domains:

- (a) `hooks/skills/**`
- (b) `hooks/items/**`
- (c) `hooks/config/**` + `scripts/mods/mod_hardened_qol_fork/{const,global}.nut` + `namespaces/`
- (d) `hooks/{factions,contracts,events,ambitions,retinue,crafting}/`
- (e) `hooks/entity/**`
- (f) `api/**`
- (g) `reforged/` + `hooks/mods/**` + `crock_pot_hooks` + `optional_mods`
- (h) `hooks/{states,root,ui,tactical_camera}` + `ui/` JS/CSS

## Phase 2 — Revert scaling subsystem (DELETE/revert)

- [ ] Strip `::Hardened.Global` scaling scalars/funcs + every dependent hook → base Reforged scaling.
- [ ] Delete: `hooks_early/entity/world/attached_location*`, dynamic_spawns + `mod_dynamic_spawns` hooks, `hooks/config/factions/*` XP tables, `api/hooks/events`, `api/hooks/factions/*`, `api/hooks/entity/world/location`, `hooks/contracts/*` difficulty + negotiation, `tooltip_events.nut` world/contract-difficulty lines, settlement/caravan resource mults.
- [ ] Remove `addTemporaryEntity`/`EntityIDFallback` save-swap machinery + `hooks_late/config/faction_temporary_units.nut`.

## Phase 3 — Strip isolated balance (DELETE)

- [ ] `reforged/` reach rework + reach-coupled hooks (`hooks/config/character`, `rf_reach`, `perk_rf_*`, `perk_groups`/`perk_group_collections`, `hooks_first_world_init/perks_adjusted.nut` trimmed).
- [ ] New-perk / perk-rework files per triage.
- [ ] `hooks/items/**`, `hooks/entity/**` reworks per triage.

## Phase 4 — Gate mixed files (GATE)

- [ ] Files mixing balance + keep-worthy QoL/Fix: `return` early out of balance code, preserve QoL. Document gates in `tasks/triage.md`.

## Phase 5 — Static sanity check

- [x] Grep asserts: zero refs to removed symbols (`getWorldDifficultyMult`, `getWorldContractMult`, `::Reforged.Reach.*` (rf_reach deleted), removed Global scalars, deleted perk paths). Fix offenders.
- [x] Session crash-sweep: Global/Const/util/Temp/Private/Camera refs, settings, HD_* function defs, load.nut include chain — all verified clean.

## Phase 6 — Identity rename + user load test

- [x] Rename identity to `mod_hardened_qol_fork`: folder, `ID`, `scripts/mods`, `ui/mods`, bootstrap filename (`main_hardened_qol_fork.nut`), include paths, build.ps1. Removed upstream GitHub update-source (would offer upstream zips as "updates"). Name → "Hardened QoL Fork".
- [x] Run `build.ps1`; verify zip layout (top-level `mod_hardened_qol_fork/`, no stale old-path entries, key files present). → `mod_hardened_qol_fork_1.22.0.zip` (456 entries).
- [ ] User loads zip over Reforged, tests new campaign + key QoL screens; report bugs → fix iteratively.

## Phase 7 — Docs & cleanup

- [x] Rewrite `README.md` to QoL-only scope.
- [x] Sync `AGENTS.md` (build script, scaling removed, Hybrid hook-classification).
- [x] Trim `mod_hardened_qol_fork/documentation.txt` known-issues referencing removed mechanics. Removed `brainstorming.txt` (upstream balance/AI/content plans, out of fork scope).

## Review / Lessons

- [ ] Record review section here when done.
- [ ] Update `tasks/lessons.md` with mistakes/patterns.
