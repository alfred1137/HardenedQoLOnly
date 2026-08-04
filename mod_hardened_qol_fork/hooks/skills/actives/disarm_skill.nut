::Hardened.HooksMod.hook("scripts/skills/actives/disarm_skill", function(q) {
	q.onVerifyTarget = @(__original) function( _originTile, _targetTile )
	{
		if (!__original(_originTile, _targetTile)) return false;

		local target = _targetTile.getEntity();
		if (target.getCurrentProperties().IsImmuneToDisarm) return false;
		if (target.getCurrentProperties().IsStunned) return false;			// Stun already skips the turn which would also wait out the disarm, so we prevent this
		if (target.getSkills().hasSkill("effects.disarmed")) return false;	// Disarm does not stack so we prevent the player from making a mistake
		if (target.getMainhandItem() == null) return false;		// We can't disarm someone who has no weapon equipped

		return true;
	}

	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		foreach (entry in ret)
		{
			if (entry.id == 7 && entry.icon == "ui/icons/special.png")
			{
				entry.text = ::Reforged.Mod.Tooltips.parseString("Apply [$ $|Skill+disarmed_effect] on a hit");	// We improve vanillas tooltip by making it shorter and featuring a nested tooltip
				break;
			}
		}

		return ret;
	}
});
