::Hardened.HooksMod.hook("scripts/items/supplies/food_item", function(q) {
	q.m.HD_MaxAmount <- 25;		// Maximum Stacksize of this food item. In Vanilla this is 25

	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		ret.push({
			id = 68,
			type = "text",
			text = format("Contains %i/%i servings", this.m.Amount, this.m.HD_MaxAmount),
		});

		return ret;
	}

	// Overwrite, because we make the randomization depending on new member variable
	q.randomizeAmount = @() function()
	{
		this.m.Amount = ::Math.rand(1, this.m.HD_MaxAmount);
	}

// Hardened Functions
	q.getRarityMult = @(__original) function( _settlement = null )
	{
		local ret = __original();

		if (_settlement != null)
		{
			ret *= _settlement.getModifiers().FoodRarityMult;
		}

		return ret;
	}
});

::Hardened.HooksMod.hookTree("scripts/items/supplies/food_item", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Amount = this.m.HD_MaxAmount;
	}
});