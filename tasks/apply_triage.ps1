# apply_triage.ps1 - Execute triage deletions per tasks/triage.md.
# Dry-run by default: pass -Execute to actually delete.
# Usage:  pwsh ./tasks/apply_triage.ps1          (dry run)
#         pwsh ./tasks/apply_triage.ps1 -Execute (delete)
#
# NOTE: GATE files are NOT deleted here - they are edited in Phase 4.

param([switch]$Execute)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Set-Location $Root

$Deleted = @()
$Missed = @()

function Remove-Files {
	param([string[]]$RelPaths, [string]$Reason)
	foreach ($rel in $RelPaths) {
		$p = Join-Path $Root $rel
		if (Test-Path -LiteralPath $p) {
			if ($Execute) { Remove-Item -LiteralPath $p -Force }
			$script:Deleted += "$rel ($Reason)"
		} else {
			$script:Missed += "$rel (NOT FOUND, $Reason)"
		}
	}
}

function Remove-DirRecursive {
	param([string]$RelDir, [string]$Reason)
	$d = Join-Path $Root $RelDir
	if (Test-Path -LiteralPath $d) {
		$files = Get-ChildItem -LiteralPath $d -Recurse -File
		if ($Execute) { Remove-Item -LiteralPath $d -Recurse -Force }
		foreach ($f in $files) {
			$rel = $f.FullName.Substring($Root.Length + 1)
			$script:Deleted += "$rel ($Reason)"
		}
	} else {
		$script:Missed += "$RelDir (DIR NOT FOUND, $Reason)"
	}
}

