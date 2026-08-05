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
