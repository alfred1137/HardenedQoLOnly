// Feat: Dragonslayer Easter-Egg (shop-only, gated by MSU setting)
this.hd_dragonslayer <- this.inherit("scripts/items/weapons/weapon", {
	m = {
		StunChance = 0
	},
	function create()
	{
		this.weapon.create();
		this.m.RegularDamage = 100;
		this.m.RegularDamageMax = 120;
		local roll = this.Math.rand(-5, 5);
		this.m.RegularDamage += roll;
		this.m.RegularDamageMax += roll;
		this.m.ID = "weapon.hd_dragonslayer";
		this.m.Name = "Dragon Slayer";
		this.m.Description = "It's too big to be called a sword. Massive, thick, heavy, and far too rough. Indeed, it's a heap of raw iron.\nOne must be particularly Huge and Strong to wield this weapon.";
		this.m.IconLarge = "weapons/melee/dragon_slayer.png";
		this.m.Icon = "weapons/melee/dragon_slayer_70x70.png";
		this.m.WeaponType = this.Const.Items.WeaponType.Sword;
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		this.m.IsAgainstShields = true;
		this.m.IsAoE = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "icon_dragon_slayer";
		this.m.ChanceToHitHead = 5;
		this.m.Value = 5600;
		this.m.ShieldDamage = 48;
		this.m.Condition = 120.0;
		this.m.ConditionMax = 120.0;
		this.m.StaminaModifier = -25;
		this.m.ArmorDamageMult = 1.5;
		this.m.DirectDamageMult = 0.4;
		this.m.FatigueOnSkillUse = 5;
	}

	function onEquip()
	{
		this.weapon.onEquip();
		this.addSkill(this.new("scripts/skills/actives/hd_guillotine_strike"));
		this.addSkill(this.new("scripts/skills/actives/hd_steel_crescent"));
		this.addSkill(this.new("scripts/skills/actives/hd_decimate"));
		this.addSkill(this.new("scripts/skills/actives/hd_demolish_shield"));
	}

});