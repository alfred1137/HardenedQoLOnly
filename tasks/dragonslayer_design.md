# Dragonslayer Easter-Egg — Design Spec (QoL fork port, NO Legends)

Status: SPEC — EDIT THIS. Every original Dragonslayer value is shown. Propose changes inline.
Fork namespace: `HD\\\_DragonSlayer` (prefix for new classes/symbols).
Easter-egg plan: MSU setting `DragonslayerEasterEgg` (default OFF) gates a hidden blueprint → no item spawn until toggled. UI should only read "Easter Egg" and not mention the actual item. It should credit original creator of the item "Koltira, a Scaly Grumpiness" who first posted it on Legends Submod Discord at `https://discord.com/channels/547043336465154049/1156335987044122807`.

## 0\. Source files reviewed (local)

`doc/mod\\\_guts\\\_dragonslayer\\\_v1.0.4/scripts/`:

* `items/weapons/dragon\\\_slayer.nut`
* `crafting/blueprints/dragon\\\_slayer\\\_blueprint.nut`
* `skills/actives/DS\\\_split.nut`, `DS\\\_shatter.nut`, `DS\\\_round\\\_swing.nut`, `DS\\\_split\\\_shield.nut`
GFX: `doc/mod\\\_guts\\\_dragonslayer\\\_v1.0.4/gfx/` (check subpaths before port).

## 1\. Legend-to-vanilla dependency map (HARD BLOCKERS — must substitute)

Dragonslayer currently imports these Legends symbols. Fork has none.

|Dragonslayer symbol|Type|Fork substitution|Decision|
|-|-|-|-|
|`effects.legend\\\_baffled` (check)|Legends effect|custom `effects.hd\\\_dragonslayer\\\_baffled` (§4)|do not include a baffled effect|
|`scripts/skills/effects/legend\\\_baffled\\\_effect`|Legends effect class|custom `hd\\\_dragonslayer\\\_baffled\\\_effect.nut`|do not include a baffled effect|
|`scripts/skills/effects/staggered\\\_effect`|vanilla|**reuse directly** (vanilla, confirmed)|KEEP vanilla|
|`weapon.legend\\\_parrying\\\_dagger`|Legends weapon|vanilla `weapon.parrying\\\_dagger`|\[SUB vanilla]|
|`shield.legend\\\_named\\\_parrying\\\_dagger`|Legends shield|vanilla `weapon.named\\\_parrying\\\_dagger`|\[SUB vanilla]|
|`scripts/items/trade/legend\\\_iron\\\_ingots\\\_item` (×8)|Legends trade|substitute (§5)|remove crafting recipe, shop only|
|`scripts/items/misc/legend\\\_demon\\\_alp\\\_skin\\\_item` (×2)|Legends misc|substitute (§5)|remove crafting recipe, shop only|
|`scripts/items/misc/legend\\\_stollwurm\\\_blood\\\_item` (×1)|Legends misc|substitute (§5)|remove crafting recipe, shop only|
|`scripts/items/misc/legend\\\_ancient\\\_green\\\_wood\\\_item` (×1)|Legends misc|substitute (§5)|remove crafting recipe, shop only|
|`scripts/skills/backgrounds/legend\\\_blacksmith\\\_background`|Legends bg|relax (§5)|remove crafting recipe, shop only|

## 2\. Weapon class — `scripts/items/weapons/named/hd\\\_dragonslayer.nut`

(Port from `dragon\\\_slayer.nut`. Inherit Reforged `named\\\_weapon` + `BaseItemScript` so it shows in named-weapon table.)

