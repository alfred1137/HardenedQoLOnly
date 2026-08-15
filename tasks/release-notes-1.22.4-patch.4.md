# v1.22.4-patch.4

Fork-local fixes (not upstream).

## Changes

- **Fix: native stack overflow during combat** — removed `actor.setDirty(true)` from `onUpdate` in three injury hooks (`collapsed_lung_part`, `crushed_windpipe`, `pierced_lung`). The call recursed through URUI → Reforged nimble perk → MaJin RCE update loop (198× native stack overflow). Upstream Hardened carries the same latent bug; fix is fork-local for now.
- **Fix: UI hook loading failure (JS SyntaxError)** — removed two trailing commas in function-call arguments in `world_combat_dialog.js` (the in-game JS engine is ES5-era CEF and rejects them; Node tolerates them). This silently disabled all Hardened combat-dialog QoL hooks.
- **Fix: MSU startup warning about `onUse` parameter count** — the `_targetTile` parameter of the `onUse` hookTree wrapper is now optional (`= null`), matching MaJin RCE 2.7.1's own signature conversion for one-parameter vanilla skills. Runtime behavior unchanged (Squirrel fills missing args with `null` either way); log noise gone.
- Version `1.22.4-patch.3` → `1.22.4-patch.4`.

## Verified

- Zero Script Errors, zero JS errors, zero Unknown Brush warnings in user test log (`tasks/test-202608151710-log.html`); campaign loads clean.
