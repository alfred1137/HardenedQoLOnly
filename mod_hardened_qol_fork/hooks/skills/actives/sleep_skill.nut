::Hardened.HooksMod.hook("scripts/skills/actives/sleep_skill", function(q) {
	// Vanilla Fix: alp tooltips not generating correctly when player controlled
	// Overwrite to remove the vanilla implementation, because it is redundant and calls getAIAgent() without checking its result, which causes problems on player controlled characters
	q.isUsable = @() function()
	{
		return this.skill.isUsable();
	}

	// Sleep can no longer be used on headless entities
	q.onVerifyTarget = @(__original) function( _originTile, _targetTile )
	{
		return __original(_originTile, _targetTile) && !_targetTile.getEntity().getSkills().hasSkill("effects.hd_headless");
	}
});