|Field|Dragonslayer (orig)|Fork proposal|Decision|
|-|-|-|-|
|`m.ID`|`weapon.dragon\\\_slayer`|`weapon.hd\\\_dragonslayer`|as proposed|
|`m.Name`|`Dragon Slayer`|`Dragon Slayer`|as proposed|
|`m.Description`|"It's too big to be called a sword. Massive, thick, heavy, and far too rough. Indeed, it's a heap of raw iron.\\nOne must be particularly Huge and Strong to wield this weapon."|same|as proposed: keep original|
|Icon (large)|`weapons/melee/dragon\\\_slayer.png`|`gfx/ui/items/weapons/melee/hd\\\_dragonslayer.png`|as proposed|
|Icon (70x70)|`weapons/melee/dragon\\\_slayer\\\_70x70.png`|`gfx/ui/items/weapons/melee/hd\\\_dragonslayer\\\_70x70.png`|as proposed|
|`m.WeaponType`|`Sword`|`Sword`|as proposed|
|`m.SlotType` / `BlockedSlotType`|Mainhand / Offhand|Mainhand / Offhand (2H)|as proposed|
|`m.ItemType`|`Weapon|MeleeWeapon|as proposed, TwoHanded`|
|`m.IsAgainstShields`|true|true|as proposed|
|`m.IsAoE`|true|true|as proposed|
|`m.AddGenericSkill`|true|true|as proposed|
|`m.ArmamentIcon`|`icon\\\_dragon\\\_slayer`|`icon\\\_hd\\\_dragonslayer`|as proposed|
|`m.Value`|4200|4200 (or raise, named-tier)|5600|
|`m.ShieldDamage`|96|96 (Demolish Shield uses this)|as proposed|
|`m.ConditionMax`|220.0|220.0|120|
|`m.StaminaModifier`|-40|-40|-25|
|`m.RegularDamage` (min/max)|140 / 160|140 / 160 (± roll 1..20)|100 / 120  (± roll 5)|
|`m.ArmorDamageMult`|1.5|1.5|as proposed|
|`m.DirectDamageMult`|0.4|0.4|as proposed|
|`m.FatigueOnSkillUse`|30|30|5|
|`onEquip` skills|DS\_split, DS\_shatter, DS\_round\_swing, DS\_split\_shield (4 actives)|keep all 4 (renamed `HD\\\_\\\*`)|as proposed|

## 3\. Active skills (port each from `DS\\\_\\\*` → `HD\\\_\\\*` under `scripts/skills/actives/`)

All inherit vanilla `scripts/skills/skill`. Cost-scaling identical across all 4 (Huge/Strong/Sword-Spec): `FatigueCostMult` 0.78 / 0.55 / 0.33 and AP 8 / 7 / 6.

### 3a. `HD\\\_split` — "Guillotine Strike" (DS\_split)

|Prop|Dragonslayer (orig)|Decision|
|-|-|-|
|`m.ID`|`actives.DS\\\_split`|`actives.hd\\\_guerillotine\\\_strike`|
|Name / KilledString|Guillotine Strike / "Split in two"|Keep|
|HitChanceBonus (onAnySkillUsed)|`MeleeSkill -= 5`|Keep|
|DamageTooltipMult (onAnySkillUsed)|Min×1.5, Max×1.5|Keep|
|DirectDamageMult|0.4|Keep|
|AP / Fatigue|9 / 30 base|Keep|
|Range|1–1|Keep|
|ChanceDecap / Disembowl / Smash|99 / 75 / 0|Keep|
|Targets|up to 2 (line)|Keep|
|**Legend dep**|`legend\\\_baffled\\\_effect` + checks `effects.legend\\\_baffled`|apply vanilla stagger instead of baffled|
|Extra body-part hit|hits opposite body part at 50% dmg|Keep|

### 3b. `HD\\\_shatter` — "Steel Crescent" (DS\_shatter)

|Prop|Dragonslayer (orig)|Decision|
|-|-|-|
|`m.ID`|`actives.DS\\\_shatter`|`actives.hd\\\_steel\\\_crescent`|
|Name / KilledString|Steel Crescent / "Crushed"|Keep|
|HitChanceBonus|`MeleeSkill -= 10`|Keep|
|DirectDamageMult|0.4|Keep|
|AP / Fatigue|9 / 30 base|Keep|
|Proc|50% chance → `staggered\\\_effect` (vanilla) on hit|KEEP vanilla stagger|
|Targets|up to 3 (arc, CCW)|Keep|
|ChanceDecap / Disembowl / Smash|99 / 70 / 0|Keep|

### 3c. `HD\\\_round\\\_swing` — "Decimate" (DS\_round\_swing)

|Prop|Dragonslayer (orig)|Decision|
|-|-|-|
|`m.ID`|`actives.DS\\\_round\\\_swing`|`actives.hd\\\_decimate`|
|HitChanceBonus|`MeleeSkill -= 15`|Keep|
|DirectDamageMult|0.4|Keep|
|AP / Fatigue|9 / 35 base|Keep|
|Targets|up to 6 (all adjacent)|Keep|
|ChanceDecap / Disembowl / Smash|99 / 75 / 0|Keep|

