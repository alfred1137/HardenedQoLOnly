::Hardened.HooksMod.hookTree("scripts/items/item", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Condition = ::Math.minf(this.m.Condition, this.m.ConditionMax);	// Prevent Condition from ever being larger than ConditionMax
	}

// Hardened Functions
	q.getRarityMult = @(__original) function( _settlement = null )
	{
		local ret = __original();

		if (_settlement != null)
		{
			if (this.isBuildingSupply())
			{
				ret *= _settlement.getModifiers().BuildingRarityMult;
			}

			if (this.isMedical())
			{
				ret *= _settlement.getModifiers().MedicalRarityMult;
			}

			if (this.isMineral())
			{
				ret *= _settlement.getModifiers().MineralRarityMult;
			}
		}

		return ret;
	}

// New Functions
	// Trigger an unequip and equip of this item, without changing the slot it is in
	// Keep all skills attached, which are marked as HD_IsConnectedBuff == true
	// This can be used to refresh an items potential interactions with various effects and perks, after a new effect has just been added.
	//	For example if that skill modifies the itemtypes on this item
	q.HD_refreshItem <- function()
	{
		// First we need to move all skills we wanna keep out of this.m.SkillPtrs so they are not removed
		local preservedSkills = [];
		for (local i = this.m.SkillPtrs.len() - 1; i >= 0; --i)
		{
			local skillRef = this.m.SkillPtrs[i];
			if (skillRef.m.HD_IsConnectedBuff)
			{
				preservedSkills.push(skillRef);
				this.m.SkillPtrs.remove(i);
			}
		}

		local actor = this.getContainer().getActor();
		actor.getItems().unequip(this);
		actor.getItems().equip(this);

		this.m.SkillPtrs.extend(preservedSkills);
	}

	// Similar to addSkill()
	// A connected buff is a skill that is connected to this item and expected to be wiped when the item becomes unequipped
	// However it must survive an Item Refresh (see HD_refreshItem), which is not a real unequip
	q.HD_addConnectedBuff <- function( _connectedBuff )
	{
		_connectedBuff.m.HD_IsConnectedBuff = true;
		this.addSkill(_connectedBuff);
	}

// New Events
	// Triggers directly after unEquipping this item, after all connections to the item container have been severed
	// This can be used by items which trigger updates on other entities, whose effects might rely on the equip-state of this item
	q.HD_onAfterUnEquip <- function()
	{
	}
});