::Hardened.HooksMod.hook("scripts/items/misc/adrenaline_gland_item", function(q) {
	// Overwrite, because we play a different sound effect when moving this item
	q.playInventorySound = @() function( _eventType )
	{
		::Sound.play("sounds/enemies/unhold_regenerate_01.wav", ::Const.Sound.Volume.Inventory);	// Same sfx as moving around unhold hearts or kraken tenticles
	}
});