### 3d. `HD\\\_split\\\_shield` — "Demolish Shield" (DS\_split\_shield)

|Prop|Dragonslayer (orig)|Decision|
|-|-|-|
|`m.ID`|`actives.DS\\\_split\\\_shield`|`actives.hd\\\_demolish\\\_shield`|
|AP / Fatigue|9 / 15 base|Keep|
|`m.IsUsingHitchance`|false (always hits)|Keep|
|`onVerifyTarget`|requires `isArmedWithShield()`|Keep|
|ShieldDamage|`weapon.getShieldDamage()` (96)|Keep|
|**Legend dep**|reduces dmg ×0.2 if target holds `weapon.legend\\\_parrying\\\_dagger` or `shield.legend\\\_named\\\_parrying\\\_dagger`|remove|
|Stagger|always adds `staggered\\\_effect` (vanilla)|Keep|
|Stun|if shield broken → adds `stunned\\\_effect` (vanilla)|Keep|

## 4\. Custom effect — replace `legend\\\_baffled\\\_effect`

`scripts/skills/effects/hd\\\_dragonslayer\\\_baffled\\\_effect.nut` — standalone class (autoload). Original Legends `baffled\\\_effect` = reduced damage + stagger window. Since vanilla `staggered\\\_effect` already covers Initiative debuff, propose:

|Prop|Proposed|Decision|
|-|-|-|
|Extends|`scripts/skills/effects/stagger` (vanilla base) OR standalone effect|REMOVE|
|`m.ID`|`effects.hd\\\_dragonslayer\\\_baffled`|REMOVE|
|Name / Icon|"Baffled" / `effects/stagger.png` (reuse icon)|REMOVE|
|Effect|-25% dmg dealt by target for 1 turn + `staggered\\\_effect` applied|REMOVE|
|Duration|1 turn (Legends baffled = 1 turn)|REMOVE|

## 5\. Crafting recipe — `scripts/crafting/blueprints/hd\\\_dragonslayer\\\_recipe.nut`

Port from `dragon\\\_slayer\\\_blueprint.nut`.

|Field|Dragonslayer (orig)|Fork proposal|Decision|
|-|-|-|-|
|`m.ID`|`blueprint.dragon\\\_slayer\\\_blueprint`|`crafting.hd\\\_dragonslayer\\\_blueprint` \[TODO]|REMOVE - available at shop instead|
|`m.Type`|`Weapon`|`Weapon`|REMOVE|
|`m.PreviewCraftable`|dragon\_slayer|hd\_dragonslayer|REMOVE|
|`m.Cost`|4000|4000 (or tune for QoL/easter-egg)|REMOVE|
|Ingredient 1|`scripts/items/trade/legend\\\_iron\\\_ingots\\\_item` ×8|substitute below|REMOVE|
|Ingredient 2|`scripts/items/misc/legend\\\_demon\\\_alp\\\_skin\\\_item` ×2|substitute below|REMOVE|
|Ingredient 3|`scripts/items/misc/legend\\\_stollwurm\\\_blood\\\_item` ×1|substitute below|REMOVE|
|Ingredient 4|`scripts/items/misc/sulfurous\\\_rocks\\\_item` ×10|`sulfurous\\\_rocks\\\_item` ×10 (Vanilla, confirmed `misc.sulfurous\\\_rock`, Value 2000)|REMOVE|
|Ingredient 5|`scripts/items/misc/legend\\\_ancient\\\_green\\\_wood\\\_item` ×1|substitute below|REMOVE|
|Background req|`scripts/skills/backgrounds/legend\\\_blacksmith\\\_background`|NONE ▢ / Anatomist ▢ / rf\_old\_swordmaster ▢ / rf\_renowned\_swordmaster ▢|REMOVE|
|Station|(vanilla crafting screen)|vanilla crafting screen ▢ / Reforged armory ▢|REMOVE|

### Ingredient substitution candidates (from locally-confirmed existence)

Confirmed-vanilla / Reforged craft materials available as substitutes:

* `misc.sulfurous\\\_rock` (vanilla) — KEPT.
* `misc.petrified\\\_scream` (vanilla) — Reforged grave\_chill\_bomb recipe uses it (safe).
* `misc.glistening\\\_scale` (vanilla) — same, safe.
* `misc.lindwurm\\\_blood` / `misc.lindwurm\\\_scales` (vanilla beast part).
* `misc.kraken\\\_tentacle` / `misc.kraken\\\_horn\\\_plate` (vanilla).
* `rf.hollenhund\\\_bones` / `rf.geist\\\_tear` (Reforged loot).

