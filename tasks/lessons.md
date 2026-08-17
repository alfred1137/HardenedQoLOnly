# Lessons Learned

Session log of mistakes/patterns to avoid. Review at session start.

## 2026-08-04 — Hardened → QoL-only fork triage

- **Subagent tool corrupts on LARGE scopes.** Batches of 10 or 4 big-dir tasks returned garbled/empty JSON. Small scopes (<= ~130 files, or single-file deep reads) succeeded reliably. Rule: keep each triage task to one directory or one big file; never ask one agent to cover 400+ files.
- **Em-dash / unicode in Edit tool strings breaks JSON parse.** Use plain hyphens in `oldString`/`newString`. (Hit twice editing todo.md.)
- **Header-comment classification is the fast path.** `// QoL:`/`// Fix:`/`// Vanilla Fix:` = keep; `// Feat:`/`// Vanilla Adjustments:`/no header = balance. Read full body only when header ambiguous. This made 1600-file triage tractable.
- **Cross-file dependency units must be decided as a whole.** e.g. knockback (`util.findTileToKnockBackTo` + api skill + fling_back + gore/repel/kingfisher) and ranged/ammo overhaul — deleting one orphan breaks the rest. Flag units, don't split.
- **Mechanical regex pass (bash) is a good fallback when subagents glitch**, but leaves UNKNOWNs; manual spot-read of ambiguous infra files is required.
- **User may override a verdict** (config/character.nut + faction_greenskins.nut GATE→DELETE). Respect the override; note the trade-off (lost roundToDec/spawnlist fixes).
- **build.ps1**: stage to temp dir, copy package dirs, strip junk dirs, `Compress-Archive`. Verify zip top-level entries after build.

## 2026-08-04 — Crash-sweep pass (post-purge)

- **Purge over-deletes KEEP files.** `drum_item`, `lightbringer_sword`, `obsidian_dagger`, `arena_collar_item` were deleted but their consumers (`arena_contract.nut`, `character_screen.nut`) were kept → runtime crash. Rule: after any purge, grep every kept hook for calls to functions whose defining file was deleted; restore the defining file if a kept consumer exists.
- **Removed Global/Const members referenced by kept hooks = load-time crash.** `WeaponSpecFatigueMult` (mastery perks), `CaravanBannerOffset` (party.nut), 7 scaling scalars (util.nut). Rule: sweep `::Hardened.Global.X`/`::Hardened.Const.X` refs vs definitions after stripping; either delete the dead consumer or re-add the const.
- **`::MSU.Mod.ModSettings.getSetting("ExpandedSkillTooltips")` is MSU-core, not ours** — don't flag it as missing in a Hardened-only settings sweep.
- **`::IO.enumerateFiles` on a dir with only subdirs is fine** (returns nested files); only a truly empty dir throws. Check with recursive file count, not direct-file count.
- **`scripts/entity/world/party.nut` etc. were never tracked** — a "restored from HEAD" note in a prior summary was wrong; verify against `git log --all -- <path>` before trusting restore claims.
- **`::Hardened.Const.CaravanBannerOffset` was defined in `main_hardened.nut` queue, not const.nut** — when re-scoping const.nut, re-check main_hardened.nut for const definitions that kept hooks still need.

## 2026-08-04 — Identity rename (phase 6)

- **Folder name = include path.** `::include("mod_hardened/load")` resolves against the zip root, so renaming the mod ID requires renaming the top-level folder AND every `"mod_hardened/..."` string in .nut/.js/ps1 files.
- **Bootstrap filename must differ too.** `scripts/!mods_preload/main_hardened.nut` is a shared virtual path — upstream + fork zips both mounting it collide. Fork uses `main_hardened_qol_fork.nut`.
- **Regex lookahead gotcha:** `mod_hardened(?![_a-z0-9])` correctly protects `mod_hardened_qol_fork` but ALSO skips `mod_hardened_$Version` (underscore counts as identifier char) — verify build.ps1/other filename-building lines manually after a string-replace rename.
- **Remove upstream GitHub update-source in forks.** `Registry.setUpdateSource` pointing at upstream would offer upstream zips (different mod ID) as "updates" for the fork. Delete the Registry lines + GitHubURL.

