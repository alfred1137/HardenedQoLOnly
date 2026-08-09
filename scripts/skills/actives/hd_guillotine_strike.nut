// Feat: Dragonslayer easter-egg active skill (port DS_split / DS_shatter)
this.hd_guillotine_strike <- this.inherit("scripts/skills/skill", {
	m = {
		ApplyBonusToBodyPart = -1	
	},
	function create()
	{
		this.m.ID = "actives.hd_guillotine_strike";
		this.m.Name = "Guillotine Strike";
		this.m.Description = "A slow overhead attack performed with full force to split a target in two from top to bottom. Can hit second target in a straight line due to weapon's size.";
		this.m.KilledString = "Split in two";
		this.m.Icon = "skills/active_07.png";
		this.m.IconDisabled = "skills/active_07_sw.png";
		this.m.Overlay = "active_07";
		this.m.SoundOnUse = [
			"sounds/combat/split_01.wav",
			"sounds/combat/split_02.wav",
			"sounds/combat/split_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/split_hit_01.wav",
			"sounds/combat/split_hit_02.wav",
			"sounds/combat/split_hit_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsIgnoredAsAOO = false;
		this.m.IsAOE = true;
		this.m.IsWeaponSkill = true;
		this.m.InjuriesOnBody = this.Const.Injury.CuttingBody;
		this.m.InjuriesOnHead = this.Const.Injury.CuttingHead;
		this.m.DirectDamageMult = 0.4;
		this.m.ActionPointCost = 7;
		this.m.FatigueCost = 30;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.ChanceDecapitate = 99;
		this.m.ChanceDisembowel = 75;
		this.m.ChanceSmash = 0;
	}

	function getTooltip()
	{
		local ret = this.getDefaultTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Can hit up to 2 targets"
		});
		
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Staggers first target and hits both to its head and body for additional damage"
		});
		
		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Huge, Strong, Sword Mastery and Executioner each decrease AP cost by [color=" + this.Const.UI.Color.PositiveValue + "]1[/color] and Fatigue cost by [color=" + this.Const.UI.Color.PositiveValue + "]22%[/color]. Can stack (max 3 stacks)"
		});

		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/hitchance.png",
			text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-5%[/color] chance to hit"
		});
		
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
		this.spawnAttackEffect(_targetTile, this.Const.Tactical.AttackEffectSplit);
		local targetEntity = _targetTile.getEntity();
		local ret = this.attackEntity(_user, _targetTile.getEntity());

		if (!_user.isAlive() || _user.isDying())
		{
			return ret;
		}
		
		if (ret && this.m.ApplyBonusToBodyPart != -1 && !_targetTile.IsEmpty && targetEntity.isAlive())
		{
			local p = this.getContainer().buildPropertiesForUse(this, targetEntity);
			local hitInfo = clone this.Const.Tactical.HitInfo;
			local damageRegular = this.Math.rand(p.DamageRegularMin, p.DamageRegularMax) * p.DamageRegularMult * 0.5;
			local damageArmor = this.Math.rand(p.DamageRegularMin, p.DamageRegularMax) * p.DamageArmorMult * 0.5;
			local damageDirect = this.Math.minf(1.0, p.DamageDirectMult * (this.m.DirectDamageMult + p.DamageDirectAdd + p.DamageDirectMeleeAdd));
			hitInfo.DamageRegular = damageRegular;
			hitInfo.DamageArmor = damageArmor;
			hitInfo.DamageDirect = damageDirect;
			hitInfo.BodyPart = this.m.ApplyBonusToBodyPart;
			hitInfo.BodyDamageMult = 1.0;
			local damageDirect = this.Math.minf(1.0, p.DamageDirectMult * (this.m.DirectDamageMult + p.DamageDirectAdd));
			hitInfo.DamageDirect = damageDirect;
			targetEntity.onDamageReceived(this.getContainer().getActor(), this, hitInfo);
			this.m.ApplyBonusToBodyPart = -1;

			local applyEffect = this.Math.rand(1, 2);
			if (applyEffect == 1)
			{
				if (!targetEntity.isNonCombatant())
				{
					if (!targetEntity.getSkills().hasSkill("effects.staggered"))
					{
						targetEntity.getSkills().add(this.new("scripts/skills/effects/staggered_effect"));
					}

					if (!_user.isHiddenToPlayer() && _targetTile.IsVisibleForPlayer)
					{
						this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " has staggered " + this.Const.UI.getColorizedEntityName(targetEntity) + " for one turn");
					}
				}
			}
		}

		local ownTile = _user.getTile();
		local dir = ownTile.getDirectionTo(_targetTile);

		if (_targetTile.hasNextTile(dir))
		{
			local forwardTile = _targetTile.getNextTile(dir);

			if (forwardTile.IsOccupiedByActor && forwardTile.getEntity().isAttackable() && this.Math.abs(forwardTile.Level - ownTile.Level) <= 1)
			{
				ret = this.attackEntity(_user, forwardTile.getEntity()) || ret;
			}
		}

		return ret;
	}
	
	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill == this)
		{
			this.m.ApplyBonusToBodyPart = _bodyPart == this.Const.BodyPart.Body ? this.Const.BodyPart.Head : this.Const.BodyPart.Body;
		}
	}

	function onTargetSelected( _targetTile )
	{
		this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, _targetTile, _targetTile.Pos.X, _targetTile.Pos.Y);
		local ownTile = this.m.Container.getActor().getTile();
		local dir = ownTile.getDirectionTo(_targetTile);

		if (_targetTile.hasNextTile(dir))
		{
			local forwardTile = _targetTile.getNextTile(dir);

			if (this.Math.abs(forwardTile.Level - ownTile.Level) <= 1)
			{
				this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, forwardTile, forwardTile.Pos.X, forwardTile.Pos.Y);
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill -= 5;
			_properties.DamageTooltipMinMult *= 1.5;
			_properties.DamageTooltipMaxMult *= 1.5;
		}
	}

});