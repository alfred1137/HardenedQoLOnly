// Feat: DS easter-egg active (port DS_round_swing / DS_split_shield)
this.hd_demolish_shield <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "actives.hd_demolish_shield";
		this.m.Name = "Demolish Shield";
		this.m.Description = "A concussive attack specifically aimed at destroying an opponent\'s shield. Can only be used against targets that carry a shield. Will always hit and stagger the target. Stuns targets whose shields are broken by this attack.";
		this.m.Icon = "skills/active_09.png";
		this.m.IconDisabled = "skills/active_09_sw.png";
		this.m.Overlay = "active_09";
		this.m.SoundOnHit = [
			"sounds/combat/split_shield_01.wav",
			"sounds/combat/split_shield_02.wav",
			"sounds/combat/split_shield_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsUsingHitchance = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsWeaponSkill = true;
		this.m.ActionPointCost = 7;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}

	function getTooltip()
	{
		local damage = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).getShieldDamage();

		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 3,
				type = "text",
				text = this.getCostString()
			}
		];
		ret.push({
			id = 7,
			type = "text",
			icon = "ui/icons/shield_damage.png",
			text = "Inflicts [color=" + this.Const.UI.Color.DamageValue + "]" + damage + "[/color] damage to shields"
		});
		
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Huge, Strong, Sword Mastery and Executioner each decrease AP cost by [color=" + this.Const.UI.Color.PositiveValue + "]1[/color] and Fatigue cost by [color=" + this.Const.UI.Color.PositiveValue + "]22%[/color]. Can stack (max 4 stacks)"
		});
		
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Always staggers on a hit. Also inflicts stun if the shield is broken by this attack"
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

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile))
		{
			return false;
		}

		return _targetTile.getEntity().isArmedWithShield();
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local shield = target.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);

		if (shield != null)
		{
			this.spawnAttackEffect(_targetTile, this.Const.Tactical.AttackEffectSplitShield);
			local damage = _user.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).getShieldDamage();

			local conditionBefore = shield.getCondition();
			shield.applyShieldDamage(damage);
			target.getSkills().add(this.new("scripts/skills/effects/staggered_effect"));

			if (shield.getCondition() == 0)
			{
				if (!_user.isHiddenToPlayer() && _targetTile.IsVisibleForPlayer)
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " uses Split Shield and destroys " + this.Const.UI.getColorizedEntityName(target) + "\'s shield");
					
					if (!target.getCurrentProperties().IsImmuneToStun)
					{
						target.getSkills().add(this.new("scripts/skills/effects/stunned_effect"));
					}
				}
			}
			else
			{
				if (this.m.SoundOnHit.len() != 0)
				{
					this.Sound.play(this.m.SoundOnHit[this.Math.rand(0, this.m.SoundOnHit.len() - 1)], this.Const.Sound.Volume.Skill, target.getPos());
				}

				if (!_user.isHiddenToPlayer() && _targetTile.IsVisibleForPlayer)
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " uses Split Shield and hits " + this.Const.UI.getColorizedEntityName(target) + "\'s shield for [b]" + (conditionBefore - shield.getCondition()) + "[/b] damage");
				}
			}

			if (!this.Tactical.getNavigator().isTravelling(target))
			{
				this.Tactical.getShaker().shake(target, _user.getTile(), 2, this.Const.Combat.ShakeEffectSplitShieldColor, this.Const.Combat.ShakeEffectSplitShieldHighlight, this.Const.Combat.ShakeEffectSplitShieldFactor, 1.0, [
					"shield_icon"
				], 1.0);
			}

			local overwhelm = this.getContainer().getSkillByID("perk.overwhelm");

			if (overwhelm != null)
			{
				overwhelm.onTargetHit(this, _targetTile.getEntity(), this.Const.BodyPart.Body, 0, 0);
			}
		}

		return true;
	}
});