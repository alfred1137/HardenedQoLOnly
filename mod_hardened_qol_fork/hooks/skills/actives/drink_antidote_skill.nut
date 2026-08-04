::Hardened.HooksMod.hook("scripts/skills/actives/drink_antidote_skill", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Name = "Use Antidote";	// In Vanilla this is "Drink or Give Antidote"
		this.m.Description = "Save yourself or another character from toxins.";		// We change "poisons" into "toxins" and remove any mention of "giving it to allies"
	}
});