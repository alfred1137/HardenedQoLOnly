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
