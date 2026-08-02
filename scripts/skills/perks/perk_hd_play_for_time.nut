this.perk_hd_play_for_time <- ::inherit("scripts/skills/skill", {
	m = {
		HD_MeleeDefenseModifier = 15,
		HD_RangedDefenseModifier = 15,
	},
	function create()
	{
		this.m.ID = "perk.hd_play_for_time";
		this.m.Name = ::Const.Strings.PerkName.HD_PlayForTime;
		this.m.Type = ::Const.SkillType.Perk;
		this.m.Order = ::Const.SkillOrder.Perk;
	}

	function onBeingAttacked( _attacker, _skill, _properties )
	{
		if (this.HD_isAttackerValid(_attacker))
		{
			_properties.MeleeDefense += this.m.HD_MeleeDefenseModifier;
			_properties.RangedDefense += this.m.HD_RangedDefenseModifier;
		}
	}

// MSU Functions
	function onGetHitFactorsAsTarget( _skill, _targetTile, _tooltip )
	{
		if (this.HD_isAttackerValid(_skill.getContainer().getActor()) && _skill.isAttack() && _skill.isUsingHitchance())
		{
			_tooltip.push({
				icon = "ui/tooltips/negative.png",
				text = ::MSU.Text.colorNegative((this.m.HD_MeleeDefenseModifier) + "% ") + ::Reforged.Mod.Tooltips.parseString(::Reforged.NestedTooltips.getNestedPerkName(this)),
			});
		};
	}

// New Functions
	function HD_isAttackerValid( _attacker )
	{
		if (_attacker.HD_isBleeding()) return true;
		if (_attacker.HD_isPoisoned()) return true;

		return false;
	}
});
