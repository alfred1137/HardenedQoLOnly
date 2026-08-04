::Hardened.HooksMod.hook("scripts/skills/actives/coat_with_spider_poison_skill", function(q) {
	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		foreach (entry in ret)
		{
			if (entry.id == 7 && entry.icon == "ui/icons/special.png")
			{
				entry.text = ::Reforged.Mod.Tooltips.parseString("Gain [$ $|Skill+spider_poison_coat_effect]");
			}
		}

		return ret;
	}
});
