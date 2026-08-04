// The reforged hook for this perk is being sniped
::Hardened.HooksMod.hook("scripts/skills/perks/perk_mastery_throwing", function(q) {
	q.create = @(__original) function()
	{
		__original();

		this.m.Description = "Master throwing weapons to wound or kill the enemy before they even get close";
		this.m.Icon = "ui/perks/perk_50.png";	// Vanilla: "ui/perks/perk_10.png"; which is the Anticipation Icon
	}
});