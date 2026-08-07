# v1.22.4 (tag v1.22.2-patch.13)

Upstream-aligned bump. Incorporates upstream **1.22.4** bug fixes.

## Changes

- **Vanilla Fix:** World map no longer goes invisible (UI freeze) when cancelling a combat dialog and getting attacked immediately after. Ported from upstream `5522495f` (`world_combat_dialog.nut` + `.js` velocity cleanup).
- Version bump `1.22.3` → `1.22.4` (build output `mod_hardened_qol_fork_1.22.4.zip`).

## Not ported from 1.22.4

- Reforged contract-setting hide (`HD_hide("Disabled")`) — no fork consumer; contracts/scaling stripped.
- Tooltip wording change ("an enemy" → "anyones") — upstream grammar regression, kept fork wording.