# Delete every file in $Dir except the basenames in $Keep (relative paths kept).
function Remove-DirExcept {
	param([string]$RelDir, [string[]]$Keep, [string]$Reason)
	$d = Join-Path $Root $RelDir
	if (-not (Test-Path -LiteralPath $d)) { $script:Missed += "$RelDir (DIR NOT FOUND)"; return }
	$keepSet = @{}
	foreach ($k in $Keep) { $keepSet[$k.Replace("/", "\").ToLowerInvariant()] = $true }
	foreach ($f in (Get-ChildItem -LiteralPath $d -Recurse -File)) {
		$rel = $f.FullName.Substring($Root.Length + 1)
		if ($keepSet.ContainsKey($rel.ToLowerInvariant())) { continue }
		if ($Execute) { Remove-Item -LiteralPath $f.FullName -Force }
		$script:Deleted += "$rel ($Reason)"
	}
}

# ============================================================
# 1) Whole-directory deletions
# ============================================================
Remove-DirRecursive "mod_hardened_qol_fork/crock_pot_hooks" "DELETE: beast resource rework"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/mods/mod_reforged" "DELETE: Reforged integration (keep config/text.nut separately - not in this dir)" 
# NOTE: config/text.nut lives inside the above dir. We handle it by keeping it via the except variant below.
# Fix: redo mod_reforged with keep-list instead:

# ============================================================
# 2) Keep-allowlist bulk dirs
# ============================================================
Remove-DirExcept "mod_hardened_qol_fork/hooks/mods/mod_reforged" @(
	"mod_hardened_qol_fork/hooks/mods/mod_reforged/config/text.nut"
) "DELETE: Reforged integration"
Remove-DirRecursive "mod_hardened_qol_fork/hooks_afterhooks/mods/mod_reforged" "DELETE: Reforged named-item table"
Remove-DirRecursive "mod_hardened_qol_fork/hooks_afterhooks/perk_groups" "DELETE: new perk groups" 

# reforged/ - keep actor_tooltip_functions
Remove-DirExcept "mod_hardened_qol_fork/reforged" @(
	"mod_hardened_qol_fork/reforged/actor_tooltip_functions.nut"
) "DELETE: Reforged-overhaul integration"

# scripts content
Remove-DirRecursive "scripts/scenarios" "DELETE: custom HD scenarios"
Remove-DirRecursive "scripts/ai" "DELETE: custom HD AI content"
Remove-DirRecursive "scripts/entity" "DELETE: custom HD entities"
Remove-DirRecursive "scripts/mods/mod_hardened_qol_fork/ai" "DELETE: bounty-hunter manager"
Remove-DirRecursive "scripts/mods/mod_hardened_qol_fork/perk_groups" "DELETE: custom Reforged perk groups"
Remove-DirRecursive "scripts/skills/perks" "DELETE: custom HD perks"
Remove-DirRecursive "scripts/skills/actives" "DELETE: custom HD actives"
Remove-DirRecursive "scripts/skills/effects" "DELETE: custom HD effects"
Remove-DirRecursive "scripts/skills/racial" "DELETE: custom HD racials"
Remove-DirRecursive "scripts/skills/injury" "DELETE: custom HD injury"
Remove-DirRecursive "scripts/skills/items" "DELETE: custom HD item skill"
Remove-DirExcept "scripts/skills/special" @(
	"scripts/skills/special/hd_bag_item_silhouettes.nut",
	"scripts/skills/special/hd_bag_item_manager.nut",
	"scripts/skills/special/hd_frenzy_eyes_manager.nut",
	"scripts/skills/special/hd_dummy_morale_state.nut",
	"scripts/skills/special/hd_dummy_morale_state_breaking.nut",
	"scripts/skills/special/hd_dummy_morale_state_confident.nut",
	"scripts/skills/special/hd_dummy_morale_state_fleeing.nut",
	"scripts/skills/special/hd_dummy_morale_state_wavering.nut"
) "DELETE: custom HD special skills (balance)"

# hooks/skills bulk
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/perks" @(
	"mod_hardened_qol_fork/hooks/skills/perks/perk_colossus.nut",
	"mod_hardened_qol_fork/hooks/skills/perks/perk_fortified_mind.nut",
	"mod_hardened_qol_fork/hooks/skills/perks/perk_fast_adaption.nut",
	"mod_hardened_qol_fork/hooks/skills/perks/perk_mastery_cleaver.nut",
	"mod_hardened_qol_fork/hooks/skills/perks/perk_mastery_throwing.nut",
	"mod_hardened_qol_fork/hooks/skills/perks/perk_rf_calculated_strikes.nut"
) "DELETE: perk balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/actives" @(
	"mod_hardened_qol_fork/hooks/skills/actives/coat_with_poison_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/exesword_decapitate.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/explode_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/fling_back_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/geomancy_once_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/geomancy_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/goblin_whip.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/gruesome_feast.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/ignite_firelance_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/knock_back.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/kraken_ensnare_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/lightning_storm_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/move_tail_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/nightmare_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/overhead_strike.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/raise_all_undead_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/recover_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_cheap_trick_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_cover_ally_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_encourage_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_line_breaker_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rotation.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/sleep_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/split_man.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/summon_flying_skulls_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/summon_mirror_image_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/swing.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/voice_of_davkul_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/zombie_bite.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/coat_with_spider_poison_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/disarm_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/drink_antidote_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/fire_handgonne_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_hold_steady_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_net_pull_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/rf_pummel_skill.nut",
	"mod_hardened_qol_fork/hooks/skills/actives/teleport_skill.nut"
) "DELETE: active-skill balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/effects" @(
	"mod_hardened_qol_fork/hooks/skills/effects/stunned_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/horrified_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/disarmed_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/bleeding_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/smoke_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/shieldwall_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/killing_frenzy_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/berserker_mushrooms_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/adrenaline_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/antidote_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/goblin_poison_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/rf_sanguine_curse_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/rf_frostbound_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/rf_warmth_potion_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/rf_sapling_harvest_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/charmed_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/effects/dazed_effect.nut"
) "DELETE: effect balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/special" @(
	"mod_hardened_qol_fork/hooks/skills/special/rf_reach.nut",
	"mod_hardened_qol_fork/hooks/skills/special/mood_check.nut",
	"mod_hardened_qol_fork/hooks/skills/special/night_effect.nut",
	"mod_hardened_qol_fork/hooks/skills/special/morale_check.nut"
) "DELETE: special balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/skills/racial" "DELETE: racial balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/traits" @(
	"mod_hardened_qol_fork/hooks/skills/traits/teamplayer_trait.nut",
	"mod_hardened_qol_fork/hooks/skills/traits/brute_trait.nut"
) "DELETE: trait balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/skills/backgrounds" @(
	"mod_hardened_qol_fork/hooks/skills/backgrounds/crusader_background.nut",
	"mod_hardened_qol_fork/hooks/skills/backgrounds/orc_slayer_background.nut"
) "DELETE: background balance reworks"

# hooks/items bulk
Remove-DirExcept "mod_hardened_qol_fork/hooks/items/weapons" @(
	"mod_hardened_qol_fork/hooks/items/weapons/drum_item.nut",
	"mod_hardened_qol_fork/hooks/items/weapons/lightbringer_sword.nut",
	"mod_hardened_qol_fork/hooks/items/weapons/obsidian_dagger.nut",
	"mod_hardened_qol_fork/hooks/items/weapons/weapon.nut",
	"mod_hardened_qol_fork/hooks/items/weapons/named/named_weapon.nut"
) "DELETE: weapon balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/items/armor" @(
	"mod_hardened_qol_fork/hooks/items/armor/armor.nut",
	"mod_hardened_qol_fork/hooks/items/armor/rf_draugr/rf_draugr_pauldron_armor.nut",
	"mod_hardened_qol_fork/hooks/items/armor/rf_draugr/rf_draugr_pauldron_fur_armor.nut"
) "DELETE: armor balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/items/helmets" @(
	"mod_hardened_qol_fork/hooks/items/helmets/helmet.nut"
) "DELETE: helmet balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/items/shields" @(
	"mod_hardened_qol_fork/hooks/items/shields/shield.nut"
) "DELETE: shield balance reworks"
Remove-DirExcept "mod_hardened_qol_fork/hooks/items/ammo" @(
	"mod_hardened_qol_fork/hooks/items/ammo/legendary/quiver_of_coated_arrows.nut"
) "DELETE: ammo balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/accessory" "DELETE: accessory balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/tools" "DELETE: tool balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/trade" "DELETE: trade balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/armor_upgrades" "DELETE: upgrade balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/loot" "DELETE: loot balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/misc" "DELETE: misc balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/special" "DELETE: special balance reworks"
Remove-DirRecursive "mod_hardened_qol_fork/hooks/items/supplies" "DELETE: supply balance reworks"

# hooks/entity bulk
Remove-DirExcept "mod_hardened_qol_fork/hooks/entity/tactical" @(
	"mod_hardened_qol_fork/hooks/entity/tactical/actor.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/player.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/tactical_entity_manager.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/wardog.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/warhound.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/enemies/zombie_yeoman.nut",
	"mod_hardened_qol_fork/hooks/entity/tactical/enemies/unhold.nut"
) "DELETE: NPC redesigns"
Remove-DirExcept "mod_hardened_qol_fork/hooks/entity/world" @(
	"mod_hardened_qol_fork/hooks/entity/world/world_entity.nut",
	"mod_hardened_qol_fork/hooks/entity/world/location.nut",
	"mod_hardened_qol_fork/hooks/entity/world/party.nut",
	"mod_hardened_qol_fork/hooks/entity/world/settlement.nut",
	"mod_hardened_qol_fork/hooks/entity/world/player_party.nut",
	"mod_hardened_qol_fork/hooks/entity/world/settlements/city_state.nut",
	"mod_hardened_qol_fork/hooks/entity/world/settlements/buildings/port_bulding.nut",
	"mod_hardened_qol_fork/hooks/entity/world/settlements/situations/situation.nut",
	"mod_hardened_qol_fork/hooks/entity/world/settlements/buildings/tavern_building.nut",
	"mod_hardened_qol_fork/hooks/entity/world/locations/undead_buried_castle_location.nut"
) "DELETE: world-entity balance/scaling reworks"

# hooks/ai bulk
Remove-DirExcept "mod_hardened_qol_fork/hooks/ai" @(
	"mod_hardened_qol_fork/hooks/ai/world/behaviors/ai_world_attack.nut",
	"mod_hardened_qol_fork/hooks/ai/world/orders/move_order.nut",
	"mod_hardened_qol_fork/hooks/ai/tactical/behaviors/ai_sleep.nut",
	"mod_hardened_qol_fork/hooks/ai/tactical/behaviors/ai_retreat.nut",
	"mod_hardened_qol_fork/hooks/ai/tactical/behaviors/ai_flee.nut",
	"mod_hardened_qol_fork/hooks/ai/tactical/behaviors/ai_break_free.nut"
) "DELETE: AI behavior reworks"

# ============================================================
# 3) Targeted deletions in mixed dirs
# ============================================================
Remove-Files @(
	# hooks/config/ - delete balance/scaling tables
	"mod_hardened_qol_fork/hooks/config/world_settlement.nut",
	"mod_hardened_qol_fork/hooks/config/world_entity_common.nut",
	"mod_hardened_qol_fork/hooks/config/world_assets.nut",
	"mod_hardened_qol_fork/hooks/config/global.nut",
	"mod_hardened_qol_fork/hooks/config/faction_traits.nut",
	"mod_hardened_qol_fork/hooks/config/world.nut",
	"mod_hardened_qol_fork/hooks/config/tactical_entity_common.nut",
	"mod_hardened_qol_fork/hooks/config/ai.nut",
	"mod_hardened_qol_fork/hooks/config/root_table.nut",
	"mod_hardened_qol_fork/hooks/config/perk_defs.nut",
	"mod_hardened_qol_fork/hooks/config/spawnlist_master.nut",
	"mod_hardened_qol_fork/hooks/config/character_traits.nut",
	"mod_hardened_qol_fork/hooks/config/contracts.nut",
	"mod_hardened_qol_fork/hooks/config/faction.nut",
	"mod_hardened_qol_fork/hooks/config/character_injuries.nut",
	"mod_hardened_qol_fork/hooks/config/character.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_undead.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_southern.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_military.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_greenskins.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_civilian.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_beasts.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_barbarians.nut",
	"mod_hardened_qol_fork/hooks/config/factions/faction_bandits.nut",
	# hooks/contracts/
	"mod_hardened_qol_fork/hooks/contracts/contracts/escort_envoy_contract.nut",
	"mod_hardened_qol_fork/hooks/contracts/contracts/escort_caravan_contract.nut",
	# hooks/events/ - balance events
	"mod_hardened_qol_fork/hooks/events/special/retinue_slot_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/rf_oathtakers_take_oaths_in_regular_origins_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/player_plays_dice_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/bad_omen_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/caravan_hand_cart_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/dlc4/tundra_elk_destroyed_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/dlc2/location/ancient_watchtower_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/dlc2/location/ancient_temple_enter_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/dlc2/glutton_eats_apple_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/dlc2/bird_shits_on_sellsword_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/crisis/undead_crusader_leaves_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/crisis/greenskins_slayer_leaves_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/crisis/civilwar_dead_knight_event.nut",
	"mod_hardened_qol_fork/hooks/events/events/crisis/civilwar_conscription_event.nut",
	# hooks/ambitions/ - all 5
	"mod_hardened_qol_fork/hooks/ambitions/ambitions/trade_ambition.nut",
	"mod_hardened_qol_fork/hooks/ambitions/ambitions/sergeant_ambition.nut",
	"mod_hardened_qol_fork/hooks/ambitions/ambitions/ranged_mastery_ambition.nut",
	"mod_hardened_qol_fork/hooks/ambitions/ambitions/battle_standard_ambition.nut",
	"mod_hardened_qol_fork/hooks/ambitions/ambitions/allied_nobles_ambition.nut",
	# hooks/crafting/
	"mod_hardened_qol_fork/hooks/crafting/blueprints/antidote_blueprint.nut",
	# hooks/factions/ - scaling + actions
	"mod_hardened_qol_fork/hooks/factions/faction_manager.nut",
	"mod_hardened_qol_fork/hooks/factions/faction_action.nut",
	"mod_hardened_qol_fork/hooks/factions/contracts/discover_location_action.nut",
	"mod_hardened_qol_fork/hooks/factions/contracts/return_item_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_supplies_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_peasants_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_military_holysite_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_military_army_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_citystate_holysite_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_citystate_army_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/send_caravan_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/rf_build_draugr_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/patrol_roads_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/patrol_area_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/move_troops_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/defend_military_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/defend_citystate_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_zombie_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_undead_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_orc_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_nomad_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_goblin_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_barbarian_camp_action.nut",
	"mod_hardened_qol_fork/hooks/factions/actions/build_bandit_camp_action.nut",
	# hooks/mods/ - dynamic spawns classes
	"mod_hardened_qol_fork/hooks/mods/mod_dynamic_spawns/classes/party.nut",
	"mod_hardened_qol_fork/hooks/mods/mod_dynamic_spawns/classes/party_leader.nut",
	"mod_hardened_qol_fork/hooks/mods/mod_dynamic_spawns/classes/block.nut",
	"mod_hardened_qol_fork/hooks/mods/mod_dynamic_spawns/classes/unit.nut",
	# hooks/states/
	"mod_hardened_qol_fork/hooks/states/main_menu_state.nut",
	# hooks/mapgen/
	"mod_hardened_qol_fork/hooks/mapgen/templates/tactical/tiles/swamp3.nut",
	"mod_hardened_qol_fork/hooks/mapgen/templates/tactical/patches/patch_forest.nut",
	# hooks_early/ - non-api deletes
	"mod_hardened_qol_fork/hooks_early/mapgen/templates/world/worldmap_generator.nut",
	"mod_hardened_qol_fork/hooks_early/skills/perks/perk_nine_lives.nut",
	"mod_hardened_qol_fork/hooks_early/ui/screens/world/modules/world_campfire_screen/campfire_main_dialog_module.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/wooden_watchtower_location.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/stone_watchtower_oriental_location.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/stone_watchtower_location.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/militia_trainingcamp_oriental_location.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/militia_trainingcamp_location.nut",
	"mod_hardened_qol_fork/hooks_early/entity/world/attached_location/fortified_outpost_location.nut",
	"mod_hardened_qol_fork/hooks_early/ai/tactical/behaviors/ai_attack_bow.nut",
	"mod_hardened_qol_fork/hooks_early/ai/tactical/behavior.nut",
	"mod_hardened_qol_fork/hooks_early/entity/tactical/human.nut",
	# hooks_late/
	"mod_hardened_qol_fork/hooks_late/config/temporary_faction_units.nut",
	# hooks_last/
	"mod_hardened_qol_fork/hooks_last/snipe_hooks.nut",
	"mod_hardened_qol_fork/hooks_last/shield_last.nut",
	# hooks_afterhooks/
	"mod_hardened_qol_fork/hooks_afterhooks/perk_group_collection.nut",
	"mod_hardened_qol_fork/hooks_afterhooks/perk_groups.nut",
	# namespaces/
	"mod_hardened_qol_fork/namespaces/flagged_perks.nut",
	# api/ deletes
	"mod_hardened_qol_fork/api/hooks/ai/world/orders/mercenary_order.nut",
	"mod_hardened_qol_fork/api/hooks/entity/tactical/enemies/zombie.nut",
	"mod_hardened_qol_fork/api/hooks/entity/world/entity_manager.nut",
	"mod_hardened_qol_fork/api/hooks/entity/world/settlements/buildings/building.nut",
	"mod_hardened_qol_fork/api/hooks/factions/faction_action.nut",
	"mod_hardened_qol_fork/api/hooks/items/weapons/named/named_weapon.nut",
	"mod_hardened_qol_fork/api/hooks/skills/special/rf_polearm_adjacency.nut",
	"mod_hardened_qol_fork/api/hooks/states/main_menu_state.nut",
	"mod_hardened_qol_fork/api/hooks_early/entity/tactical/player.nut",
	"mod_hardened_qol_fork/api/hooks_early/items/accessory/accessory.nut",
	"mod_hardened_qol_fork/api/hooks_early/items/armor/armor.nut",
	"mod_hardened_qol_fork/api/hooks_early/items/helmets/helmet.nut",
	"mod_hardened_qol_fork/api/hooks_early/items/shields/shield.nut",
	"mod_hardened_qol_fork/api/hooks_early/items/weapons/weapon.nut"
) "DELETE: balance/scaling/Reforged reworks"

# ============================================================
# Report
# ============================================================
Write-Host ""
Write-Host "===== TRIAGE APPLICATION SUMMARY ($($Deleted.Count) deletes, $($Missed.Count) misses) ====="
if ($Missed.Count -gt 0) {
	Write-Host ""
	Write-Host "--- MISSED (paths not found - verify) ---"
	$Missed | Sort-Object | ForEach-Object { Write-Host "  $_" }
}
if (-not $Execute) {
	Write-Host ""
	Write-Host "DRY RUN - no files deleted. Re-run with -Execute to apply."
}