## 2026-08-04 — Docs + commit (phase 7)

- **Upstream changelog in a fork is factually wrong, not just stale.** documentation.txt claimed ~95% balance changes that were deleted. Rewrote to fork-accurate scope + upstream pointer. Never leave removed-feature changelogs shipping in a zip.
- **brainstorming.txt was never tracked** (git ls-files empty) — deleting it is a no-op for git. Verify with git ls-files before expecting a D entry.
- **gfx pngs are all tracked despite .gitignore `gfx/*.png`.** The rule only matches gfx/ root; all 66 files live in subdirs covered by `!gfx/*/.png`. Inert but harmless — user said keep.
- **Docs-only changes don't need a rebuild** (documentation.txt is packaged text, brainstorming.txt wasn't packaged-visible to git anyway).

## 2026-08-04 — Test-log fixes (user load test #1)

- **Edit/Write tools silently failed on one JS file** (reported success, file unchanged; attr = Archive, not read-only). Bash Set-Content persisted. Rule: after ANY edit of packaged files, verify on-disk bytes (Get-Content or git diff), don't trust tool success.
- **Upstream onEquip bug is real and the naive fix was wrong.** Hardened wrote `function()` but used `_item` (undefined; vanilla passes 0 args) → crash on crossbow/firearm equip. Fork's "fix" (adding `_item` param) doesn't help — nothing passes it, and it tripped 526 MSU wrap warnings. Correct: `function()` + use `this` (the weapon).
- **MSU wrap warnings = signature mismatch signal.** "wrapping function X with more required parameters than before" = wrapper declares params vanilla doesn't pass. Fix signature to match, don't add params.
- **JS trailing commas break BB's CEF** (`function ( _a, )` → SyntaxError, whole file fails to load). Scan shipped JS for `,\s*\)` and `,$` before next-line `)` before building.
- **Log analysis:** game log is time/tag/text triplets; CSS line pollutes naive greps — exclude line 1 before searching. 791 warnings, 526 ours (all onEquip), rest MSU-own (optional-param, benign).

## 2026-08-04 — Campaign-load crash (user test #2)

- **Crash-sweep must cover ALL removed-API shapes, not just `::Hardened.*`.** Missed `::Const.World.Spawn.HD_AttachedProduction` (deleted with dynamic_spawns human_parties.nut) and actor method `getStamina` (deleted with api/hooks/entity/tactical/actor.nut). Rule: after purge, grep kept files for every removed symbol family: `::Const.*.HD_*`, non-prefixed actor methods (getStamina), HD_StaminaMin etc.
- **Gate-strip verdicts can be partially executed.** attached_location.nut triage said "strip raidable/rebuild/loot" but the strip never happened — file shipped with the whole Feat + removed Const. Rule: after GATE file, verify the strip actually removed the balance parts, not just left the file.
- **Cascade errors hide root cause.** 47x `Scale` (vanilla onAfterInit) + 1x `setBrush` were downstream of 47x getStamina init crash. Fix root; cascades resolve. Get per-error counts (65/47/47/1) to spot the root.
- **Edit tool flakiness is real.** Failed silently on the JS file AND risk on others — always `git diff --stat` + re-grep removed refs after editing.
- **Vanilla actor lacks getStamina** (only actor_properties.getStamina exists); Hardened defined it via API for the stamina rework. Any kept caller breaks without it.

## 2026-08-04 — Campaign-load crash #2 (bag-slot infra)

