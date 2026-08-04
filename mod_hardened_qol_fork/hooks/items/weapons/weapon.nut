::Hardened.HooksMod.hook("scripts/items/weapons/weapon", function(q) {
	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		// We delete the Reforged entry about "Applicable masteries" as that whole system is no longer relevant under Hardened
		// We delete the Reforged entry about "Free Dagger Swaps" as that whole system is no longer relevant under Hardened
		::Hardened.util.HD_deleteBulletPoint(ret, function(_entry) {
			return (_entry.id == 20 || _entry.id == 30) && (_entry.icon == "ui/icons/special.png");
		});

		foreach (entry in ret)
		{
			if (entry.id == 64 && entry.icon == "ui/icons/direct_damage.png")
			{
				// Improve wording and add Hyperlink for Armor Penetration
				entry.text = ::MSU.String.replace(entry.text, "of damage ignores armor", ::Reforged.Mod.Tooltips.parseString("[$ $|Concept.ArmorPenetration]"));
			}
			else if (entry.id == 9 && entry.icon == "ui/icons/chance_to_hit_head.png")
			{
				// Vanilla does not show the maximum ammunition. We now also color the remaining ammunition in the negative color if it is 0
				entry.text =  ::Reforged.Mod.Tooltips.parseString("[Chance to hit head|Concept.ChanceToHitHead]: ") + ::MSU.Text.colorizeValue(this.m.ChanceToHitHead, {AddSign = true, AddPercent = true});
			}
			else if (entry.id == 10 && entry.icon == "ui/icons/ammo.png")
			{
				// Vanilla does not show the maximum ammunition. We now also color the remaining ammunition in the negative color if it is 0
				entry.text = "Remaining Ammo: " + ::MSU.Text.colorizeValue(this.getAmmo(), {CompareTo = 1}) + " / " + this.getAmmoMax();
			}
			else if (entry.id == 5 && entry.icon == "ui/icons/armor_damage.png")
			{
				// Improve wording for Armor Damage
				entry.text = ::MSU.String.replace(entry.text, "effective against armor", "Armor Damage");

				// Vanilla Fix: Improve accuracy of shown values by removing rounding and flooring
				entry.text = entry.text.slice(entry.text.find("%[/color]") + 9, entry.text.len());	// Remove the vanilla damage number representation at the start
				entry.text = ::MSU.Text.colorizePct(this.m.ArmorDamageMult, {InvertColor = true}) + entry.text;
			}
			else if (entry.id == 8 && entry.icon == "ui/icons/fatigue.png" && entry.text.find("Weapon skills build up") != null)
			{
				// Vanilla: Weapon skills build up +-X more/less fatigue
				// We shorten the tooltip a bit and add a hyperlink
				entry.text = "Weapon Skills cost " + ::MSU.Text.colorizeValue(this.m.FatigueOnSkillUse, {AddSign = true, InvertColor = true}) + ::Reforged.Mod.Tooltips.parseString(" [Fatigue|Concept.Fatigue]");
			}
			else if (entry.id == 20 && entry.icon == "ui/icons/rf_reach.png")
			{
				entry.text = ::Reforged.Mod.Tooltips.parseString("[Reach|Concept.Reach]: ") + this.m.Reach;
			}
		}

		return ret;
	}

	q.consumeAmmo = @(__original) function()
	{
		__original();

		local actor = this.getContainer().getActor();
		if (this.getAmmo() == 0 && actor.isPlayerControlled() && actor.isPlacedOnMap())
		{
			local tile = actor.getTile();
			if (tile.IsVisibleForPlayer)
			{
				::Tactical.spawnIconEffect("status_effect_63", tile, ::Const.Tactical.Settings.SkillIconOffsetX, ::Const.Tactical.Settings.SkillIconOffsetY, ::Const.Tactical.Settings.SkillIconScale, ::Const.Tactical.Settings.SkillIconFadeInDuration, ::Const.Tactical.Settings.SkillIconStayDuration, ::Const.Tactical.Settings.SkillIconFadeOutDuration, ::Const.Tactical.Settings.SkillIconMovement);
			}
		}
	}

	q.lowerCondition = @(__original) function( _value = ::Const.Combat.WeaponDurabilityLossOnHit )
	{
		// We only drop the weapon when it has 0 condition BEFORE the condition loss
		local actor = this.getContainer().getActor();
		if (this.m.Condition == 0)
		{
			if (!actor.isHiddenToPlayer())
			{
				::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + "\'s " + this.getName() + " has broken!");
				::Tactical.spawnIconEffect("status_effect_36", actor.getTile(), ::Const.Tactical.Settings.SkillIconOffsetX, ::Const.Tactical.Settings.SkillIconOffsetY, ::Const.Tactical.Settings.SkillIconScale, ::Const.Tactical.Settings.SkillIconFadeInDuration, ::Const.Tactical.Settings.SkillIconStayDuration,::Const.Tactical.Settings.SkillIconFadeOutDuration, ::Const.Tactical.Settings.SkillIconMovement);
				::Sound.play(this.m.BreakingSound, 1.0, actor.getPos());
			}

			::Time.scheduleEvent(::TimeUnit.Virtual, 150, this.onDelayedRemoveSelf, null);	// In Vanilla this delay is 300. I find it a bit too long
		}

		// We mock the next isHiddenToPlayer call to return true, so that the vanilla weapon break/drop mechanic is skipped
		local mockObject = ::Hardened.mockFunction(actor, "isHiddenToPlayer", function() {
			return { done = true, value = true };
		});

		__original(_value);

		mockObject.cleanup();
	}

// MSU Functions
	q.buildCategoriesFromWeaponType = @(__original) function()
	{
		__original();
		this.m.Categories = ::MSU.String.replace(this.m.Categories, "/", "/[wbr][/wbr]", true);
	}
});

::Hardened.HooksMod.hookTree("scripts/items/weapons/weapon", function(q) {
	q.create = @(__original) function()
	{
		__original();

		this.m.Condition = this.m.ConditionMax;		// We do this here so that it doesn't have to be done in the individual weapon scripts anymore
	}

	q.onEquip = @(__original) function( _item )
	{
		if (!("IsLoaded" in this)) return __original();

		local oldIsLoaded = this.m.IsLoaded;
		if (_item.isWeaponType(::Const.Items.WeaponType.Crossbow) || _item.isWeaponType(::Const.Items.WeaponType.Firearm))
		{
			// Setting this to true prevents Vanilla and any mod from adding an additional redundant reload_bolt skill to this actor
			this.m.IsLoaded = true;
		}

		__original();

		this.m.IsLoaded = oldIsLoaded;
	}
});