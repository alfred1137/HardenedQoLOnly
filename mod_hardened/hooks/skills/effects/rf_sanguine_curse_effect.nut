::Hardened.HooksMod.hook("scripts/skills/effects/rf_sanguine_curse_effect", function(q) {
// Hardened
	q.m.HD_IsBleed = true;
	q.m.HD_PreventedByProperties = ["IsImmuneToBleeding"];
});
