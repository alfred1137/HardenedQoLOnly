this.hd_payoff_effect <- ::inherit("scripts/skills/skill", {
	m = {
		HitchanceModifier = 20,
		ArmorPenetrationPct = 0.2,
	},

	function create()
	{
		this.m.ID = "effects.hd_payoff";
		this.m.Name = "Payoff";
		this.m.Description = "Good timing can make all the difference.";
		this.m.Icon = "skills/hd_payoff_effect.png";
		this.m.Overlay = "hd_payoff_effect";
		this.m.Type = ::Const.SkillType.StatusEffect;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;

		this.m.HD_LastsForTurns = 1;
	}

	function getTooltip()
	{
		local ret = this.skill.getTooltip();

		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/melee_skill.png",
			text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizeValue(this.m.HitchanceModifier, {AddSign = true}) + " [$ $|Concept.MeleeSkill]"),
		});

		ret.push({
			id = 11,
			type = "text",
			icon = "ui/icons/ranged_skill.png",
			text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizeValue(this.m.HitchanceModifier, {AddSign = true}) + " [$ $|Concept.RangeSkill]"),
		});

		ret.push({
			id = 12,
			type = "text",
			icon = "ui/icons/direct_damage.png",
			text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizePct(this.m.ArmorPenetrationPct, {AddSign = true}) + " [$ $|Concept.ArmorPenetration]"),
		});

		return ret;
	}

	function onUpdate( _properties )
	{
		_properties.MeleeSkill += this.m.HitchanceModifier;
		_properties.RangedSkill += this.m.HitchanceModifier;
		_properties.DamageDirectAdd += this.m.ArmorPenetrationPct;
	}
});
