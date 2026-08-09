// Feat: Dragonslayer easter-egg active skill (port DS_split / DS_shatter)
this.hd_steel_crescent <- this.inherit("scripts/skills/skill", {
	m = {
		TilesUsed = []
	},
	function create()
	{
		this.m.ID = "actives.hd_steel_crescent";
		this.m.Name = "Steel Crescent";
		this.m.Description = "Swing the weapon in a wide arc that hits three adjacent tiles in counter-clockwise order. A target hit may get staggered from the force of the blow. Be careful around your own men unless you want to relieve your payroll!";
		this.m.KilledString = "Crushed";
		this.m.Icon = "skills/active_06.png";
		this.m.IconDisabled = "skills/active_06_sw.png";
		this.m.Overlay = "active_06";
		this.m.SoundOnUse = [
			"sounds/combat/swing_01.wav",
			"sounds/combat/swing_02.wav",
			"sounds/combat/swing_03.wav"
		];
		this.m.SoundOnHitHitpoints = [
			"sounds/combat/swing_hit_01.wav",
			"sounds/combat/swing_hit_02.wav",
			"sounds/combat/swing_hit_03.wav"
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
		this.m.HitChanceBonus = -10;
		this.m.DirectDamageMult = 0.4;
		this.m.ActionPointCost = 7;
		this.m.FatigueCost = 30;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.ChanceDecapitate = 99;
		this.m.ChanceDisembowel = 70;
		this.m.ChanceSmash = 0;
	}

	function getTooltip()
	{
		local ret = this.getDefaultTooltip();

		ret.extend([
			{
				id = 8,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Has a [color=" + this.Const.UI.Color.PositiveValue + "]50%[/color] chance to stagger on a hit"
			},
			{
				id = 9,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Can hit up to 3 targets"
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
				text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-10%[/color] chance to hit"
			}
		]);
		return ret;
	}

	function applyEffectToTarget( _user, _target, _targetTile )
	{
		local applyEffect = this.Math.rand(1, 2);

		if (applyEffect == 1)
		{
			if (_target.isNonCombatant())
			{
				return;
			}
			if (!_target.getSkills().hasSkill("effects.staggered"))
			{
				_target.getSkills().add(this.new("scripts/skills/effects/staggered_effect"));
			}

			if (!_user.isHiddenToPlayer() && _targetTile.IsVisibleForPlayer)
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " has staggered " + this.Const.UI.getColorizedEntityName(_target) + " for one turn");
			}
		}
		else
		{
			return;
		}
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
		this.m.TilesUsed = [];
		this.spawnAttackEffect(_targetTile, this.Const.Tactical.AttackEffectSwing);
		local ret = false;
		local ownTile = _user.getTile();
		local dir = ownTile.getDirectionTo(_targetTile);
		local target = _targetTile.getEntity();
		ret = this.attackEntity(_user, target);

		if (!_user.isAlive() || _user.isDying())
		{
			return ret;
		}

		if (ret && _targetTile.IsOccupiedByActor && target.isAlive() && !target.isDying())
		{
			this.applyEffectToTarget(_user, target, _targetTile);
		}

		local nextDir = dir - 1 >= 0 ? dir - 1 : this.Const.Direction.COUNT - 1;

		if (ownTile.hasNextTile(nextDir))
		{
			local nextTile = ownTile.getNextTile(nextDir);
			local success = false;

			if (nextTile.IsOccupiedByActor && nextTile.getEntity().isAttackable() && this.Math.abs(nextTile.Level - ownTile.Level) <= 1)
			{
				success = this.attackEntity(_user, nextTile.getEntity());
			}

			if (!_user.isAlive() || _user.isDying())
			{
				return success;
			}

			if (success && nextTile.IsOccupiedByActor && nextTile.getEntity().isAlive() && !nextTile.getEntity().isDying())
			{
				this.applyEffectToTarget(_user, nextTile.getEntity(), nextTile);
			}

			ret = success || ret;
		}

		nextDir = nextDir - 1 >= 0 ? nextDir - 1 : this.Const.Direction.COUNT - 1;

		if (ownTile.hasNextTile(nextDir))
		{
			local nextTile = ownTile.getNextTile(nextDir);
			local success = false;

			if (nextTile.IsOccupiedByActor && nextTile.getEntity().isAttackable() && this.Math.abs(nextTile.Level - ownTile.Level) <= 1)
			{
				success = this.attackEntity(_user, nextTile.getEntity());
			}

			if (!_user.isAlive() || _user.isDying())
			{
				return success;
			}

			if (success && nextTile.IsOccupiedByActor && nextTile.getEntity().isAlive() && !nextTile.getEntity().isDying())
			{
				this.applyEffectToTarget(_user, nextTile.getEntity(), nextTile);
			}

			ret = success || ret;
		}

		this.m.TilesUsed = [];
		return ret;
	}

	function onTargetSelected( _targetTile )
	{
		local ownTile = this.m.Container.getActor().getTile();
		local dir = ownTile.getDirectionTo(_targetTile);
		this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, _targetTile, _targetTile.Pos.X, _targetTile.Pos.Y);
		local nextDir = dir - 1 >= 0 ? dir - 1 : this.Const.Direction.COUNT - 1;

		if (ownTile.hasNextTile(nextDir))
		{
			local nextTile = ownTile.getNextTile(nextDir);

			if (this.Math.abs(nextTile.Level - ownTile.Level) <= 1)
			{
				this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, nextTile, nextTile.Pos.X, nextTile.Pos.Y);
			}
		}

		nextDir = nextDir - 1 >= 0 ? nextDir - 1 : this.Const.Direction.COUNT - 1;

		if (ownTile.hasNextTile(nextDir))
		{
			local nextTile = ownTile.getNextTile(nextDir);

			if (this.Math.abs(nextTile.Level - ownTile.Level) <= 1)
			{
				this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, nextTile, nextTile.Pos.X, nextTile.Pos.Y);
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill -= 10;
		}
	}

});