- **Kept feature can depend on a deleted balance property.** hd_bag_item_manager (kept) read `_properties.BagSlots`, a Hardened property defined in deleted config/character.nut (`BagSlots <- 2` = balance normalization 4->2). Manager threw onAfterUpdate -> property update aborted -> 47x Scale + 1x setBrush cascade. Rule: when a kept script reads a `_properties.X` or `::Const.*.X` that purge removed, decide KEEP-feature vs STRIP-feature; don't restore the balance property.
- **Bag-slot normalization is balance, silhouettes are QoL.** Manager (clamps slots to 2) = balance -> deleted. hd_bag_item_silhouettes (visual display) = QoL -> kept. Split features along balance/QoL line.
- **Cascade confirmed by error ordering.** Log showed strict `BAG SCALE BAG SCALE...` interleave = 1:1 cascade, not independent. Fix root, cascades vanish.
- **Member defs deleted with their file.** `q.m.HD_BagSlotSpriteName` lived in deleted hooks/entity/tactical/human.nut; kept api human.nut used it. Restore the member def in the kept file, don't recreate the deleted file.
- **git add -A sweeps test logs.** User drops HTML logs in tasks/; `git add -A` commits them. Use targeted `git add <paths>` for code commits.

## 2026-08-04 — Campaign-load crash #3 (CharacterProperties member seeds)

- **Purged config/character.nut was a member-seed file, not just balance.** `::Const.CharacterProperties.X <- default` lines seed EVERY character's cloned properties. KEPT hooks reading purged members throw "the index 'X' does not exist" on the read path. Deleting the file silently creates landmines across every kept feature that consumed its seeds.
- **Reach timing varies:** ShowFrenzyEyes (read every spawn via hd_frenzy_eyes_manager onAfterUpdate) crashed immediately at loadCampaign; HD_HitChanceMax / CanExertZoneOfControl / ShieldDamage* / WeaponDurabilityLossMult crash only when combat/UI/tooltip paths run — latent, would have been next crash. Grep sweep (`git grep` upstream file members vs kept reads) found them all in one pass.
- **Fix class not instance:** restoring all 6 QoL-supporting seeds in one recreated hooks/config/character.nut beats fixing one crash per test cycle. Exclude balance members + function overrides (vanilla fns already exist).
- **`<-` in Squirrel = create-or-replace; `=` = assign.** Upstream config/character.nut used `<-` for Hardened-added members (vanilla-absent) vs `=` for overrides of vanilla members. Member reads = crash risk; fn overrides = silent behavior change.
- **Frenzy-eyes is QoL, not balance:** kept killing_frenzy_effect + berserker_mushrooms_effect setters + ShowGlowingEyes setting + sprite add all survived purge; only the property seed died. Restore seed, not the effects.

## 2026-08-04 — Fight-entry stall (43k Native stack overflow)

- **Mocking a low-level native then running heavy logic inside the mock = recursion hazard.** showCombatDialog mocks ::Math.minf, and the mock callback called getNumeralString -> getSetting, whose MSU internals re-call ::Math.minf -> re-enters the mock -> infinite recursion (43k stack overflows = the slowdown). Fix: re-entrancy guard flag; nested minf calls fall through to the real function. Rule: never execute code inside a mocked low-level fn that might call that same fn.
- **Parsing a 678MB single-line BB log:** regex-replace <[^>]+> over the whole string is catastrophically slow; use chunked StreamReader + per-chunk regex, keep a ~400-char carry overlap at chunk boundary for matches crossing chunks. Row-type counts via string.Split('class=\x22row error\x22') identify the flood; then extract each distinct error message's first stacktrace by regex windows.
- **Missing waypoint spawn = null cascade.** Kept world_state spawns scripts/entity/world/hd_waypoint (QoL DisplayWaypoint marker); the file was purged as "world subsystem". spawnEntity returns null for a missing script -> 209x 'init does not exist' + nulls leaked into world-party arrays -> other mods (ambition_manager, defend_military_action, crock_pot) iterate nulls (isAlliedWithPlayer/isAlive/isLocation/isParty). Restore the file, cascade clears.
- **Balance leftover inside kept file.** kept player.nut onInit still read ::Const.Difficulty.getPlayerDamageReceivedMult() (Hardened difficulty scaling = purged balance). Its fn def died with config/global.nut -> 288x. On purge, sweep kept files for reads of removed Difficulty/Global/Const entries too, not just CharacterProperties.
- **Reforged namespace version drift.** upsteam tooltip indexed ::Reforged.Reach.ReachAdvantageMult; installed Reforged renamed it -> missing key aborted the WHOLE nested_tooltips file (un-registering every Concept -> cascade 7x Weight tooltip errors). One fragile deref in a big registration file = whole file dies. Guard with 'in' + fallback.

