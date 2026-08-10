# v1.22.4-patch.1

Fork-local fix (not upstream).

## Changes

- **Dropped in patch.3**: upstream Hardened world clock schedule (sunrise/morning/midday/afternoon labels, ambient lighting override, DayTime concept tooltip). Restored vanilla clock behavior — the Hardened schedule adds no meaningful QoL and was out of phase.

## Original (now reverted)

- **Fix: in-game clock period labels read phase-shifted** (night → "afternoon", dawn → "midday", morning → "sunset"). Upstream Hardened ships `Const.Strings.World.TimeOfDay` (12 entries) and `Const.World.TimeOfDay` index constants rotated a half step behind the `floor(Hours / 2)` bucket mapping, so the 2-hour period label at each bucket was wrong.
  - `mod_hardened_qol_fork/hooks/config/strings/strings.nut` — rotated label array to the Hardened schedule: Sunrise 0-1, Morning 2-7, Midday 8-9, Afternoon 10-15, Sunset 16-17, Dusk 18-19, Midnight 20-21, Dawn 22-23.
  - `mod_hardened_qol_fork/hooks/config/world.nut` (new) — repointed `Const.World.TimeOfDay` indices (`Sunrise=0, Dusk=9, Midnight=10, Dawn=11`) so `isDay/isNight` night buckets (18-23) match the corrected labels.
