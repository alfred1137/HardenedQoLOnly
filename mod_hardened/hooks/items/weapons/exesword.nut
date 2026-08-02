::Hardened.HooksMod.hook("scripts/items/weapons/exesword", function(q) {
	q.create = @(__original) function()
	{
		__original();

		this.m.ShieldDamage = 32;		// Vanilla: 16
		this.m.StaminaModifier = -26;	// Vanilla -12
		this.m.RegularDamage = 130;		// Vanilla: 95
		this.m.RegularDamageMax = 140;	// Vanilla: 110

		this.m.ArmorDamageMult = 1.2;	// Vanilla: 0.9
		this.m.DirectDamageMult = 0.25;	// Vanilla: 0.35
		this.m.ChanceToHitHead = 0;		// Vanilla: 5

		this.m.AdditionalAccuracy = -15;	// Vanilla: 0
	}
});
