# Triage Inventory — Hardened → QoL-only fork

Verdict legend:

* **KEEP** — QoL / vanilla fix / bug fix. Retain as-is.
* **DELETE** — balance rework / Reforged-overhaul / scaling subsystem / non-QoL feature. Remove file + prune MSU setting + `::Hardened.Global` const.
* **GATE** — mixed file: keep QoL/fix parts, strip balance/scaling parts.
* **REVERT** — file reverts Reforged→vanilla (balance). Delete unless user wants vanilla reversions.

## Confirmed verdicts (manually read)

### hooks_early/

* injury_defaults.nut → KEEP — Fix: correct injury body-part assignment
* crafting/blueprint.nut → KEEP — Perf: inventory map for isCraftable
* mapgen/templates/world/worldmap_generator.nut → DELETE — Mapgen settlement rework (not QoL)
* skills/perks/perk_nine_lives.nut → DELETE — Balance: removes heightened-reflexes on trigger
* ui/screens/menu/modules/main_menu_module.nut → KEEP — QoL: remembers last origin settings
* ui/screens/menu/modules/new_campaign_menu_module.nut → KEEP — QoL: saves last origin settings
* ui/screens/world/modules/world_campfire_screen/campfire_main_dialog_module.nut → DELETE — Dev moddability refactor, not player QoL
* camera/tactical_camera_director.nut → KEEP — Fix: allow camera input while moving
* entity/world/combat_manager.nut → KEEP — Vanilla Fix: prevents parties joining combat multiple times
* entity/world/attached_location.nut → GATE — keep "Produces:" tooltip + onDeserialize item-clear fix; strip raidable/rebuild/loot/FactionDifficulty scaling
* entity/tactical/actor.nut → GATE — keep setDirty null-guard + getHitpointsMax roundToDec; strip getFatigueMax default-recalc + getInitiative weight/stamina rework
* entity/world/attached_location/{wooden_watchtower,stone_watchtower_oriental,stone_watchtower,militia_trainingcamp_oriental,militia_trainingcamp,fortified_outpost}_location.nut → DELETE — garrison/loot rework
* ai/tactical/behaviors/ai_attack_bow.nut → DELETE — AI target-priority rework
* ai/tactical/behavior.nut → DELETE — AI queryActorTurnsNearTarget rework
* entity/tactical/human.nut → DELETE — sound-not-repeated feat

### hooks_late/

* skills/actives/fling_back_skill.nut → KEEP — Part of shared knockback infra (util.nut)
* config/temporary_faction_units.nut → DELETE — Scaling subsystem (`addTemporaryEntity`/`addEntityFallback`)

### hooks_last/

* turn_sequence_bar.nut → KEEP — QoL: hit-chance / ZOC preview overlays
* skill.nut → KEEP — Fix: getTooltip dummy-player attach
* snipe_hooks.nut → DELETE — Reverts Reforged mechanics to vanilla (balance)
* shield_last.nut → DELETE — Shield condition/durability rework (balance)

### hooks_afterhooks/

* perk_group_collection.nut → DELETE — Perk-group restructuring
* perk_groups.nut → DELETE — New perk groups (pg_hd_*)
* mods/mod_reforged/item_tables/named_northern_weapon_melee.nut → DELETE — Removes named RF longsword (loot balance)

### hooks/root/

* tactical.nut → KEEP — Projectile obstacle-hit effect (dep: api entity HD_onHitByProjectile)
* tactical_camera_bridge.nut → KEEP — QoL: better camera level
* sound.nut → KEEP
* tactical_highlighter.nut → KEEP — Vanilla Fix: overlay-icon y-offset, skill range preview

### hooks/states/

* main_menu_state.nut → DELETE — Registers HD custom scenarios (content, not QoL)
* tactical_state.nut → KEEP — QoL/fixes: camera hotkeys, zoom mult, freeze fixes, round-start fix
* world_state.nut → KEEP — QoL (numerals)

### hooks/ui/