## 2026-08-04 — Save-time crash (orphan serialize)

- **A kept hook can serialize a purged system.** world_state.onSerialize still called ::World.EntityManager.m.HD_BountyHunterManager.onSerialize(); the bounty-hunter manager (balance) + its entity_manager member def died in purge -> 'HD_BountyHunterManager does not exist' on save. When stripping a system, also sweep kept files for serialization (onSerialize/onDeserialize) of its members.
- **Banner load errors (banner_104/1822.png) not ours:** fork ships NO gfx/ui/banners dir; high banner IDs come from other installed mods. Verify asset ownership before chasing cosmetic load warnings.

## 2026-08-05 — Tooltip Range:0 regression

- **QoL tooltip synthesis must bail on zero-range skills.** hooks/skills/skill.nut.getTooltip pushed a synthetic Range bullet for any `isTargeted()` skill lacking a vanilla "Has a range of" line; api/hooks/skills/skill.nut.HD_generateRangeTooltipString then appended `getMaxRange()` — which is `0` for perks/backgrounds/self-target skills, producing literal "Range: 0 tiles". Guard both: only add the row when `this.getMaxRange() > 0`, and make the generator return `""` when max range <= 0. When a kept QoL hook _invents_ a tooltip row, it must respect the skill's actual data or it silently rewrites vanilla tooltips.

## 2026-08-05 — Upstream 1.22.2 incorporation

- **Upstream micro-releases need a 2-step classification per commit.** `git cherry`-equivalent (commit range diff --stat + `show --stat`) + AGENTS.md hook headers. For this fork: `a6074362` fix(null guard skill::onSkillsUpdated) PORTED (kept file, correctness, matches 1.22.1 guard style); `abd3061c` api(HD_getDebuffDuration) PORTED (pure HD_* math on vanilla NegativeStatusEffectDuration, no removed Const refs); `683a0d89` feat(improve charm) SKIPPED — charm_skill.nut already purged by balance strip and fork's charmed_effect.nut is the lean QoL variant; overwriting it with upstream "improve charm" re-introduces perk balance churn. Rule of thumb: any commit touching a `hooks/skills/...` perk file under `actives/` or `effects/` with a `feat:`/`Feat:` header = inspect for balance reads of removed `::Hardened.Const`/`Difficulty` — if it rewrites behavior, skip; if it's pure `HD_*` API on vanilla consts or a pure null/IO guard on a kept file, port.
- **Version bump must ride the same commit as upstream ports.** Don't bump bootstrap Version in a docs-only commit while code ports sit uncommitted — MSU reads Version at mod-register time; a stale 1.22.1 with 1.22.2 code makes bug reports un-reproducible. Bump + code + package together.
- **Confirm upstream file set vs fork file set before diff.** 1.22.2's charm commit touches `mod_hardened/hooks/skills/...` — fork root is `mod_hardened_qol_fork/...`. Diffing against `upstream 1.22.2` directly still works because upstream renamed its dir to `mod_hardened` between 1.22.0 and 1.22.1; just map paths. Don't assume a missing upstream file means "already ported" — it may mean "purged as balance".

## 2026-08-05 — Release + purge-over-delete patch cycle

