::Hardened.HooksMod.hook("scripts/skills/effects/charmed_effect", function (q) {
	q.getName = @(__original) function()
	{
		return __original() + " (x" + this.m.TurnsLeft + ")";
	}

	q.onAdded = @(__original) function()
	{
		__original();

		local actor = this.getContainer().getActor();
		if (!actor.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " is charmed for " + ::MSU.Text.colorPositive(this.m.TurnsLeft) + " turns");
		}
	}

	// QoL: temporarily charmed units are less likely to be targeted by their former allies
	q.onAfterUpdate = @(__original) function( _properties )
	{
		if (_properties.IsStunned)
		{
			_properties.TargetAttractionMult *= 0.1;
		}
		else
		{
			_properties.TargetAttractionMult *= 0.5;
		}
	}

	// QoL: reduce AI targeting priority for temporarily charmed units
	q.getQueryTargetValueMult = @(__original) function( _user, _target, _skill )
	{
		local ret = __original(_user, _target, _skill);

		local actor = this.getContainer().getActor();
		if (_target.getID() == actor.getID() && _user.getID() != _target.getID())
		{
			ret *= 0.8;
		}

		return ret;
	}
});