* screens/tooltip/modules/tooltip.nut → KEEP — Fix: revert faction switcheroo
* screens/world/world_combat_dialog.nut → KEEP — Fix: clear temp-enemy flags on dialog cancel
* screens/world/world_event_screen.nut → KEEP — Fix: contract button lock
* screens/tactical/tactical_combat_result_screen.nut → KEEP
* screens/world/modules/world_town_screen/town_training_dialog_module.nut → KEEP — QoL: show trained effect
* screens/tooltip/tooltip_events.nut → GATE — QoL tooltips KEEP; strip difficulty lines
* screens/world/modules/world_town_screen/town_hire_dialog_module.nut → KEEP — dismiss sound + roster reload QoL
* screens/tactical/modules/topbar/tactical_screen_topbar_event_log.nut → KEEP — combat-log combining, setting-gated readability
* screens/world/world_relations_screen.nut → GATE — keep undiscovered-faction placeholders; strip rest
* screens/tactical/modules/turn_sequence_bar/turn_sequence_bar.nut → GATE — keep morale label + camera reset + ExtraKeybinds fix; strip round-separator log
* screens/character/character_screen.nut → GATE — keep perk-unlock sound + duplicate-sound fix; strip XP-share-on-dismiss, arena collar imprint
* ui/global/data_helper.nut → GATE — keep per-level XP display; strip angry-brother dismiss hijack

### hooks/crafting/

* crafting_manager.nut → KEEP — Perf: inventory map
* blueprint.nut → KEEP — Vanilla Fix: potion/elixir crafting sounds
* blueprints/poisoned_oil_blueprint.nut → KEEP — Vanilla Fix: crafting sound
* blueprints/paint_set_blueprint.nut → GATE — keep "x3" name label; strip extra craft yield

### hooks/entity/world/

* world_entity.nut → KEEP — QoL: numerals + faction color
* location.nut → KEEP — QoL: discovery fixes
* party.nut → KEEP — QoL: label alpha, faction flag
* settlement.nut → GATE — Strip "resources grow with world difficulty" (scaling)
* player_party.nut → KEEP — QoL: banner during camping
* settlements/city_state.nut → GATE — Strip "produce ammo/armor/medicine" (balance)
* settlements/buildings/port_bulding.nut → KEEP — QoL: forbidden ports in sail roster
* settlements/situations/situation.nut → GATE — keep price/rarity/recruit tooltip display; strip recruit-availability tooltip (tied to deleted draft removals)
* settlements/buildings/tavern_building.nut → GATE — keep "[Rumors Given]" counter; strip MaximumRumors cap + price scaling

### hooks/entity/tactical/

* player.nut → GATE — Keep XP fix + mood QoL; strip strength-calc overwrite
* tactical_entity_manager.nut → GATE — Keep kill-noncombatants fix; strip weather-seed feat
* actor.nut → GATE — see dedicated section below
* wardog.nut → KEEP — QoL: sound-volume reduction
* warhound.nut → KEEP — QoL: sound-volume reduction
* enemies/zombie_yeoman.nut → KEEP — display fix: "Armored Zombie" name
* enemies/unhold.nut → KEEP — QoL: names match world-map names

### hooks/factions/

