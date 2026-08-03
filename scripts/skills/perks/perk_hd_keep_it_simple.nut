this.perk_hd_keep_it_simple <- ::inherit("scripts/skills/skill", {
	m = {
		HD_HitChanceModifier = 10,
		HD_DefenseModifier = -5,
	},
	function create()
	{
		this.m.ID = "perk.hd_keep_it_simple";
		this.m.Name = ::Const.Strings.PerkName.HD_KeepItSimple;
		this.m.Icon = "ui/perks/perk_hd_keep_it_simple.png";
		this.m.Type = ::Const.SkillType.Perk;
		this.m.Order = ::Const.SkillOrder.Perk;
	}

	function onUpdate( _properties )
	{
		_properties.MeleeSkill += this.m.HD_HitChanceModifier;
		_properties.RangedSkill += this.m.HD_HitChanceModifier;
		_properties.MeleeDefense += this.m.HD_DefenseModifier;
		_properties.RangedDefense += this.m.HD_DefenseModifier;
	}
});
