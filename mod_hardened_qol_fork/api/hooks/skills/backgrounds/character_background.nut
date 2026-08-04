::Hardened.HooksMod.hook("scripts/skills/backgrounds/character_background", function(q) {
// New Functions
	q.HD_getNamePlural <- function()
	{
		local pluralName = this.getNameOnly();

		if (pluralName.len() >= 3 && pluralName.slice(pluralName.len() - 3) == "man")
		{
			pluralName = pluralName.slice(0, pluralName.len() - 3) + "men";
		}
		else
		{
			pluralName += "s";
		}

		return pluralName;
	}
})