Proposed default set:

|Legends original (qty)|Proposed substitute|
|-|-|
|legend\_iron\_ingots ×8|`misc.glistening\\\_scale` ×5 ▢ / `rf.hollenhund\\\_bones` ×3 ▢ / REMOVE recipe|
|legend\_demon\_alp\_skin ×2|`misc.petrified\\\_scream` ×1 ▢ / `misc.lindwurm\\\_blood` ×1 ▢ / REMOVE recipe|
|legend\_stollwurm\_blood ×1|`misc.lindwurm\\\_blood` ×1 ▢ / `misc.kraken\\\_tentacle` ×1 ▢ / REMOVE recipe|
|legend\_ancient\_green\_wood ×1|`misc.ancient\\\_wood` ×1 ▢ / `misc.glowing\\\_resin` ×1 ▢ / REMOVE recipe|

## 6\. MSU toggle (edit existing)

`mod\\\_hardened\\\_qol\\\_fork/msu/msu\\\_settings.nut` — add:

```
addBooleanSetting("DragonslayerEasterEgg", false, "Dragonslayer Recipe",
  "Unlock a hidden Dragonslayer crafting recipe (see tasks/dragonslayer\\\_design.md). Off by default.")
```

Recipe class checks this setting at `create()`; if false → registers no blueprint (truly hidden = easter egg).

## 7\. GFX / brush checklist

Original gfx paths (port + rename to `hd\\\_dragonslayer`):

* Weapon icon (inventory): `weapons/melee/dragon\\\_slayer.png`, `dragon\\\_slayer\\\_70x70.png`
* Armament icon sprite: `icon\\\_dragon\\\_slayer` → need `gfx/ui/items/weapons/melee/hd\\\_dragonslayer.png` + brush entry (`brushes/` dir has `unpacked\\\_brushes/`? check).
* Active skill icons: vanilla icons reused (`active\\\_06/07/09/100.png` + `\\\_sw` disabled) — OR new `gfx/ui/skills/hd\\\_\\\*`.
* Effect icon: reuse `gfx/ui/skills/effects/stagger.png` (vanilla) — confirm exists.
* Sound: reuse vanilla sword/sweep/stagger hit sounds (`sounds/combat/swing\\\_\\\*`, `split\\\_\\\*`, `round\\\_swing\\\_\\\*`) — no new sfx required. \[KEEP]

## 8\. Balance guardrails (READ — no Legendary refs)

* After port, grep every new `.nut` for `legend` / `Legends` — zero hits allowed.
* `staggered\\\_effect` + `stunned\\\_effect` are vanilla — safe to apply directly.
* Ingredient scripts must resolve at runtime under Reforged (>=0.9.0) + vanilla — confirm each candidate path exists (§5 candidates pre-checked).
* Recipe hidden until MSU toggle = no menu clutter, no balance churn → stays QoL easter egg.
* Test: (a) toggle OFF → crafting screen has no Dragonslayer entry; (b) toggle ON + valid bg → recipe visible; (c) wield 2H → 4 actives show + stagger-on-shatter works; (d) Demolish Shield vs parrying dagger → vanilla 0.2× pen.

## 9\. Decisions needed (fill ▢ / edit numbers)

1. Weapon `m.ID`: `weapon.hd\\\_dragonslayer` ▢ (other: `\\\_\\\_TODO\\\_\\\_`)
2. Active skill IDs: `hd\\\_guerillotine\\\_strike` / `hd\\\_steel\\\_crescent` / `hd\\\_decimate` / `hd\\\_demolish\\\_shield` ▢
3. `legend\\\_baffled\\\_effect` replacement: custom 1-turn effect (-25% dmg + stagger) ▢ / stagger-only ▢ / different %
4. Ingredient set: use proposed default (§5) ▢ / edit each qty/substitute
5. Background req: none ▢ / anatomist ▢ / rf\_old\_swordmaster ▢ / rf\_renowned\_swordmaster ▢
6. Crafting station: vanilla ▢ / Reforged armory ▢
7. GFX: reuse Dragonslayer art (copy) ▢ / new art ▢
8. Sound: vanilla reuse ▢ / custom ▢
9. Value 4200 ▢ / change to `\\\_\\\_TODO\\\_\\\_`

