::Hardened.HooksMod.hook("scripts/skills/perks/perk_relentless", function(q) {
// MSU Events
	q.onQueryTooltip <- function( _skill, _tooltip )
	{
		// Remove mention about the waiting debuff
		if (_skill.getID() == "actives.recover")
		{
			foreach (index, entry in _tooltip)
			{
				if (entry.id == 11 && entry.icon == "ui/icons/special.png" && entry.text.find("Gain the ") != null)
				{
					_tooltip.remove(index);
					break;
				}
			}
		}
	}

// Hardened Events
	q.onOtherSkillAdded = @(__original) function( _otherSkill )
	{
		if (_otherSkill.getID() == "effects.hd_wait")
		{
			_otherSkill.removeSelf();
		}
	}
});
