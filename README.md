# Hardened QoL Fork

A **quality-of-life-only fork** of [Hardened](https://github.com/Darxo/Hardened), a submod for the Battle Brothers overhaul mod **Reforged**.

This fork strips Hardened's balance and mechanic overhauls — the Reforged perk/mechanic reworks and Hardened's world/contract/faction scaling subsystem — and keeps only the **QoL improvements and bug fixes**. It is intended to sit on top of Reforged and add convenience without changing the game's balance.

## Identity

- Mod ID: **`mod_hardened_qol_fork`** — **incompatible with and must not be loaded alongside the original Hardened** (`mod_hardened`). Both are declared as conflicting mods, so MSU / Modern Hooks will block the game from loading them together; disable one before enabling the other.
- Tracks upstream Hardened `develop` (base release `1.22.0`; incorporates upstream `1.22.4` bug fixes)
- Requires: **MSU**, **Reforged >= 0.9.0**, **Dynamic Spawns >= 0.5.0**
- Incompatible: the original **Hardened** (`mod_hardened`) — MSU / Modern Hooks block loading both; disable one before enabling the other.

## Attribution \& Support

This fork builds on the success of [Hardened](https://github.com/Darxo/Hardened) and upstream's continuing maintenance. Credit for the underlying ideas and bug fixes belongs to the upstream author (Darxo); this fork repackages their QoL and bug-fix work without the balance/mechanic overhauls. We incorporated upstream fixes through release `1.22.4`.

This fork is provided **as-is**: we make **no commitment** to maintaining it. Upstream may move on, and this fork may fall behind, diverge, or be abandoned without notice. Install and use at your
own discretion.

### Easter egg

The hidden option named "Easter Egg" in MSU settings unlocks a special weapon port of a fan-made Legends submod content. That item and its abilities were created by **Koltira, a Scaly Grumpiness**, first posted on the [Legends Submod Discord](https://discord.com/channels/547043336465154049/1156335987044122807). This fork carries the port as an easter egg out of respect for the original work; it is off by default and not affiliated with the original author.

## What was removed

- Reforged perk reworks and new perks (e.g. Reach rework, Double Grip rework, Crowded, new/renamed perks)
- Hardened's world/contract/faction difficulty scaling (`::Hardened.Global` scalars) — reverts to base Reforged scaling
- Economy/price reworks (buy/sell price multipliers, buyback, drop-condition changes)
- Stamina/Initiative/Weight rework (stamina minimum, weight-after-multiplier)
- Item/weapon/armor/helmet/shield stat rebalances
- NPC/agent/trait reworks
- Reforged reach rework (`rf_reach`) — reverts to Reforged's own reach

## What is kept (QoL + fixes)

- **Hitchance overlay** + auto camera level on skill/movement preview
- **Ammo/reload wiring** (no-ammo warning, reload disorientation, crossbow/firearm load state)
- **Retreat skill** for individual brothers (`hd_retreat_skill`)
- **Arena collar** accessory restore after arena contracts
- **XP display rework** (per-level progress instead of cumulative)
- **Food/repair/medicine** remaining-duration indicators on the world map
- **Situation-effect tooltips** (what a settlement situation actually does)
- **Faction relation change log** + relation-price tooltip
- **Party/location label** readability (background alpha, caravan banner offset)
- **AI intent flags** (fleeing/attacking) on world parties
- **Miniboss skull** socket on world parties
- **Camp banner** display while camping
- **Day-range tooltips** (town day ranges via Reforged text)
- **Weapon tooltip** improvements (ammo, reach, armor damage accuracy)
- **Broken-weapon** log/sound + no weapon-drop on break
- **Perk stack count** display (Fast Adaptation)
- **Mastery icon fixes** (Anticipation icon bug on Cleaver/Throwing mastery)
- **Hidden easter egg** — optional, disabled by default (toggle "Easter Egg" in MSU settings); see Attribution.
- Dozens of **Vanilla Fixes** (e.g. `onEquip` crossbow crash, `getHitpointsMax` rounding, `setDirty` TurnSequenceBar null check, drum double-grip, lightbringer tooltip, obsidian dagger reanimation draw)

## Install

1. Install **MSU**, **Reforged**, and **Dynamic Spawns** (plus all of their own dependencies).
2. **Disable/remove the original Hardened (`mod_hardened`)** if present — this fork conflicts with it, and MSU will refuse to load both at once.
3. Drop `mod_hardened_qol_fork_<version>.zip` **as-is** (do not extract) into `<Battle Brothers>/data/`.
4. Enable the mod in the launcher.

## Build

Run `pwsh ./build.ps1` from the repo root to produce `mod_hardened_qol_fork_<version>.zip`.

## Documentation

- `tasks/triage.md` — full KEEP/GATE/DELETE inventory of the transformation
- `tasks/todo.md` — transformation status
- `tasks/lessons.md` — session lessons
- `mod_hardened_qol_fork/documentation.txt` — mod-internal API vs non-API split, known issues
