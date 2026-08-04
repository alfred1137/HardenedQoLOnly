::Hardened.HooksMod.hook("scripts/skills/actives/fire_handgonne_skill", function(q) {
	q.m.HD_UsableWhileEngagedInMelee = false;

	// Overwrite, because we prevent Vanilla from adding the reload skill whenever this skill is used
	// Because of stack-based-skills, those additional reloads, clog up the skill UI list otherwise
	q.onUse = @(__original) function( _user, _targetTile )
	{
		// We prevent Vanilla from adding the reload skill at this point, as in Hardened it is always present
		local mockObject = ::Hardened.mockFunction(this.getContainer(), "add", function( _skillToAdd ) {
			if (_skillToAdd.getID() == "actives.reload_handgonne")
			{
				// We just prevent this skill addition, nothing more
				return { done = true, value = null };
			}
		});

		local ret = __original(_user, _targetTile);

		mockObject.cleanup();

		return ret;
	}

	q.onAdded = @(__original) function()
	{
		__original();

		// Don't add skill for the dummy player to prevent duplicate reload skills
		if (!::MSU.isEqual(this.getContainer().getActor(), ::MSU.getDummyPlayer()))
		{
			this.getItem().addSkill(::new("scripts/skills/actives/reload_handgonne_skill"));
		}
	}
});