* faction_manager.nut → DELETE — Scaling subsystem
* faction_action.nut → DELETE — Scaling subsystem
* faction.nut → GATE — Keep relation fixes; strip temp-ally feature
* factions/contracts/* → DELETE — Scaling subsystem
* settlement_faction.nut → GATE — keep relation-reason mirror + owner-banner fix; strip contract count/delay economy
* actions/build_unique_locations_action.nut → GATE — keep spacing/perf fix; strip Oracle range restriction

### hooks/ai/

* world/behaviors/ai_world_attack.nut → KEEP — Fix: self-engage
* tactical/behaviors/ai_sleep.nut → KEEP — Fix: queryTargetValue null
* tactical/behaviors/ai_retreat.nut → KEEP — Fix: lindwurm tail + ZOC retreat
* tactical/behaviors/ai_flee.nut → KEEP — Fix: retreat-vs-flee priority
* world/orders/move_order.nut → GATE — keep caravan-despawn fix; strip HD_onRemoved bounty-hunter event
* tactical/behaviors/ai_break_free.nut → GATE — keep ≤30% ZoC fix; strip MeleeDef mult + ZoC scaling
* tactical/agents/vampire_agent.nut → DELETE — EngageMelee removal = AI rework, not fix
* tactical/behaviors/ai_switchto_*.nut → GATE — Strip equip-sound feat
* tactical/behaviors/ai_hex/charm/attack_swallow_whole → GATE — queryTargetValue fix KEEP; strip TargetAttractionMult
* tactical/behaviors/ai_engage_ranged.nut → GATE — Strip defend-abort feat
* tactical/behaviors/ai_attack_throw_net.nut → GATE — Split-function refactor
* tactical/strategy.nut → DELETE — Defend-cancel balance

### hooks/contracts/

* contract.nut → GATE — Keep screen-fix; strip renown-penalty feat
* contracts/arena_contract.nut → GATE — Keep participant-name QoL; strip reequip feat
* contracts/discover_location_contract.nut → KEEP — anti-cheese: cache/serialize directions
* contracts/barbarian_king_contract.nut → KEEP — anti-cheese: cache/serialize king directions

### hooks/ambitions/

* ambitions/trade_ambition.nut → DELETE — Balance: count both buy+sell
* ambitions/allied_nobles_ambition.nut → DELETE — Balance: heraldic cape reward

### hooks/events/

* events/wound_gets_infected_event.nut → GATE — Score calc
* events/wardogs_fight_each_other_event.nut → GATE — Score calc + dog-ratio feat
* events/fat_guy_gets_fit_event.nut → GATE — Candidate condition
* events/drunkard_loses_stuff_event.nut → GATE — Item-choice change
* events/dlc6/crisis/holywar_occupied_south_event.nut → KEEP — Fix: road-condition queuing
* events/dlc6/crisis/holywar_occupied_north_event.nut → KEEP — Fix: road-condition queuing
* events/event.nut → KEEP — "Max Fatigue"→"Stamina" rename QoL
* events/dlc2/location/kraken_cult_enter_event.nut → KEEP — fixed quest items, removes scaling tedium
* events/crisis/civilwar_town_conquered_event.nut → KEEP — Fix: news not road-gated
* events/crisis/greenskins_town_destroyed_event.nut → KEEP — Fix: news not road-gated
* events/crisis/undead_town_destroyed_event.nut → KEEP — Fix: news not road-gated

### hooks/mapgen/

* templates/world/worldmap_generator.nut → KEEP — Fix: port/road border
* templates/world/tiles/tile_badlands.nut → KEEP — Fix: badlands brush
* templates/tactical/tiles/swamp3.nut → DELETE — Balance: terrain AP change
* templates/tactical/patches/patch_forest.nut → DELETE — Balance: forest grass removal

### hooks/config/

* item_names.nut → KEEP — Vanilla Adjustments
* character_injuries.nut → DELETE — Balance: injury inflict rates
* character.nut → DELETE — (user verdict; was GATE — roundToDec fix lost)
* factions/faction_greenskins.nut → DELETE — (user verdict; was GATE — spawnlist fix lost)
* world_entity_common.nut → DELETE — Balance: champion chance
* tactical_skill_particles.nut → KEEP — miasma/parry visual clarity
* tactical_particles.nut → KEEP — fire visibility + new effect brushes
* tactical.nut → KEEP — day/night ambient lighting colors
* sound.nut → KEEP — idle-sound spam reduction + ambience volume
* character_names.nut → KEEP — extra mercenary company name flavor
* tip_of_the_day.nut → GATE — keep duplicate-screen removal; prune Hardened-feature tips
* strings/strings.nut → GATE — keep label strings; strip newPerk defs
* items.nut → GATE — keep ItemTypeName renames; strip named-item pool changes

### hooks/entity/world/locations/

* undead_ruins_location.nut → DELETE — Loot balance
* undead_graveyard_location.nut → DELETE — Loot balance
* undead_buried_castle_location.nut → KEEP — QoL: original name display

### hooks/mods/

* mod_combat_simulator/global.nut → KEEP — Fix: scenario start
* mod_dynamic_perks/classes/special_perk_group.nut → KEEP — perk-group tooltip condition hints

## Bulk triage results (subagent scans)

### skills/perks/ — 116 files: 110 DELETE | 0 KEEP | 6 GATE
GATE: perk_colossus (keep NPC perk-bloat reduction; strip player HitpointsMult), perk_fortified_mind (keep NPC bloat; strip resolve rework), perk_fast_adaption (keep stack-count name; strip multi-hit), perk_mastery_cleaver + perk_mastery_throwing (keep Anticipation icon fix; strip fatigue/damage), perk_rf_calculated_strikes (keep use-vs-stunned fix; strip InitiativeMult).

### skills/actives/ — 130 files: 93 DELETE | 29 KEEP | 8 GATE
KEEP (29): coat_with_poison_skill, exesword_decapitate, explode_skill, fling_back_skill, geomancy_once_skill, geomancy_skill, goblin_whip, gruesome_feast, ignite_firelance_skill, knock_back, kraken_ensnare_skill, lightning_storm_skill, move_tail_skill, nightmare_skill, overhead_strike, raise_all_undead_skill, recover_skill, rf_cheap_trick_skill, rf_cover_ally_skill, rf_encourage_skill, rf_line_breaker_skill, rotation, sleep_skill, split_man, summon_flying_skulls_skill, summon_mirror_image_skill, swing, voice_of_davkul_skill, zombie_bite (all text/tooltip/sort/visual/fix).
GATE (8): coat_with_spider_poison_skill (keep tooltip; strip AP-discount), disarm_skill (keep tooltip+verify guard; strip AI weighting), drink_antidote_skill (keep name/desc; strip onUse rework), fire_handgonne_skill (keep no-reload-clog; strip UsableWhileEngaged), rf_hold_steady_skill (keep SoundOnTarget; strip Radius 4), rf_net_pull_skill (keep icon; strip IsAttack=false), rf_pummel_skill (keep sound; strip AP cost), teleport_skill (keep fade; strip min-distance).

### skills/effects/ — 48: 31 DEL | 13 KEEP | 4 GATE
KEEP: stunned_effect, horrified_effect, disarmed_effect (vanilla-fix immunity), bleeding_effect (visuals+consistency), smoke_effect, shieldwall_effect (dummy-player tooltip), killing_frenzy_effect, berserker_mushrooms_effect (eyes visual), adrenaline_effect, antidote_effect, goblin_poison_effect (rename+consistency), rf_sanguine_curse_effect (bleed-consistency), rf_frostbound_effect (tooltip+log suppress).
GATE: rf_warmth_potion_effect (keep tooltip; strip ImmuneToChilled), rf_sapling_harvest_effect (keep icon fix; strip damage threshold), charmed_effect (keep name+log; strip TargetAttractionMult), dazed_effect (keep immunity fix; strip 0.8/1.25 mults).

### skills/special/ — 14: 10 DEL | 2 KEEP | 2 GATE
KEEP: rf_reach (tooltip/desc), mood_check (QoL name + absolute mood).
GATE: night_effect (keep icon clarity; strip Vision -3), morale_check (keep icon fix; strip fleeing modifiers).

### skills/racial/ — 13: 13 DELETE. skills/traits/ — 13: 11 DEL | 2 KEEP (teamplayer_trait, brute_trait — tooltip/fix). skills/backgrounds/ — 20: 18 DEL | 2 KEEP (crusader_background, orc_slayer_background — tooltip).

### items/weapons/ — 109: 104 DEL | 3 KEEP | 2 GATE
KEEP: drum_item (IsDoubleGrippable fix), lightbringer_sword (strip RF bullet tooltip), obsidian_dagger (reanimation draw fix).
GATE: weapon.nut (keep tooltips/lowerCondition/consumeAmmo/buildCategories; strip DirectDamage/condition-loss/HD_getDropChance), named_weapon.nut (keep AmmoWeight carryover fix; strip ConditionMult 1.2).

### items/armor/ — 77: 74 DEL | 2 KEEP | 1 GATE
KEEP: rf_draugr/rf_draugr_pauldron_armor.nut + rf_draugr_pauldron_fur_armor.nut (name/art mismatch fix).
GATE: armor.nut (keep hidden-tooltip fix + AutoRepair; strip drop/value/shop logic).

### items/helmets/ — 135: 134 DEL | 1 GATE (helmet.nut — keep hidden-tooltip + paint tracking + AutoRepair; strip values/drop). items/shields/ — 28: 27 DEL | 1 GATE (shield.nut — keep damaged-appearance fix; strip shield-damage engine). items/ammo/ — 8: 7 DEL | 1 GATE (quiver_of_coated_arrows — keep tooltip fix; strip value). items/{tools,trade,armor_upgrades,accessory,loot,misc,special,supplies}/ → all DELETE (~55).

### entity/tactical/ — 176: 172 DEL | 4 KEEP (wardog, warhound, zombie_yeoman, unhold) | 0 GATE. All NPC redesigns, rf_* integration, lindwurm/headless/unworthy/human-resurrection reworks → DELETE.

### entity/world/ — 51: 48 DEL | 1 KEEP (port_bulding) | 2 GATE (situation, tavern_building). All 31 locations scale m.Resources via FactionDifficulty → DELETE. 7 situations remove recruit backgrounds → DELETE. Buildings shop/rarity reworks → DELETE.

### reforged/ — 5: 4 DEL | 1 KEEP (actor_tooltip_functions.nut — cosmetic reach tooltip). hooks/mods/mod_reforged/ — 46: 45 DEL | 1 KEEP (config/text.nut — day-range text). hooks_afterhooks/mods/mod_reforged/ — 1: 1 DEL. crock_pot_hooks/ — 6: 6 DEL. skills/perks/rf_* — 82: 82 DEL.

### ai/ — 33: 30 DEL | 0 KEEP | 3 GATE (move_order, ai_break_free, vampire_agent=DELETE).

### hooks/ui+states+root+mapgen+contracts+events+ambitions+crafting+factions+config+mods — 131: 78 DEL | 34 KEEP | 22 GATE. Events: 14 DELETE (retinue/XP/relation/loot reworks). Faction actions: 21 DELETE (camp build/spawn/difficulty). Config: 25 DELETE (faction stat tables, global/world_assets/contracts/spawnlist_master, perk_defs, faction_traits, character_traits).

## hooks/skills/skill.nut (476 lines) — GATE
Strip: `HD_PreviousRandomResult`, `getHitFactors`, `MV_getDamageRegular`, `MV_onAttackRolled`, `MV_getDamageArmor`, `isDuelistValid`, `RF_isNewSkillUseOrEntity`, `create` (`IsAudibleWhenHidden`), `findTileToKnockBackTo` (+ `HD_KnockBackDistance`).
Keep: `use` (combat-log non-attack), `MV_getDiversionTarget` (cover log), `verifyTargetAndRange` (visibility fix), `revealUser`, `HD_getSkillTags`, `HD_isPrintingUseLog`, `getTooltip` x2, `onUse`, `getDescription`.
Note: stripping `findTileToKnockBackTo` orphans `util.findTileToKnockBackTo` + fling_back_skill + knockback perk hooks — decide as a unit (recommend: keep unit as QoL-adjacent fix infra).

## hooks/entity/tactical/actor.nut (617 lines) — GATE
Strip: `checkMorale`, `wait`, `killSilently`, `onOtherActorDeath`, `onOtherActorFleeing`, `MV_calcHitpointsDamageReceived`, `__calculateSurroundedCount`, `onSpawned`, `RF_canDropLootForPlayer`, plus balance bits in `onInit`, `kill`, `onRoundStart`.
Keep: `getTooltip`, `onMissed`, `onDamageReceived`, `onDiscovered`, `onFactionChanged`, `playIdleSound`, `playSound`, `onAppearanceChanged`, `onMovementFinish`, `onTurnResumed/Start/End`, `setCurrentProperties`, `MV_selectInjury`, `HD_onStartFleeing`, `HD_playFleeAnimation`, `HD_dodgeSidewaysAnimation`, `HD_playColoredJumpAnimation`, `HD_onDiscovered`, `spawnBloodEffect`.

## api/ (75 files) — infra layer
**KEEP** (QoL/fix/UI/camera/perf): tile_reservation, ai/tactical/agent, ai/world/world_controller, config/factions, contracts/contract_manager, entity/tactical/entity, entity/world/player_party, items/item_container, items/ammo/ammo, items/armor_upgrades/armor_upgrade, items/tools/player_banner, mods/mod_unified_perk_descriptions/config, root/math, root/tactical_camera_bridge, root/tactical_highlighter, root/tactical_navigator, skills/skill_container, skills/injury/injury, states/tactical_state, states/world_state, ui/.../orientation_overlay, ui/.../turn_sequence_bar, ui/.../town_tavern_dialog_module, hooks_early/ai/world/world_behavior, hooks_early/skills/skill, hooks_early/skills/special/no_ammo_warning.

**DELETE** (balance/economy/scaling/Reforged): ai/world/orders/mercenary_order, entity/tactical/enemies/zombie, entity/world/entity_manager, settlements/buildings/building, factions/faction_action, items/weapons/named/named_weapon, skills/special/rf_polearm_adjacency, states/main_menu_state, hooks_early/entity/tactical/player, hooks_early/items/accessory/accessory, hooks_early/items/armor/armor, hooks_early/items/helmets/helmet, hooks_early/items/shields/shield, hooks_early/items/weapons/weapon.

**GATE** (keep QoL/fix, strip balance): ai/tactical/behavior, config/character, contracts/contract, entity/tactical/actor, entity/tactical/human, entity/tactical/player, entity/tactical/tactical_entity_manager, entity/world/location, entity/world/settlement, entity/world/world_entity, events/event, factions/faction, items/food_item, items/item, items/shields/shield, items/trade/trading_good_item, items/weapons/ranged_weapon_hooks, items/weapons/weapon, root/time, skills/skill, skills/backgrounds/character_background, states/world/asset_manager, hooks_early/entity/tactical/actor, hooks_early/entity/world/attached_location, hooks_early/factions/actions/build_unique_locations_action, hooks_early/items/item, hooks_early/skills/actives/reload_bolt, hooks_early/skills/actives/reload_handgonne_skill, hooks_early/skills/actives/throw_fire_bomb_skill.

**Cross-refs to preserve:** `::Hardened.TileReservation` (kept navigator/entity_manager/turn_bar), `::Hardened.Private.IsPreviewingAttackWithHitChance` + `HD_ChanceToBeHit` (hitchance overlay chain), `::Hardened.util.findUnusedMercenaryBanner/Name`, `HD_deleteBulletPoint`. `::Hardened.FlaggedPerks` only used by discarded perk parts — safe to delete. Ranged/ammo overhaul = one unit; keep only true-QoL slices (silhouettes, ammo-return, no-ammo warning).

## namespaces/msu/global/const

* namespaces/util.nut → KEEP (core helpers; prune `migratePerk` + `findTileToKnockBackTo` unit only if knockback dropped)
* namespaces/numerals.nut → KEEP — QoL party-size presentation
* namespaces/camera.nut → KEEP — auto camera-level QoL
* namespaces/animation.nut → KEEP — particle vector helpers
* namespaces/flagged_perks.nut → DELETE — custom-perk serialization (only feeds discarded perks)
* msu/msu_settings.nut → KEEP — all settings QoL; no balance-gated settings found
* msu/vanilla_settings.nut, msu/text.nut, msu/tooltips.nut, msu/tile.nut, msu/colorize.nut → all KEEP
* scripts/mods/mod_hardened_qol_fork/global.nut → GATE — STRIP: ContractScaling*, WorldScaling*, negotiation tweaks, FactionDifficulty/FactionExperience, Dynamic-Spawns scaling, getWorldDifficultyMult/getWorldContractMult, addTemporaryEntity/addEntityFallback/switchWorldTroops*, MinimumVision, WeaponSpecFatigueMult, ActionPointChangeOnRally. KEEP: LabelBackgroundAlpha.
* scripts/mods/mod_hardened_qol_fork/const.nut → GATE — STRIP: SettlementsSpaceModifier, ResourceTierMult/ExperienceTierMult. KEEP: getAmmoType/AmmoType (only if ammo QoL kept).
* scripts/mods/mod_hardened_qol_fork/ai/world/bounty_hunter_manager.nut → DELETE
* scripts/mods/mod_hardened_qol_fork/perk_groups/** → DELETE (pg_hd_*, pg_special_hd_*)

## scripts/ (Hardened's own content)

* scripts/skills/perks/perk_hd_* (17) → DELETE. scripts/skills/actives/hd_* (14) → DELETE. scripts/skills/effects/hd_* (20) → DELETE. scripts/skills/racial/hd_* (3) → DELETE. scripts/skills/injury/hd_missing_tail.nut → DELETE. scripts/skills/items/hd_skill_ignore_accessory_effect.nut → DELETE.
* scripts/skills/special/ KEEP (8): hd_bag_item_silhouettes.nut, hd_bag_item_manager.nut, hd_frenzy_eyes_manager.nut, hd_dummy_morale_state.nut + _breaking/_confident/_fleeing/_wavering.nut (QoL infra referenced by KEEP hooks). DELETE (4): hd_direct_damage_limiter, hd_non_combatant_effect, hd_worthless_effect, hd_unworthy_effect.
* scripts/scenarios/tactical/scenario_hd_* (12) → DELETE. scripts/entity/world/hd_waypoint.nut → DELETE. scripts/entity/tactical/enemies/hd_trickster_hollenhund.nut → DELETE. scripts/ai/tactical/behaviors/hd_* (3) → DELETE. scripts/ai/tactical/agents/hd_* (5) → DELETE.
* scripts/!mods_preload/main_hardened.nut → KEEP (bootstrap). PRUNE: Private.CustomTacticalScenarios, Private.LastSpawnedActor, Private.EntityIDFallback (+ their refs in util.nut:475 and main_menu_state). Keep Private.IsPreviewingAttackWithHitChance. Keep all generic helpers (wipeClass, controlledRound, snipeHook, getFunctionCaller, mockFunction, removeTooClosePenalty).

## Key cross-file decisions to confirm

1. **Knockback unit** (util.findTileToKnockBackTo + api/skill.nut findTileToKnockBackTo + hooks/skills/skill.nut + fling_back_skill + gore/repel/knock_back/shatter/kingfisher) — either keep all (fix infra) or drop all. Recommend KEEP.
2. **Ranged/ammo unit** (ranged_weapon_hooks + reload_bolt/reload_handgonne + getRangedWeaponInfo + no_ammo_warning + ammo + const.AmmoType) — keep QoL slices only.
3. **snipe_hooks.nut** — deletes Reforged→vanilla reversions. As QoL-only Reforged submod we want base Reforged, not vanilla: DELETE confirmed.
4. **config/character.nut + faction_greenskins.nut** — user verdict DELETE (loses roundToDec/spawnlist fixes).
5. **hd_dummy_morale_state*** + silhouettes + frenzy-eyes live inside mixed api actor/human hooks — preserve the `add(...)` lines when pruning those files.

## Verification

* Phase 5 static ref scan: after deletions, grep for dangling `::Hardened.Global`, `::Hardened.util`, `HD_*` method refs pointing at deleted files. Fix or restore.
* Phase 6 build + user load over Reforged.
