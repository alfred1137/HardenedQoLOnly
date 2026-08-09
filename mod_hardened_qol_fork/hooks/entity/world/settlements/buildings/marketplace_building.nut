// Feat: Dragonslayer easter egg — marketplace stock (gated by MSU setting)
// Mimics Crock_Pot's cp_marketplace pattern: extend getDefaultShopList with {R, P, S} entries.

::Hardened.HooksMod.hook("scripts/entity/world/settlements/buildings/marketplace_building", function(q) {
	q.getDefaultShopList = @(__original) function()
	{
		local list = __original();
		if (::Hardened.Mod.ModSettings.getSetting("DragonslayerEasterEgg").getValue())
		{
			// Exotic import: extremely rare (R=99.5 ~0.5% per refresh) and overpriced (P=1.5)
			list.push({
				R = 99.5,
				P = 1.5,
				S = "weapons/hd_dragonslayer"
			});
		}
		return list;
	}
});