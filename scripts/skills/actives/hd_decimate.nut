// Feat: DS easter-egg active (port DS_round_swing / DS_split_shield)
this.hd_decimate <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "actives.hd_decimate";
		this.m.Name = "Decimate";
		this.m.Description = "Mow down all the targets around you, foe and friend alike, with a reckless round swing. Not hard to evade because it is rather slow, but can be devastating if it connects. Be careful around your own men unless you want to relieve your payroll!";
		this.m.KilledString = "Carved up";
		this.m.Icon = "skills/active_100.png";
		this.m.IconDisabled = "skills/active_100_sw.png";
		this.m.Overlay = "active_100";
		this.m.SoundOnUse = [
			"sounds/combat/round_swing_01.wav",
			"sounds/combat/round_swing_02.wav",
			"sounds/combat/round_swing_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/round_swing_hit_01.wav",
			"sounds/combat/round_swing_hit_02.wav",
			"sounds/combat/round_swing_hit_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsAOE = true;
		this.m.IsWeaponSkill = true;
		this.m.InjuriesOnBody = this.Const.Injury.CuttingBody;
		this.m.InjuriesOnHead = this.Const.Injury.CuttingHead;
		this.m.HitChanceBonus = -15;
		this.m.DirectDamageMult = 0.4;
		this.m.ActionPointCost = 7;
		this.m.FatigueCost = 35;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.ChanceDecapitate = 99;
		this.m.ChanceDisembowel = 75;
		this.m.ChanceSmash = 0;
	}

	function getTooltip()
	{
		local ret = this.getDefaultTooltip();

		ret.extend([
			{
				id = 9,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Can hit up to 6 targets"
			},
			{
				id = 6,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Huge, Strong, Sword Mastery and Executioner each decrease AP cost by [color=" + this.Const.UI.Color.PositiveValue + "]1[/color] and Fatigue cost by [color=" + this.Const.UI.Color.PositiveValue + "]22%[/color]. Can stack (max 4 stacks)"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/hitchance.png",
				text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-15%[/color] chance to hit"
			}
		]);
		return ret;
	}

	function onAfterUpdate( _properties )
	{
		local conditions = 0;

		if (this.getContainer().getActor().getCurrentProperties().IsSpecializedInSwords) conditions++;
		if (this.getContainer().getActor().getSkills().hasSkill("trait.huge")) conditions++;
		if (this.getContainer().getActor().getSkills().hasSkill("trait.strong")) conditions++;
		if (this.getContainer().getActor().getSkills().hasSkill("background.executioner")) conditions++;

		if (conditions == 1)
		{
			this.m.FatigueCostMult = 0.78;
			this.m.ActionPointCost = 6;
		}
		else if (conditions == 2)
		{
			this.m.FatigueCostMult = 0.55;
			this.m.ActionPointCost = 5;
		}
		else if (conditions >= 3)
		{
			this.m.FatigueCostMult = 0.33;
			this.m.ActionPointCost = 4;
		}
	}

	function onUse( _user, _targetTile )
	{
		local ret = false;
		local ownTile = this.m.Container.getActor().getTile();
		local soundBackup = [];
		this.spawnAttackEffect(ownTile, this.Const.Tactical.AttackEffectThresh);

		for( local i = 5; i >= 0; i = i )
		{
			if (!ownTile.hasNextTile(i))
			{
			}
			else
			{
				local tile = ownTile.getNextTile(i);

				if (!tile.IsEmpty && tile.getEntity().isAttackable() && this.Math.abs(tile.Level - ownTile.Level) <= 1)
				{
					if (ret && soundBackup.len() == 0)
					{
						soundBackup = this.m.SoundOnHit;
						this.m.SoundOnHit = [];
					}

					ret = this.attackEntity(_user, tile.getEntity()) || ret;

					if (!_user.isAlive() || _user.isDying())
					{
						break;
					}
				}
			}

			i = --i;
		}

		if (ret && this.m.SoundOnHit.len() == 0)
		{
			this.m.SoundOnHit = soundBackup;
		}

		return ret;
	}

	function onTargetSelected( _targetTile )
	{
		local ownTile = this.m.Container.getActor().getTile();

		for( local i = 0; i != 6; i = i )
		{
			if (!ownTile.hasNextTile(i))
			{
			}
			else
			{
				local tile = ownTile.getNextTile(i);

				if (this.Math.abs(tile.Level - ownTile.Level) <= 1)
				{
					this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, tile, tile.Pos.X, tile.Pos.Y);
				}
			}

			i = ++i;
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill -= 15;
		}
	}

});