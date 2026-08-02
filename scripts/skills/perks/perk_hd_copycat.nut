this.perk_hd_copycat <- ::inherit("scripts/skills/skill", {
	m = {
		HD_MeleeDefenseModifier = 15,
		HD_RangedDefenseModifier = 15,
	},
	function create()
	{
		this.m.ID = "perk.hd_copycat";
		this.m.Name = ::Const.Strings.PerkName.HD_Copycat;
		this.m.Icon = "ui/perks/perk_rf_swordmaster_versatile_swordsman.png";	// Todo:
		this.m.Type = ::Const.SkillType.Perk;
		this.m.Order = ::Const.SkillOrder.Perk;
	}

	function onTurnStart()
	{
		local discoveredWeaponTypes = [];

		local actor = this.getContainer().getActor();
		foreach (nextTile in ::MSU.Tile.getNeighbors(actor.getTile()))
		{
			if (!nextTile.IsOccupiedByActor) continue;

			local nextEntity = nextTile.getEntity();
			if (!this.HD_isActorValid(nextEntity)) continue;

			local mainhandItem = nextEntity.getMainhandItem();
			if (mainhandItem == null || !mainhandItem.isItemType(::Const.Items.ItemType.Weapon)) continue;

			foreach (weaponType in mainhandItem.HD_getWeaponTypesAsArray())
			{
				discoveredWeaponTypes.push({
					Type = weaponType,
					Owner = nextEntity,
				});
			}
		}
		if (discoveredWeaponTypes.len() == 0) return;	// We have not found any weapontype nearby

		local chosenWeaponType = this.HD_getRandomWeaponType(discoveredWeaponTypes);
		if (chosenWeaponType == null) return;	// None of the weapon types found nearby belong to any perk group

		this.HD_imitateWeaponType(chosenWeaponType.Type, chosenWeaponType.Owner);
	}

// New Functions
	function HD_isActorValid( _actor )
	{
		return true;	// Currently we allow allies and enemies
	}

	function HD_getRandomWeaponType( _discoveredWeaponTypeInfoArray )
	{
		local possibleWeaponTypes = [];
		foreach (weaponTypeInfo in _discoveredWeaponTypeInfoArray )
		{
			if (this.HD_hasRelatedPerkGroup(weaponTypeInfo.Type))
			{
				possibleWeaponTypes.push(weaponTypeInfo);
			}
		}
		if (possibleWeaponTypes.len() == 0) return null;

		return ::MSU.Array.rand(possibleWeaponTypes);
	}

	function HD_hasRelatedPerkGroup( _weaponType )
	{
		local imitatingSkill = ::new("scripts/skills/effects/hd_imitating_effect");
		return imitatingSkill.getPerkGroupForWeaponType(_weaponType) != null;
	}

	function HD_imitateWeaponType( _weaponType, _chosenNeighbor )
	{
		local imitatingSkill = ::new("scripts/skills/effects/hd_imitating_effect");
		imitatingSkill.m.ChosenWeaponType = _weaponType;
		this.getContainer().add(imitatingSkill);

		local actor = this.getContainer().getActor();
		if (!actor.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " imitates the " + ::Const.Items.getWeaponTypeName(_weaponType) + " from " + ::Const.UI.getColorizedEntityName(_chosenNeighbor));
		}
	}
});