- **Purge-over-delete recurs in 5 more classes, all the same shape: kept hook reads an upstream-only seed, purge deleted the seeding file.** `getHeadHitchance` (character.nut), `HD_DealtHitToEnemy`/`HD_WasHitByEnemy` (strategy.nut), `HD_FatalityType`/`HD_CorpseTouched`/`ShakeEffectZOCHighlight` (character.nut), `HD_InventoryUpgradeSlots` (world_assets.nut), bleeding mini brushes (gfx). Rule: grep every KEPT hook for `HD_*`/`::Const.*` reads AND for assets (brush/icon names), then verify the seeding definition survives. One sweep now beats 5 test cycles.
- **`skill.getHitchance(target)` (vanilla skill method) internally routes through `CharacterProperties.getHitchance`** — the upstream `getHitchance` override that delegates to `getHeadHitchance` under Temp attacker/skill/target is REQUIRED by kept actor.nut hit-overlay, not just the direct call in skill.nut:81. Restore the whole chain, not just the leaf function.
- **Restoring a constant with upstream's value can re-import balance.** `HD_InventoryUpgradeSlots` upstream `[18,27,36]` doubles cart capacity; fork restored `[9,9,9]` (vanilla progression) so the QoL display keeps vanilla balance. When a kept hook needs an upstream-only const, prefer the vanilla-equivalent value.
- **unpacked_brushes is DEV source, not the runtime format.** Shipping `unpacked_brushes/mod_hardened/metadata.xml` in the zip did NOT register sprite ids. Release zips ship COMPILED `brushes/<name>.brush` + `gfx/<name>.png` atlas (MSU convention: `brushes/msu_world.brush` + `gfx/msu_world.png`). Fix: extract the .brush + atlas from the upstream release zip (not the repo), add `brushes/` to build PackDirs, keep `unpacked_brushes` excluded.
- **IconMini standalone PNGs don't register mod brushes.** `gfx/ui/mini/hd_bleeding_mini_*.png` alone still threw "Unknown Brush requested" — the sprite id must exist in a compiled .brush. Verify the brush binary contains the sprite id string (`[IO.File]::ReadAllBytes` + `-match`).
- **Distinguish stale test from real failure by timestamps.** Log start time vs zip build time: test-202608051200 (12:01) ran BEFORE the 1.22.3 zip (12:07) → `getHeadHitchance` error was stale, not a fix failure. Always compare before declaring a fix broken.
- **Vortex deploys via zip hash — replace zip, not contents.** `vortex.deployment.json` tracks the zip; verify the deployed zip's mtime/content matches the release you think the user tested.

## 2026-08-06 — character.nut purge investigation

- **Purge-mistake signal: member-seed files.** `hooks/config/character.nut` is a `::Const.CharacterProperties.*` seed file — each `<-` line runs at load and backs every property clone. Purging it whole silently broke every kept consumer that read a seed. Pattern: when a purge commit touches a `*seed/defaults* .nut` (character.nut, world_assets.nut, sound.nut), grep kept hooks for the members it defined and verify each read has a surviving definition. The 4 `fix: restore ...` commits (45f1a0a4/299dea58/34c51fbd/3914ac50) prove this file was over-deleted.
- **Decision rule for upstream Vanilla-Fix carryover.** After the seed restores, diff the fork file vs upstream and triage remaining upstream pieces by consumption: restore iff a KEPT fork hook reads it; skip pure-accuracy Vanilla Fixes no fork code consumes. For character.nut, the 3 still-absent upstream pieces (`getVision`+`MinimumVision`, `getBravery`/`getInitiative` rounding) have NO fork consumer → leave out (no behavior required, no crash). Prevents cargo-culting balance-adjacent math onto a QoL-only fork.
- **`world_state.nut` was NOT a purge mistake.** Hooks intact + fork ADDED the `Math.minf` re-entrancy guard (upstream lacks it). Only correct removal: `HD_BountyHunterManager.onSerialize` (balance, already purged) — matches crash-on-save lesson (lessons.md:80).
- **Stale-test discrimination by file mtime, not just log.** de23a529 committed 12:13 but test-202608051434-log.html (14:34) still showed `HD_WasHitByEnemy does not exist` — confirm whether the tested zip was rebuilt post-commit by comparing zip path mtime vs log start time before treating a "still crashing" log as a real regression.
- **Reincorporation vs. gate-strip: don't restore a const to satisfy an unstripped feat.** `world_assets.nut` (d5f081f6) claimed "all other stripped symbols unused by fork" — but missed `HD_ReputationOnContractCancelAdvance`, which `contract.nut:23` (un-stripped cancel-renown-penalty Feat) + `tooltip_events.nut:354` still read. Triage (triage.md:131 = "strip renown-penalty feat") was never executed → latent crash on advance-pay contract cancel. Fix is STRIP the feat, not restore the const (restoring would re-import balance churn). Audit: for every upstream-only `HD_`/`Const` symbol, list ALL fork readers, then check each reader against triage verdict (KEEP vs GATE-strip); if a reader is a Feat meant to be stripped, strip reader + symbol together.
  2026-06-06: delete stale generic_item.nut stamina revert hook — actor.nut never reimplemented gear-weight stamina; revert only removed vanilla penalty.

