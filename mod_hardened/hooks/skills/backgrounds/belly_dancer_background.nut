::Hardened.HooksMod.hook("scripts/skills/backgrounds/belly_dancer_background", function(q) {
	q.createPerkTreeBlueprint = @() { function createPerkTreeBlueprint()
	{
		return ::new(::DynamicPerks.Class.PerkTree).init({
			DynamicMap = {
				"pgc.rf_exclusive_1": [
					"pg.hd_entertainer",
				],
				"pgc.rf_shared_1": [],
				"pgc.rf_weapon": [],
				"pgc.rf_armor": [
					"pg.rf_medium_armor",
				],
				"pgc.rf_fighting_style": [
					"pg.rf_swift",
				],
			}
		});
	}}.createPerkTreeBlueprint;
});
