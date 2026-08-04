::Hardened.HooksMod.hook("scripts/entity/tactical/human", function(q) {
	q.onInit = @(__original) function()
	{
		local mockObject;
		mockObject = ::Hardened.mockFunction(this, "addSprite", function( _spriteName ) {
			if (_spriteName == "socket")
			{
				local ret = { done = true, value = mockObject.original(_spriteName) };

				// We iterate in reverse order, because we want to left-most bag item to be added last, so it renders above all other bag items
				for (local i = ::Const.ItemSlotSpaces[::Const.ItemSlot.Bag] - 1; i >= 0; --i)
				{
					mockObject.original(this.m.HD_BagSlotSpriteName + i);		// We add the new sprite for bags
				}
				this.getSkills().add(::new("scripts/skills/special/hd_bag_item_silhouettes"));	// We add the new manager skill, for managing those silhouettes
				return ret;
			}
			return { done = false };
		});
		__original();
		mockObject.cleanup();
	}

	q.onFactionChanged = @(__original) function()
	{
		__original();
		local flip = !this.isAlliedWithPlayer();

		for (local i = 0; i < ::Const.ItemSlotSpaces[::Const.ItemSlot.Bag]; ++i)
		{
			this.getSprite(this.m.HD_BagSlotSpriteName + i).setHorizontalFlipping(flip);
		}
	}
});

::Hardened.HooksMod.hookTree("scripts/entity/tactical/human", function(q) {
	q.m.HD_BagSlotSpriteName <- "HD_BagSlotSprite_";	// Prefix for the bag item silhouette sprites added in onInit

	q.onInit = @(__original) function()
	{
		__original();

		// Feat: we automatically call setAppearance on every human after initialization. That way we can save one lines in every human implementation
		this.setAppearance();
	}
})