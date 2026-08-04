# TODO — QoL-Only Fork Transformation

Status: IN PROGRESS — Phase 1 (triage) complete, executing phases 0-6.

## Context

Clone of upstream Hardened (Reforged submod, ID `mod_hardened`, branch `develop`).
Mission: **remove Reforged perk/mechanic overhauls + global difficulty scaling; retain & curate QoL improvements.**

User decisions:

- **Hybrid** purge: delete isolated balance files; gate files that mix QoL + balance.
- **Remove** world/contract/faction scaling (`::Hardened.Global` scalars) → revert to base Reforged scaling.
- **Stay a Reforged submod** (keep `mod_reforged >= 0.9.0`, `mod_dynamic_spawns >= 0.5.0` hard reqs).
- **Verify by zip script + manual game load** over Reforged; user reports issues.
  Mod identity decision: **rename to `mod_hardened_qol_fork`** (distinct from upstream `mod_hardened`, so fork can coexist in Mods folder). Decision pending implementation details below.
  Numerals decision: **keep** `namespaces/numerals.nut` numeral/hide-exact-size as QoL-gated feature (and its `world_entity`/`location`/`party`/`world_state` hooks).

## Phase 0 — Harness

- [ ] Add `build.ps1` zipping required top-level dirs (`mod_hardened`, `scripts`, `ui`, `gfx`, `sounds`, `fonts`, data) into `mod_hardened_<ver>.zip`; exclude `doc/`, `unpacked_brushes/`, `.bbbuilder/`, tooling. Validate layout vs upstream release zip.
- [ ] Update `AGENTS.md` build section (currently claims no build script).
- [ ] Create `tasks/lessons.md`.

## Phase 1 - Full triage (parallel read-only subagents) - DONE

Spawn one investigator per domain → `path → {KEEP, DELETE, STRIP, REVERT}` + mixed-file flags. Aggregate to `tasks/triage.md`. DONE - full inventory classified, KEEP/GATE lists recorded.
Domains:

- (a) `hooks/skills/**`
- (b) `hooks/items/**`
- (c) `hooks/config/**` + `scripts/mods/mod_hardened/{const,global}.nut` + `namespaces/`
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

- [ ] Grep asserts: zero refs to removed symbols (`getWorldDifficultyMult`, `getWorldContractMult`, `::Reforged.Reach.*`, removed Global scalars, deleted perk paths). Fix offenders.

## Phase 6 — Build + user load test

- [ ] Run `build.ps1`; user loads zip over Reforged, tests new campaign + key QoL screens; report bugs → fix iteratively.

## Phase 7 — Docs & cleanup

- [ ] Rewrite `README.md` to QoL-only scope.
- [ ] Sync `AGENTS.md` (build script, scaling removed, Hybrid hook-classification).
- [ ] Trim `mod_hardened/documentation.txt` known-issues referencing removed mechanics.

## Review / Lessons

- [ ] Record review section here when done.
- [ ] Update `tasks/lessons.md` with mistakes/patterns.
