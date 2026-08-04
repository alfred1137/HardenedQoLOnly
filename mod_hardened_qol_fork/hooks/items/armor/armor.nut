::Hardened.HooksMod.hookTree("scripts/items/armor/armor", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Condition = this.m.ConditionMax;		// We do this here so that it doesn't have to be done in the individual armor scripts anymore
	}

	q.onAddedToStash = @(__original) function( _stashID )
	{
		__original(_stashID);

		if (_stashID == "player")
		{
			if (::Hardened.Mod.ModSettings.getSetting("AutoRepairUpgradedArmor").getValue())
			{
				if (this.getUpgrade() != null)
				{
					this.setToBeRepaired(true);
				}
			}

			if (::Hardened.Mod.ModSettings.getSetting("AutoRepairNamedArmor").getValue())
			{
				if (this.isItemType(::Const.Items.ItemType.Named | ::Const.Items.ItemType.Legendary))
				{
					this.setToBeRepaired(true);
				}
			}
		}
	}

	q.onDamageReceived = @(__original) function( _damage, _fatalityType, _attacker )
	{
		// We switcheroo the Name, adding the current condition to it, so that the combat log will include the condition of the armor piece before the hit
		local oldName = this.m.Name;
		this.m.Name += " (" + this.getCondition() + ")";

		// Vanilla Fix: Hide tooltips about armor taking damage, when its actor is not visible to the player
		local oldlogEx = ::Tactical.EventLog.get().logEx;
		if (this.getContainer().getActor().isHiddenToPlayer())
		{
			::Tactical.EventLog.get().logEx = function(_text) {};
		}

		__original(_damage, _fatalityType, _attacker);

		this.m.Name = oldName;
		::Tactical.EventLog.get().logEx = oldlogEx;
	}

// Hardened Functions
	q.getShopAmountMax = @() function()
	{
		// Almost never do you need to buy the third armor of the same type. Buying the first two should be sufficient
		// By not generating the third this will prevent low tier and unneeded amounts of armor from spamming late-game shops
		return 2;
	}
});