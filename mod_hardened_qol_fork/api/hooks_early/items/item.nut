::Hardened.HooksMod.hook("scripts/items/item", function(q) {
	// Public
	if (!"StaminaModifier" in q.m) q.m.StaminaModifier <- 0;
	q.m.HD_IsBuildingSupply <- false;
	q.m.HD_IsMedical <- false;
	q.m.HD_IsMineral <- false;
	q.m.HD_ConditionValueThreshold <- 0.0;	// The value of an item depending on condition will only scale down to this value linearly as condition decreases

// Reintroduced Vanilla Functions
	// Returns the type of ammo, that this item represents.
	// In Vanilla this only exists in the base class ammo.nut, but not every item with the itemtype "ammo" inherits from that class.
	// In order to safely call getAmmoType on a supposed ammo item, we need to enable it for all types of items
	q.getAmmoType <- function()
	{
		return ::Const.Items.AmmoType.None;
	}

// New Getter/Setter
	// @return true if this item is produced by any attached location of _settlement, or false otherwise
	// This might be extended to also return true, if a related building (that not necessarily produces the item in question) is present
	// 	This happens for example for armor parts, medicine, ammo and dried fish
	q.isBuildingPresent <- function( _settlement )
	{
		local scriptName = ::IO.scriptFilenameByHash(this.ClassNameHash);
		foreach (activeAttachedLocation in _settlement.getActiveAttachedLocations())
		{
			foreach (produce in activeAttachedLocation.getProduceList())
			{
				if (scriptName.find(produce) != null)	// Produce-Strings are just the identifying part of the script path
				{
					return true;
				}
			}
		}

		return false;
	}

	// Return the amount of items of this type that should be generated at most inside a shop, given enough rarity and luck
	q.getShopAmountMax <- function()
	{
		return 3;	// This is the standard vanilla value
	}

	// Return the rarityMult of this item during shop generation, making it more or less likely to appear multiple times
	// A higher RarityMult makes it more likely to pass additional RarityThreshold checks during shop generation
	// Can be hooked or overwritten by various item subclasses to add additional multipliers
	// @param _settlement is the settlement that we are currently in, as rarity is usually related to shops
	q.getRarityMult <- function( _settlement = null )
	{
		return 1.0;
	}

	q.getWeight <- function()
	{
		local staminaModifier = this.getStaminaModifier();
		return ::Math.max(0, -1 * staminaModifier);
	}

	// Set the stamina modifier of the item to the inverse of the passed value
	q.setWeight <- function( _weight )
	{
		this.m.StaminaModifier = -1 * _weight;
	}

	q.isBuildingSupply <- function()
	{
		return this.m.HD_IsBuildingSupply;
	}

	q.isMedical <- function()
	{
		return this.m.HD_IsMedical;
	}

	q.isMineral <- function()
	{
		return this.m.HD_IsMineral;
	}

	q.isNamed <- function()
	{
		return this.isItemType(::Const.Items.ItemType.Named);
	}

	// @return the brush name of this item, if it exists
	// @return null otherwise
	q.HD_getBrush <- function()
	{
		return null;
	}

	// @return the brush name of the silhouette that should be displayed for when this item is in a bag slot
	// @return null if no brush exists to be displayed
	// @return null if no silhouette should be displayed (e.g. due to mod settings)
	q.HD_getSilhouette <- function()
	{
		return this.HD_getBrush();
	}

// New Functions
	// Play the InventorySound of an item but as directional sound given a _tile
	// This can be used to play inventory sounds on NPCs during combat
	q.playInventorySoundWithPosition <- function( _eventType, _tile, _volumeMult = 1.0, _pitchMult = 1.0 )
	{
		if (_tile.IsVisibleForPlayer)
		{
			local mockObject;
			mockObject = ::Hardened.mockFunction(::Sound, "play", function( _soundFile, _volume = 1.0, _pos = null, _pitch = 1.0 ) {
				mockObject.original(_soundFile, _volume * _volumeMult, _tile.Pos, _pitch * _pitchMult);
				return { done = true, value = null };
			});

			this.playInventorySound(_eventType);

			mockObject.cleanup();
		}
	}

	// Calculate how much the current condition of this items influences its value
	// In Vanilla this is only used for weapons, shields and armor
	// In Vanilla the price changes linearly between 0% and 100% as the condition changes
	q.HD_getConditionMult <- function()
	{
		if (this.getConditionMax() == 0) return 1.0;

		local guaranteedPct = this.m.HD_ConditionValueThreshold;
		local scaledPct = 1.0 - this.m.HD_ConditionValueThreshold;
		scaledPct *= (this.getCondition() / (this.getConditionMax() * 1.0));

		return guaranteedPct + scaledPct;
	}
});