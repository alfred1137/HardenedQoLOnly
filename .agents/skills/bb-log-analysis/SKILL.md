---
name: bb-log-analysis
description: Battle Brothers game log analysis for mod testing. Parse HTML log files (tasks/test-*-log.html) from the Hardened QoL Fork codespace. Extract ScriptErrors, stacktraces, Unknown Brush warnings, distinct error messages. Use when user drops a test log or reports a crash/error from a game session. Triggers: "check log", "err_stacks", "test-*-log.html", "script error", "critical error".
---

# BB Log Analysis

Analyze Battle Brothers HTML logs from the HardenedQoLOnly codespace. Logs land in `tasks/test-<timestamp>-log.html` (user drops them after game sessions). Logs are big single-line HTML; naive regex over whole string is slow — use chunked StreamReader scripts.

## Workflow

1. **Locate log**: newest `tasks/test-*.log.html` (glob `tasks/test-*.html`).
2. **Extract error stacks** (primary):
   ```powershell
   & ".agents\skills\bb-log-analysis\scripts\err_stacks.ps1" -Path <log>
   ```
   Prints distinct error messages + first stacktrace each. Empty output = 0 ScriptErrors.
3. **Extract just messages** (count flood):
   ```powershell
   & ".agents\skills\bb-log-analysis\scripts\err_msgs.ps1" -Path <log>
   ```
4. **Extract full stacks** (verbose, for root-cause walk):
   ```powershell
   & ".agents\skills\bb-log-analysis\scripts\distinct_errors.ps1" -Path <log>
   ```

## Classification

- `Script Error` row → real bug. Root cause = Squirrel exception; walk stacktrace top frame (fork file:line first).
- `SceneManager Unknown Brush requested: X` → missing brush asset OR unregistered sprite id.
- `Invalid match` / `Invalid sub matches` → MSU regex warnings on colorized text (sling cover-diversion, damage lines). Cosmetic, NOT bugs.
- `IO Unable to open file` (banner__.png, Arsenal-_.ttf) → external mod assets (MaJin, MSU fonts). Not fork.

## Hardened fork-specific triage rules

- `the index 'HD_X' does not exist` at `mod_hardened_qol_fork/...` = purge-over-delete: kept hook reads upstream-only seed (const/member/brush) deleted during balance strip. Restore seed with vanilla-equivalent value where upstream value is balance churn. See `tasks/lessons.md` 2026-08-05 section.
- Crash in `onDamageReceived`/`onDamageReceived` chain → check `HD_FatalityType`, `HD_WasHitByEnemy`, `HD_DealtHitToEnemy` first.
- Tooltip crash → `getHeadHitchance` / `getHitchance` override / `HD_InventoryUpgradeSlots`.
- `Unknown Brush hd_bleeding_mini_*` → compiled `brushes/mod_hardened.brush` + `gfx/mod_hardened.png` atlas must ship in zip (NOT unpacked_brushes source).

## Verification

- After fix: rebuild `pwsh ./build.ps1`, verify zip contents (brushes/, gfx/mod_hardened.png), tag `v1.22.2-patch.N` (version stays upstream-aligned `1.22.2`), publish via gh. User re-tests, drops new log.
- Check stale-test risk: compare log start timestamp vs zip build time before declaring a fix broken.
