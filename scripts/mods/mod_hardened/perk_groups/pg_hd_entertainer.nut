this.pg_hd_entertainer <- ::inherit(::DynamicPerks.Class.PerkGroup, {
	m = {},
	function create()
	{
		this.m.ID = "pg.hd_entertainer";
		this.m.Name = "Entertainer";	// maybe Performer
		this.m.Icon = "ui/backgrounds/background_14.png";
		this.m.Tree = [
			[
				"perk.rf_cheap_trick",
			],
			[],
			[],
			[],
			[
				"perk.hd_set_up",
			],
			[],
			[
				"perk.hd_copycat",
			],
		];
	}
});
