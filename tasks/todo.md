# TODO — QoL-Only Fork Transformation

Status: STABLE — v1.22.2-patch.7 released (0 ScriptErrors, 0 Unknown Brush on live test 2026-08-05 14:34). Crash-sweep pass complete. Patch cycle closed.

## Session Log (latest first)

### Session: 1.22.4-patch.1 — clock readout phase fix (2026-08-07)

- User report: in-game clock period labels phase-shifted (night→afternoon, dawn→midday, morning→sunset).
- Diagnosis: fork hosts upstream's `Const.Strings.World.TimeOfDay` verbatim (12 entries) + vanilla `floor(Hours/2)` bucketing; upstream `Const.World.TimeOfDay` object (`world.nut`) is rotated a half step → labels read wrong bucket. Verified byte-identical to upstream → inherited, not fork-introduced.
- Fix (Hardened schedule): rotated label array (`hooks/config/strings/strings.nut`: Sunrise first, Dawn last) + new `hooks/config/world.nut` repointing `Const.World.TimeOfDay` indices (Sunrise=0, Dusk=9, Midnight=10, Dawn=11) so isDay/isNight night buckets = hours 18-23.
- Verified build zip payload (world.nut + strings.nut present, indices correct). Committed `249b9b88`, tagged `1.22.4-patch.1`, release: https://github.com/alfred1137/HardenedQoLOnly/releases/tag/1.22.4-patch.1.
- Deferred: `tactical.nut` AmbientLightingColor tint rotation + "Monring" typo (cosmetic; revisit 1.22.4-patch.2 if tint mismatch reported).

### Session: v1.22.4 bump + combat-dialog freeze fix (2026-08-07)

- Bumped fork `Version` 1.22.3 -> 1.22.4 (aligns with upstream 1.22.4 base; build output now `mod_hardened_qol_fork_1.22.4.zip`).
- Carry-over upstream 1.22.4 fix `5522495f`: world map invisible UI freeze when cancelling a combat dialog into an immediate attack. Ported `world_combat_dialog.nut` (`HD_forceAllowDialog`/`HD_isHidingScreen` + `show`/`isVisible`/`isAnimating`/`onScreenHidden` overrides) + js_hooks `show` velocity-stop. No new settings.
- Explicitly NOT ported from 1.22.4: Reforged contract-setting hide `HD_hide("Disabled")` (no fork consumer; N/A) and tooltip wording change "an enemy" → "anyones" (upstream grammar regression).
- docs: README + documentation.txt changelog → 1.22.4.
- Release: https://github.com/alfred1137/HardenedQoLOnly/releases/tag/1.22.4 (tag `1.22.4`, branch `develop` tip `32b78068`).
- Tag schema change (user): version-bump releases tag with the bare upstream-mirror version (`1.22.4`); patches on that base → `1.22.4-patch.N`. Initial `v1.22.2-patch.13` tag + release deleted and re-published as `1.22.4`.

### Session: Release + crash-sweep patches (2026-08-05)

Published GitHub release v1.22.2 (upstream-aligned version), then fixed 5 purge-over-delete classes found via live game logs. Version stays in sync with upstream (`1.22.3`); patch tags `v1.22.2-patch.N` (schema prefix unchanged; version field tracks upstream base):

- **v1.22.2-patch.1** — restored `CharacterProperties.getHeadHitchance` + `getHitchance` override + `HeadshotReceivedChance`/`HeadshotReceivedChanceMult` (kept tooltip hooks skill.nut:81 + actor.nut call them; purge deleted them). Restored lean `strategy.nut` with `HD_DealtHitToEnemy`/`HD_WasHitByEnemy` stats (kept skill_container.nut writes them; dropped upstream `updateDefending` Feat).
- **v1.22.2-patch.2** — restored `::Const.Corpse.HD_FatalityType`, `HD_CorpseTouched`, `::Const.Combat.ShakeEffectZOCHighlight` (kept actor.nut onDamageReceived + turn_sequence_bar ZOC highlight read them).
- **v1.22.2-patch.3** — added standalone `gfx/ui/mini/hd_bleeding_mini_{1..5}.png` (insufficient — see brush lesson).
- **v1.22.2-patch.4** — restored `::Const.World.HD_InventoryUpgradeSlots` with VANILLA values `[9,9,9]` (upstream `[18,27,36]` = balance churn; kept retinue_manager + tooltip read it).
- **v1.22.2-patch.5** — added `unpacked_brushes` to build (insufficient — dev source format, not runtime).
- **v1.22.2-patch.6** — shipped COMPILED brushes: `brushes/mod_hardened.brush` + `gfx/mod_hardened.png` atlas (+ orientation/world_entity pairs) extracted from upstream 1.22.2 release zip; added `brushes/` to build PackDirs. This is the release format (matches MSU `brushes/msu_world.brush`).
- **v1.22.2-patch.7** — dropped `unpacked_brushes` from build (redundant; compiled brushes supersede).

Final live test (test-202608051434-log.html): 0 ScriptErrors, 0 Unknown Brush, 11 bleed deaths clean. Remaining log noise all cosmetic/external (banner_1822/104 png, Arsenal-Regular.ttf, MSU regex `Invalid match` warnings on sling-diversion + damage lines).

Release: https://github.com/alfred1137/HardenedQoLOnly/releases/tag/v1.22.2-patch.7. Branch `develop` tip `cfa1e1d6`.

### Session: v1.22.3 bump + Hardened incompatibility (2026-08-06)

- Bumped fork `Version` 1.22.2 -> 1.22.3 (aligns with upstream 1.22.3 base; build output now `mod_hardened_qol_fork_1.22.3.zip`).
- Carry-over upstream 1.22.3 fix: invert `isGarbage()` guard in `skill.onAdded` (`skill.nut` onOtherSkillAdded path) — self-invalidating skills no longer spuriously re-fire `onOtherSkillAdded`.
- Declared upstream **Hardened** (`mod_hardened`) as a conflicting mod via `HooksMod.conflictWith` in `scripts/!mods_preload/main_hardened_qol_fork.nut`; MSU / Modern Hooks now block loading both Hardened forks together.
- README: install guide corrected (drop `.zip` as-is into `/data/`; do not extract) + incompatibility + dependency-closure note.
- Retired GitHub Releases v1.22.2-patch.8 / v1.22.2-patch.9 / v1.22.2 (superseded). Retagged release as v1.22.2-patch.12 (git tag v1.22.2-patch.11 retained as pre-1.22.3 historical anchor; release asset+notes live at patch.12).
- Verified built `mod_hardened_qol_fork_1.22.3.zip`: `Version="1.22.3"`, `conflictWith` entry `mod_hardened [...]` present.

Release: https://github.com/alfred1137/HardenedQoLOnly/releases/tag/v1.22.2-patch.12. Branch `develop` tip `370e4b7d`.

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

- [x] Record review section here when done.
- [x] Update `tasks/lessons.md` with mistakes/patterns.
