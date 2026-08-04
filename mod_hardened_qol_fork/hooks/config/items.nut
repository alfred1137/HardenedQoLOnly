{	// MSU Config
	::Const.Items.ItemTypeName[::MSU.Math.log2int(::Const.Items.ItemType.Ammo) + 1] = "Ammunition";
	::Const.Items.ItemTypeName[::MSU.Math.log2int(::Const.Items.ItemType.Accessory) + 1] = "Accessory";
	::Const.Items.ItemTypeName[::MSU.Math.log2int(::Const.Items.ItemType.Food) + 1] = "Food";
	::Const.Items.ItemTypeName[::MSU.Math.log2int(::Const.Items.ItemType.Usable) + 1] = "Consumable";
	::Const.Items.ItemTypeName[::MSU.Math.log2int(::Const.Items.ItemType.Quest) + 1] = "Quest Item";

	for (local i = 0; i < ::Const.Items.WeaponType.len(); ++i)
	{
		if (::Const.Items.WeaponTypeName[i] == "Throwing Weapon")
		{
			::Const.Items.WeaponTypeName[i] = "Throwable";
		}
		else if (::Const.Items.WeaponTypeName[i] == "Musical Instrument")
		{
			::Const.Items.WeaponTypeName[i] = "Instrument";
		}
	}
}