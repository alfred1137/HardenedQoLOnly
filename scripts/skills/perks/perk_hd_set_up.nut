this.perk_hd_set_up <- ::inherit("scripts/skills/skill", {
	m = {
	},
	function create()
	{
		this.m.ID = "perk.hd_set_up";
		this.m.Name = ::Const.Strings.PerkName.HD_SetUp;
		this.m.Type = ::Const.SkillType.Perk;
		this.m.Order = ::Const.SkillOrder.Perk;
	}

	function onWaitTurn()
	{
		this.getContainer().add(::new("scripts/skills/effects/hd_payoff_effect"));
		this.moveUsToSixthPosition();
	}

// New Functions
	function moveUsToSixthPosition()
	{
		// We were only pushed back at most 6 positions. We don't need to do anything
		if (::Tactical.TurnSequenceBar.m.CurrentEntities.len() <= ::Tactical.TurnSequenceBar.m.MaxVisibleEntities)
		{
			return;
		}

		::Tactical.TurnSequenceBar.m.CurrentEntities.pop();
		local actor = this.getContainer().getActor();
		::Tactical.TurnSequenceBar.m.CurrentEntities.insert(::Tactical.TurnSequenceBar.m.MaxVisibleEntities - 1, actor);

		local entityToAddIndex = ::Math.min(::Tactical.TurnSequenceBar.m.CurrentEntities.len() - 1, ::Tactical.TurnSequenceBar.m.MaxVisibleEntities - 1);
		local mockObject;
		mockObject = ::Hardened.mockFunction(::Tactical.TurnSequenceBar, "convertEntityToUIData", function( _entity, _isLastEntity = false ) {
			if (_entity.getID() == actor.getID())
			{
				return { done = true, value = mockObject.original(actor, true) };
			}
		});
		// We have no chance to manually clean up from inside this skill
		// But we don't need to clean up, because "convertEntityToUIData" is guaranteed to run, directly after the onWaitTurn event triggers and then the mockObject cleans up itself
	}
});
