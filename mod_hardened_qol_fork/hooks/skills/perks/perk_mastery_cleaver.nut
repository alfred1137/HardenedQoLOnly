// The reforged hook for this perk is being sniped
::Hardened.HooksMod.hook("scripts/skills/perks/perk_mastery_cleaver", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Icon = "ui/perks/perk_52.png";	// Vanilla Fix: Vanilla has the icon for Anticipation here
	}
});