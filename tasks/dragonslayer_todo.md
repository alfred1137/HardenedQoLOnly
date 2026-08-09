# Dragonslayer Easter-Egg — Execution Plan (QoL fork port)

Status: PLAN. Builder agent executes. All facts verified against local repo, vanilla sources, Reforged/Crock patterns. Open decisions flagged F1-F3 with defaults; apply defaults unless user overrides.

References: `tasks/dragonslayer_design.md` (decision cells = locked values), `doc/mod_guts_dragonslayer_v1.0.4/` (upstream source — read-only).

## Scope (locked)

**In:** item + 4 actives (renamed `hd_*`), marketplace stock injection, MSU toggle, gfx port, credit attribution.
**Out (per design decisions):** crafting blueprint (§5 — REMOVE), custom `legend_baffled` effect (§4 — REMOVE), parrying-dagger 0.2x damage branch (§3d — REMOVE), all Legends loot-table / spawning routes. Item obtainable **only** via shop.
**NOT goals:** no recipe of any kind, no `Const.Items.Named*` / `:MSU.Class.newItemScript` registration (would join loot tables → violates shop-only), no brushes, no Crock Pot code (checked: Crock's physician-mask pattern = `Const.Items.NamedHelmets.push` — inapplicable to shop-only; no CP dependency).

## Verified integration facts

| Fact               | Value                                                                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Settings pattern   | `local p = ::Hardened.Mod.ModSettings.addPage("...")` then `p.addBooleanSetting("ID", default, "Label", "Desc")`                                                   |
| Setting gate       | `if (::Hardened.Mod.ModSettings.getSetting("DragonslayerEasterEgg").getValue())`                                                                                   |
| Hook dir           | `hooks/entity/world/settlements/buildings/` exists (has `port_bulding.nut`)                                                                                        |
| Hook pattern       | `::Hardened.HooksMod.hook("scripts/<path>", function(q){ ... })`. Never `::Hooks.register`                                                                         |
| Standalone classes | any `.nut` under mod zipped `scripts/` auto-loads — `::new("scripts/items/weapons/hd_dragonslayer")` works, no include needed (fork precedent: `hd_retreat_skill`) |
| Stock `S` path     | `fillStash`/settlement resolve `::new("scripts/items/" + S)` → `S` relative to `scripts/items/`                                                                    |
| Shop add           | `building.m.Stash.add(item)` — persists for current shop dialog; owner sets own price via `m.Value`                                                                |
| gfx (fork)         | `gfx/` root has `skills/` + `ui/`; weapon icons at `gfx/ui/items/weapons/melee/`                                                                                   |

## Deliverables

1. `scripts/items/weapons/hd_dragonslayer.nut` (new)
2. `scripts/skills/actives/hd_guillotine_strike.nut`, `hd_steel_crescent.nut`, `hd_decimate.nut`, `hd_demolish_shield.nut` (new, 4)
3. `hooks/entity/world/settlements/buildings/marketplace_building.nut` (new)
4. `gfx/` copies (3 pngs)
5. `mod_hardened_qol_fork/msu/msu_settings.nut` (edit — add one page + one boolean)

Do NOT create: blueprint, effect file, brush, reforged/ edits.

## Step 1 — Item: `scripts/items/weapons/hd_dragonslayer.nut`

Copy `doc/mod_guts_dragonslayer_v1.0.4/scripts/items/weapons/dragon_slayer.nut`. Apply locked values:

| Field                                                             | Orig                                    | Final                                                                                                                           |
| ----------------------------------------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `m.ID`                                                            | `weapon.dragon_slayer`                  | `weapon.hd_dragonslayer`                                                                                                        |
| `m.Name`                                                          | `Dragon Slayer`                         | keep                                                                                                                            |
| `m.Description`                                                   | iconic text                             | keep verbatim incl `Huge`, `Strong`                                                                                             |
| `m.IconLarge`                                                     | `weapons/melee/dragon_slayer.png`       | `weapons/melee/dragon_slayer.png` (path of ported file below) — see GFX step                                                    |
| `m.Icon`                                                          | `weapons/melee/dragon_slayer_70x70.png` | ported name                                                                                                                     |
| `m.WeaponType`                                                    | `Sword`                                 | keep                                                                                                                            |
| `m.WieldType`                                                     | —                                       | 2H Mainhand/Blocked Offhand (two within spec)                                                                                   |
| `m.ItemType`                                                      | `Weapon\|MeleeWeapon`                   | + `TwoHanded`                                                                                                                   |
| `m.IsAgainstShields` `m.IsAoE` `m.AddGenericSkill` `m.ShowQuiver` | all true/false                          | keep                                                                                                                            |
| `m.ShowArmamentIcon` / `m.ArmamentIcon`                           | true / `icon_dragon_slayer`             | keep `icon_dragon_slayer` (tie to male GFX step — do not rename armament ref; the original ships `gfx/icons_dragon_slayer.png`) |
| `m.Value`                                                         | 4200                                    | **5600**                                                                                                                        |
| `m.ShieldDamage`                                                  | 96                                      | keep                                                                                                                            |
| `m.ConditionMax`                                                  | 220                                     | **120**                                                                                                                         |
| `m.StaminaModifier`                                               | -40                                     | **-25**                                                                                                                         |
| `m.RegularDamage`                                                 | 140 / 160                               | **100 / 120** + per-instance roll `Math.rand(-5, 5)` added to both                                                              |
| `m.ArmorDamageMult`                                               | 1.5                                     | keep                                                                                                                            |
| `m.DirectDamageMult`                                              | 0.4                                     | keep                                                                                                                            |
| `m.FatigueOnSkillUse`                                             | 30                                      | **5**                                                                                                                           |
| `onEquip`                                                         | 4 skills                                | same, renamed paths                                                                                                             |

Roll implementation: after `weapon.create()`:

```squirrel
local roll = this.Math.rand(-5, 5);
this.m.RegularDamage += roll;
this.m.RegularDamageMax += roll;
```

**F1 (apply default):** inherit `scripts/items/weapons/weapon` (original), NOT Reforged `named_weapon`. Rationale: design doc's "show in named table" + locked shop-only are mutually exclusive (named class auto-joins `NamedMeleeWeapons` → champion loot possible). Shop injection needs only a plain weapon. If user insists on `named_weapon`, do not register/join any table.

Icon file paths: ported files keep the _original filenames_ (`dragon_slayer.png` / `dragon_slayer_70x70.png`) under new hd dir — see GFX step for exact naming; item's `m.Icon*` must match.

## Step 2 — Actives (4 files, copy + rename)

All inherit `scripts/skills/skill`. Rename table:

| Orig file         | New file                   | `m.ID`                         | Required edits                         |
| ----------------- | -------------------------- | ------------------------------ | -------------------------------------- |
| `DS_split`        | `hd_guillotine_strike.nut` | `actives.hd_guillotine_strike` | baffled → stagger (below)              |
| `DS_shatter`      | `hd_steel_crescent.nut`    | `actives.hd_steel_crescent`    | none (already vanilla stagger)         |
| `DS_round_swing`  | `hd_decimate.nut`          | `actives.hd_decimate`          | none                                   |
| `DS_split_shield` | `hd_demolish_shield.nut`   | `actives.hd_demolish_shield`   | parrying-dagger branch removal (below) |

Rename mechanics: `m.ID`, class name, `onAnySkillUsed` `_skill == this` comparisons (identity check on ID — adjust `m.ID` only), `m.Icon`/`IconDisabled`/`Overlay`/sounds keep ORIGINAL vanilla refs (icons `active_06`.., sounds `sounds/combat/...` — vanilla-exist; verify icon paths exist in `gfx/ui/skills/`). `m.Name`/`m.Description` keep from original (they mention "counter-clockwise", "Huge", "Strong", "Sword Mastery" — all vanilla traits).

### F2a — hd_guillotine_strike: baffled → stagger

- Delete `:new("scripts/skills/effects/legend_baffled_effect")`, `hasSkill("effects.legend_baffled")` checks.
- `applyEffectToTarget` => copy pattern from `DS_shatter`: `Math.rand(1,2)==1 → add "scripts/skills/effects/staggered_effect"` + conditional EventLog.
- Description line "may get baffled" → "may get staggered".

### F2b — hd_demolish_shield: remove parrying-dagger branch

- Delete the `...(getID() == "weapon.parrying_dagger" | "weapon.named_parrying_dagger")` damage×0.2 block.
- Keep: `IsUsingHitchance = false`, onVerifyTarget armed-with-shield, stagger on hit, stun + `stunned_effect` when shield broken.

## Step 3 — Marketplace hook: `hooks/entity/world/settlements/buildings/marketplace_building.nut`

```squirrel
// Feat: Dragonslayer easter egg — marketplace stock (gated by MSU setting)
// Mimics Crock_Pot's cp_marketplace pattern: extend getDefaultShopList with {R, P, S} entries.

::Hardened.HooksMod.hook("scripts/entity/world/settlements/buildings/marketplace_building", function(q) {
	q.getDefaultShopList = @(__original) function()
	{
		local list = __original();
		if (::Hardened.Mod.ModSettings.getSetting("DragonslayerEasterEgg").getValue())
		{
			// Exotic import: extremely rare (R=99.5 ~0.5% per refresh) and overpriced (P=1.5)
			list.push({
				R = 99.5,
				P = 1.5,
				S = "weapons/hd_dragonslayer"
			});
		}
		return list;
	}
});
```

Notes:

- Hook via `::Hardened.HooksMod.hook`, queued from default `hooks/` bucket — no extra registration needed.
- `hook()` single rule — no `hookTree()` (single script).
- Mimics Crock_Pot: `getDefaultShopList` override, `S` relative to `scripts/items/`, exotic-import entry `R=99.5 P=1.5`.
- Marketplace exists in every town → egg reachable anywhere. Weaponsmith variant rejected (user).

## Step 4 — MSU setting (edit `msu/msu_settings.nut`, append)

```squirrel
// Easter Egg settings
{
	local eggPage = ::Hardened.Mod.ModSettings.addPage("Easter Egg (QoL)");
	eggPage.addBooleanSetting("DragonslayerEasterEgg", false,
		"Easter Egg",
		"Enables access to a hidden easter egg. Item has no crafting recipe. Original creator: Koltira, a Scaly Grumpiness — first posted on the Legends Submod Discord (https://discord.com/channels/547043336465154049/1156335987044122807)."
	);
}
```

- UI label MUST be exactly "Easter Egg" — never the item name (design requirement).
- Wait for `DragonslayerEasterEgg`+`getValue()` read at shop refresh — no callback needed.

## Step 5 — GFX (port 3 binary pngs)

Source: `doc/mod_guts_dragonslayer_v1.0.4/gfx/`.

| Source                                           | Destination (fork `gfx/`)                                                                                             |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| `icons_dragon_slayer.png`                        | `gfx/icons_dragon_slayer.png` (root — matches original layout; `m.ArmamentIcon = "icon_dragon_slayer"` pairs with it) |
| `ui/items/weapons/melee/dragon_slayer.png`       | `gfx/ui/items/weapons/melee/dragon_slayer.png`                                                                        |
| `ui/items/weapons/melee/dragon_slayer_70x70.png` | `gfx/ui/items/weapons/melee/dragon_slayer_70x70.png`                                                                  |

Names/values: keep ORIGINAL filenames + icon strings (no rename) → minimal risk, item icon string unwedged. `gfx/*.png` is gitignored but `build.ps1` packages `gfx/` regardless — verify in Step 7.

Why no `hd_` rename: icon paths are referenced in the item `m.Icon`/`m.IconLarge` directly; keeping original names avoids the `icon_dragon_slayer` vs `icons_dragon_slayer` mismatch (original ships singular-value icon although file plural). Zero-mismatch = keep both as-is.

## Verification (builder MUST run)

1. `git status` sanity: expected additions — 5 `.nut` (item + 4 actives) + 1 hook + 3 pngs + 1 edited settings file.
2. `rg -i "legend|DS_"` over new files → zero hits.
3. `pwsh ./build.ps1` → clean zip `mod_hardened_qol_fork_<ver>.zip`.
4. Unzip verify: `scripts/items/weapons/hd_dragonslayer.nut` + 4 actives + hook present; pngs present.
5. Runtime smoke (manual for user): OFF → marketplace shows nothing; ON → visit marketplace, ~0.5% per refresh = item in stock; equip → 4 actives; demolish shield stuns (ShieldDamage 48); armament icon visible.
6. No `*.log` errors in game log related to the item/hook.

## Open decisions (defaults applied if no override)

- **F1** item base: `weapon` (plain) — shop-only; named_weapon only via user veto w/ no-table registration.
- **F2** shop rate: 15%.
- **F3** armament/icon naming: keep original names (not `hd_`).

## Out of scope (explicit)

No blueprint/recipe/ingredients, no effect class, no brushes, no Crock integration, no loot table pushes, no Reforged base edits, no UI (inventory/skills show vanilla icons only).