## 2026-08-06 — v1.22.3 bump + Hardened incompatibility + release coherence

- **Battle Brothers mod install = drop the .zip into /data/ as-is (do not extract).** BB + MSU load zip mods directly; a `mod_hardened_qol_fork_1.22.3.zip` placed in `/data/` works, whereas "unzip into /data/" is wrong (and was corrected in the README). Lesson: never write install instructions you haven't verified against the engine's mod-loading convention.
- **Git tag must anchor a commit that reproduces the shipped release asset.** Version-bump + code + conflictWith edits must all be in the tagged commit; a tag whose `::Hardened.Version` says 1.22.2 while the release ships 1.22.3 makes bug reports un-reproducible. Bump + code + package together (cf. lessons.md:90).
- **Upstream micro-release triage = range-diff, then classify by AGENTS.md hook headers.** `1.22.3` = `isGarbage()` invert (FIX -> carry over: skill.nut onOtherSkillAdded); `HD_hide()` Reforged-contract shim (Feat/balance-adjacent, no fork consumer -> skip); version bump (hygiene -> carry over for tag↔asset coherence only). Rule restated: carry over iff a KEPT fork hook reads it; skip Reforged-contract/UI shims that exist to neutralize balance churn the fork already stripped.
- **Tag schema mirrors upstream version; patches suffix the base.** User rule: version-bump release tags with the bare upstream-mirror version (`1.22.4`); a patch on top of that base → `1.22.4-patch.1`. Old `v1.22.2-patch.N` prefix is retired. Initial mis-tagged `v1.22.2-patch.13` release was deleted and re-published at `1.22.4` (asset coherence kept: same commit `32b78068`).
- **Local tag namespace is flat — fork `1.22.4` replaces the upstream-fetched `1.22.4`.** After re-tagging, `git fetch upstream --tags` will re-point `1.22.4` at the upstream commit and silently orphan the release anchor. Fetch upstream with `--no-tags` (documented in `.agents/skills/build-release-process/SKILL.md`).
- **Declare cross-mod conflicts at the loader, not just in prose.** Added `mod_hardened` to `HooksMod.conflictWith` so MSU/Modern Hooks block loading both Hardened forks together; README Identity + Install now state it. Prose-only incompatibility notes are insufficient — users will still install both.

## 2026-08-09 — Dragonslayer easter-egg doc + AP-ladder rewrite

- **`Feat:` header is NOT a reliable balance signal on easter-egg files.** All 4 Dragonslayer actives + the item + the marketplace hook carry `Feat:` headers, but they are a PROTECTED content port (intentional easter egg), not balance churn. Any future purge pass must skip them - they are listed in AGENTS.md as KEEP. When a `Feat:` file history shows it was deliberately ADDED post-purge as an egg, treat as protected.
- **Easter-egg UI must stay coy.** MSU setting label is exactly "Easter Egg", never the item name; README credits the original creator by name (attribution) without describing mechanics. Rule: easter eggs get attribution, not documentation.
- **Condition-count ladder beats chained boolean ladders.** Old onAfterUpdate of the 4 actives was nested/combinatorial `if`s; rewrote to `local conditions` counter (each trait `conditions++`) + `if/else if` on count: 1 -> 0.78/6 AP, 2 -> 0.55/5, 3+ -> 0.33/4. Adding a 4th condition (Executioner background, `background.executioner`) was a 1-line change. Combinatorial booleans scale O(n^2); a counter scales O(n).
- **Verify discord message IDs byte-for-byte before quoting.** README attribution link first wrote `1150335987044122807`; correct is `1156335987044122807` (from msu_settings.nut). Copy IDs from source, do not retype.

