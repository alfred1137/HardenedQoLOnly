// QoL-supporting defaults for ::Const.CharacterProperties.
// Upstream seeded these (and balance members) here; the purge stripped the whole file.
// KEPT code reads the members below — without them every clone of CharacterProperties
// throws "the index 'X' does not exist" whenever the read path runs (frenzy eyes at every
// spawn; hitchance overlay, ZOC call, shield/durability tooltips in combat/UI).
// Balance-only members (BagSlots, WeightStaminaMult, WeightInitiativeMult,
// ReachAdvantageMult, HD_ImmuneToChilled) and the
// getStamina/getVision/getClone function overrides are NOT restored — those
// features are purged; vanilla functions already exist.

// ShowFrenzyEyes: red glowing eyes (QoL visual). Flipped true by kept
// killing_frenzy_effect and berserker_mushrooms_effect hooks.
::Const.CharacterProperties.ShowFrenzyEyes <- false;

// QoL: headshot-aware hitchance (kept tooltip hooks in skill.nut and
// actor.nut call getHeadHitchance / rely on getHitchance delegating to it).
// Restore the members getHeadHitchance needs plus the getHitchance override
// that swaps it in when a Temp attacker/skill/target is set. Vanilla does
// NOT have any of these.
::Const.CharacterProperties.HeadshotReceivedChance <- 0;
::Const.CharacterProperties.HeadshotReceivedChanceMult <- 1.0;

{
	local oldGetHitChance = ::Const.CharacterProperties.getHitchance;
	::Const.CharacterProperties.getHitchance = function( _bodyPart )
	{
		if (::Hardened.Temp.UserWantingToHit == null)
		{
			return oldGetHitChance(_bodyPart);
		}
		else
		{
			return this.getHeadHitchance(_bodyPart, ::Hardened.Temp.UserWantingToHit, ::Hardened.Temp.SkillToBeHitWith, ::Hardened.Temp.TargetToBeHit);
		}
	}

	::Const.CharacterProperties.getHeadHitchance <- function( _bodyPart, _user = null, _skill = null, _target = null )
	{
		if (::MSU.isNull(_user) || ::MSU.isNull(_skill) || ::MSU.isNull(_target))
		{
			return oldGetHitChance(_bodyPart);
		}

		local defenderProps = _target.getSkills().buildPropertiesForDefense(_user, _skill);

		local headshotChance = this.HitChance[::Const.BodyPart.Head] + defenderProps.HeadshotReceivedChance;

		headshotChance *= this.HitChanceMult[::Const.BodyPart.Head];
		headshotChance *= defenderProps.HeadshotReceivedChanceMult;
		headshotChance = ::Math.min(100.0, ::Math.floor(headshotChance));

		if (_bodyPart == ::Const.BodyPart.Head)
		{
			return headshotChance;
		}
		else
		{
			return 100.0 - headshotChance;
		}
	}
}

// HD_HitChanceMax: per-actor hit chance cap, read by kept hitchance overlay
// (ShowUncappedHitchances) and api skill.nut MV_getHitchance.
::Const.CharacterProperties.HD_HitChanceMax <- ::Const.Combat.MV_HitChanceMax;

// CanExertZoneOfControl: read by kept actor ZOC helper.
::Const.CharacterProperties.CanExertZoneOfControl <- true;

// Shield durability math, read by kept api skill.nut getExpectedShieldDamageMult
// and weapon.nut durability-loss tooltip.
::Const.CharacterProperties.ShieldDamageMult <- 1.0;
::Const.CharacterProperties.ShieldDamageReceivedMult <- 1.0;
::Const.CharacterProperties.WeaponDurabilityLossMult <- 1.0;