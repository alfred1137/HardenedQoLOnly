::Hardened.HooksMod.hook("scripts/entity/world/attached_location", function(q) {
	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		local childrenElements = [];
		local childrenId = 41;
		foreach (produce in this.getProduceList())
		{
			local item = ::new("scripts/items/" + produce);
			childrenElements.push({
				id = childrenId,
				type = "text",
				icon = "ui/items/" + item.getIcon(),
				text = item.getName(),
			});
			++childrenId;
		}

		if (childrenElements.len() != 0)
		{
			ret.push({
				id = 40,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Produces:",
				children = childrenElements,
			});
		}

		return ret;
	}

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);

		// Fix: attached locations having too many named items after saving and loading multiple times
		// This is a retro-active fix for existing saves. It is not required for new saves and should eventually be removed from Hardened
		if (this.m.Loot.len() > 2)
		{
			this.m.Loot.clear();
			this.onSpawned();
		}
	}

// New Function
	q.getProduceList <- function()
	{
		local produceList = [];
		this.onUpdateProduce(produceList);
		return produceList;
	}
});