## 2026-08-10 — v1.22.4-patch.3 (JS fix + clock removal)

- **Trailing comma in function parameter lists is ES2017 — Coherent GT (BB's JS engine) is ES5.** `world_combat_dialog.js` had `function (_title, ..., _classes, )` — trailing comma after last param caused SyntaxError at parse time, killing the entire JS hook file. Object literal trailing commas (ES5) are fine; function param trailing commas are not. Rule: never use trailing commas in function parameter definitions in BB JS hooks.
- **JS parse failure = silent feature death, not crash.** The SyntaxError at 09:22:54 didn't crash the game immediately — it just meant `WorldCombatDialog.prototype.show` velocity-stop override was dead. The crash came 24 minutes later when the exact scenario the override protected against (cancel + immediate re-show) triggered. The root cause was the JS file, but the symptom was a UI freeze.
- **Edit tool can report success without writing.** PowerShell file locks or encoding issues caused the Edit tool to claim "applied" while the file remained unchanged. Verify with `git diff` after every edit. Bash `Set-Content` as fallback.
- **Upstream feature removal = delete override files, restore vanilla.** When an upstream feature (world clock schedule) is overridden via `::Const.X <- {...}`, deleting the override file restores vanilla behavior. Grep for all consumers of the const before deletion — zero consumers in fork scripts means clean removal. Consumers in vanilla (e.g. `World.getTime().IsDaytime`) use the vanilla table automatically.
- **Build script uses git tag over bootstrap version.** `build.ps1` calls `git describe --tags --abbrev=0` and prefers the tag. If a stale tag exists (e.g. `1.22.4-patch.2` on an older commit), the zip gets the wrong name. Delete stale tags before rebuilding, or ensure the new tag is the only one on HEAD.

## 2026-08-17 — Upstream 1.22.5 integration (bug fixes + QoL only)

- **Upstream 1.22.5 is almost entirely QoL + API additions.** 19 commits since 1.22.1 base. Of these: 5 already ported (null guard, en garde, combat dialog, SkipContracts, hitchance hidden enemies, root_table simplification), 1 balance change (charm skill rework — skipped), 1 major feature (stat breakdown system — deferred), 1 API-only (HD_hide — no use case), 2 clean QoL (minus sign formatting, charm effect targeting).
- **Stat breakdown system deferred despite being strong QoL.** `HD_addPropertyBreakdown` + `SupportedBreakdowns` + `getBaseAttributesTooltip` rewrite = ~240 lines. Replaces our Fatigue-only tooltip override. Medium risk (large change, touches tooltip_events.nut deeply). Can be ported later as a separate integration.
- **Charm effect: adapted without the duration refactor.** Upstream uses custom `HD_LastsForTurns` counter replacing vanilla `TurnsLeft`. Fork keeps vanilla TurnsLeft (simpler, no balance coupling). Ported only `onAfterUpdate` (target attraction) and `getQueryTargetValueMult` (AI targeting). Skip `onTurnEnd` overwrite — it would disable vanilla duration expiry.
- **HD_getInitiativeModifierFromFatigue skipped.** Only used by upstream's `getInitiative` override (balance: fatigue-initiative formula) and stat breakdowns. Neither in scope for QoL-only fork.
- **Tag naming: upstream tag already fetched.** `git fetch upstream` brought `1.22.5` tag pointing at upstream commit. Force-moving tag to fork commit (`git tag -f 1.22.5`) is correct — `build.ps1` reads nearest tag via `git describe`.
- **`MSU.Text.color` hook for minus signs must come from a loaded file.** `text.nut` loads early via `mod_hardened_qol_fork/msu/` include. The hook wraps the existing `color` function; tactical tooltips use it, HTML tooltips use the xbbcode.js regex. Both sides needed.
