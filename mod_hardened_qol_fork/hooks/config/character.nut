// QoL-supporting defaults for ::Const.CharacterProperties.
// Upstream seeded these (and balance members) here; the purge stripped the whole file.
// KEPT code reads the members below — without them every clone of CharacterProperties
// throws "the index 'X' does not exist" whenever the read path runs (frenzy eyes at every
// spawn; hitchance overlay, ZOC call, shield/durability tooltips in combat/UI).
// Balance-only members (BagSlots, WeightStaminaMult, WeightInitiativeMult,
// ReachAdvantageMult, HD_ImmuneToChilled, HeadshotReceivedChance*) and the
// getHitchance/getHeadHitchance/getStamina/getVision/getClone function overrides are NOT
// restored — those features are purged; vanilla functions already exist.

// ShowFrenzyEyes: red glowing eyes (QoL visual). Flipped true by kept
// killing_frenzy_effect and berserker_mushrooms_effect hooks.
::Const.CharacterProperties.ShowFrenzyEyes <- false;

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