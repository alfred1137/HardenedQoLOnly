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
