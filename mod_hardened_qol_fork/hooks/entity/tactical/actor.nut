::Hardened.HooksMod.hook("scripts/entity/tactical/actor", function(q) {
	// Private
	q.m.HD_IsDiscovered <- false;	// Is true, when setDiscovered(true) has been called on us. Is set to false at the start of every round or when this actor steps into a tile not visible to the player

	q.getTooltip = @(__original) { function getTooltip( _targetedWithSkill = null )
	{
		local ret = __original(_targetedWithSkill);
		if (_targetedWithSkill == null) return ret;

		foreach (entry in ret)
		{
			if (entry.id == 3 && entry.type == "headerText" && entry.icon == "ui/icons/hitchance.png")
			{
				if (!_targetedWithSkill.isAttack() && !_targetedWithSkill.isUsingHitchance())
				{
					// Feat: for non-attacks, which don't use hitchances, we display a new special text and icon
					entry.text = "Valid Target";
					entry.icon = "ui/icons/special.png";
				}
				else
				{
					local hitchance =  _targetedWithSkill.getHitchance(this);
					local uncappedHitchance = null;
					local currentProperties = _targetedWithSkill.getContainer().getActor().getCurrentProperties();
					if (hitchance == currentProperties.HD_HitChanceMax && ::Hardened.Mod.ModSettings.getSetting("ShowUncappedHitchances").getValue())
					{
						// We do a switcheroo, so we can fetch the true uncapped hitchance value
						local oldHD_HitChanceMax = currentProperties.HD_HitChanceMax;
						currentProperties.HD_HitChanceMax = 9000;
						uncappedHitchance = _targetedWithSkill.getHitchance(this);
						currentProperties.HD_HitChanceMax = oldHD_HitChanceMax;

						if (uncappedHitchance == hitchance) uncappedHitchance = null;	// We only want to show the uncapped hitchance if it is really higher than max hitchance
					}

					entry.text = ::MSU.Text.colorizeValue(hitchance, {AddPercent = true});
					entry.text += ::Reforged.Mod.Tooltips.parseString(" [$ $|Concept.Hitchance]");
					if (uncappedHitchance != null) entry.text += " (" + ::MSU.Text.colorizeValue(uncappedHitchance, {AddPercent = true}) + ")";
				}
				break;
			}
		}

		return ret;
	}}.getTooltip;

	q.onInit = @(__original) function()
	{
		__original();

		// This is one of the few function given to entities somewhere after create() but before onInit()
		local oldSetDiscovered = this.setDiscovered;
		this.setDiscovered = function( _b )
		{
			if (_b) this.HD_onDiscovered();
			oldSetDiscovered(_b);
		}

		// This is one of the few function given to entities somewhere after create() but before onInit()
		local oldSetRenderCallbackEnabled = this.setRenderCallbackEnabled;
		this.setRenderCallbackEnabled = function( _bool )
		{
			// Vanilla Fix: Keep the RenderCallback enabled, after raising the shield if it is still supposed to lower it afterwards
			// Vanilla Fix: Keep the RenderCallback enabled, after lowering the weapon or if it is still supposed to raise it afterwards
			// This is related to the Vanilla Fix about Shieldwall/Spearwall Animation not being removed correctly; See onAppearanceChanged Vanilla Fix
			if (_bool == false && (this.m.IsLoweringShield || this.m.IsRaisingWeapon))
			{
				return oldSetRenderCallbackEnabled(true);
			}

			oldSetRenderCallbackEnabled(_bool);
		}
	}

	q.onMissed = @(__original) function( _attacker, _skill, _dontShake = false )
	{
		__original(_attacker, _skill, _dontShake);

		if (_dontShake) return;
		if (this.isHiddenToPlayer()) return;
		if (!this.m.IsShakingOnHit) return;
		if (::Tactical.getNavigator().isTravelling(this)) return;

		// Vanilla explicitely does only shake, when the attack is Non-Ranged or at a Distance of 1 Tile, so we filter this specific case out here
		if (!_skill.isRanged()) return;
		if (_attacker.getTile().getDistanceTo(this.getTile()) == 1) return;

		// Feat: Ranged Attacks at a range of 2 or more tiles now cause us to shake
		this.HD_dodgeSidewaysAnimation(_attacker.getTile());
	}

	q.onDamageReceived = @(__original) function( _attacker, _skill, _hitInfo )
	{
		if (this.isHiddenToPlayer()) return __original(_attacker, _skill, _hitInfo);

		// Feat: we display the hitpoints of before the damage impact in the combat log
		// We switcheroo the values of the BodyPartNames to also include the current Hitpoints,
		// so that vanilla displays them in the in the logs that are printed during this function call
		local oldBodyName = ::Const.Strings.BodyPartName[::Const.BodyPart.Body];
		local oldHeadName = ::Const.Strings.BodyPartName[::Const.BodyPart.Head];
		::Const.Strings.BodyPartName[::Const.BodyPart.Body] += " (" + this.getHitpoints() + ")";
		::Const.Strings.BodyPartName[::Const.BodyPart.Head] += " (" + this.getHitpoints() + ")";

		local mockObject = ::Hardened.mockFunction(this, "kill", function(_killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = false) {
			// Vanilla Fix: Vanilla never prints a hitpoint damage combat log, when the attack kills the target, so we do that here now
			::Tactical.EventLog.logEx(format("%s\'s %s is hit for %i damage", ::Const.UI.getColorizedEntityName(this), ::Const.Strings.BodyPartName[_hitInfo.BodyPart], ::Math.floor(_hitInfo.DamageInflictedHitpoints)));
			return { done = true };
		});

		__original(_attacker, _skill, _hitInfo);

		mockObject.cleanup();

		::Const.Strings.BodyPartName[::Const.BodyPart.Body] = oldBodyName;
		::Const.Strings.BodyPartName[::Const.BodyPart.Head] = oldHeadName;
	}

	// Seems to be called from within the .exe and also doesnt seem related to setDiscovered
	q.onDiscovered = @(__original) function()
	{
		this.HD_onDiscovered();
		__original();
	}

	q.onFactionChanged = @(__original) function()
	{
		local flip = !this.isAlliedWithPlayer();
		__original();
		if (this.hasSprite("HD_frenzy_eyes")) this.getSprite("HD_frenzy_eyes").setHorizontalFlipping(flip);
	}

	q.kill = @(__original) function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = false )
	{
		// Feat: Humans who got decapitated or whose head was smashed in, no longer produce death sounds
		if (this.isHuman() && (_fatalityType == ::Const.FatalityType.Decapitated || _fatalityType == ::Const.FatalityType.Smashed))
		{
			_silent = true;
		}

		local wasAlive = this.isAlive();	// We have to save that state here, because it flips during the execution of __original

		local oldRelationUnitKilled = ::Const.World.Assets.RelationUnitKilled;
		::Const.World.Assets.RelationUnitKilled = 0;
		__original(_killer, _skill, _fatalityType, _silent);
		::Const.World.Assets.RelationUnitKilled = oldRelationUnitKilled;

		if (!wasAlive) return;	// Same check as Vanilla
		if (::Tactical.State.isScenarioMode()) return;	// Many global objects dont exist here, like FactionManager

		// Some contracts force you to fight against their own (deserter twist), we dont want those cases to cause non-scripted relation damage
		local currentContract = ::World.Contracts.getActiveContract();
		if (currentContract != null && this.getFaction() == currentContract.getFaction()) return;

		// This code is mostly a copy of vanillas checks, except that we don't check for ::World.FactionManager.getFaction(this.getFaction()).isTemporaryEnemy()
		local faction = ::World.FactionManager.getFaction(this.getFaction());
		if (faction != null && _killer != null && (_killer.getFaction() == ::Const.Faction.Player || _killer.getFaction() == ::Const.Faction.PlayerAnimals))
		{
			faction.addPlayerRelation(::Const.World.Assets.RelationUnitKilled, "Killed one of their units");
		}
	}

	q.playIdleSound = @(__original) function()
	{
		// Characters who are off-screen no longer produce idle sounds. However they will still be randomly selected as targets for making the idle sound.
		if (this.isPlacedOnMap() && this.getTile().IsVisibleForPlayer)
		{
			__original();
		}
	}

	q.playSound = @(__original) function( _type, _volume, _pitch = 1.0 )
	{
		// An actor that dies offscreen no longer produces a death sound
		if (_type == ::Const.Sound.ActorEvent.Death && !(this.isPlacedOnMap() && this.getTile().IsVisibleForPlayer))
		{
			return;
		}

		__original(_type, _volume, _pitch);
	}

	q.onAppearanceChanged = @(__original) function( _appearance, _setDirty = true )
	{
		__original(_appearance, _setDirty);
		if (!this.m.IsAlive || this.m.IsDying) return;	// Same early return as in Vanilla

		// Vanilla Fix: Update shieldwall animation correctly if an NPC loses that effect while not visible to the player
		// A shield can only be visually raised/lowered, while an entity is rendering (= visible to the player)
		//	So if an NPC gets shieldwall but is not visible; and then a little later loses shieldwall, it will not get this.m.IsLoweringShield set to true;
		//	Its shield will appear raised up until any other onAppearanceChanged call happens on them
		// We fix that bug here by also allowing this.m.IsLoweringShield to be set to true, while this.m.IsRaisingShield == true
		// This fix also requires a tweak in actor::setRenderCallbackEnabled to make sure, that both queued animations are correctly rendered
		if (this.hasSprite("shield_icon") && _appearance.Shield.len() != 0)
		{
			local offset = this.getSpriteOffset("shield_icon");
			if (!this.m.IsLoweringShield && !_appearance.RaiseShield && this.m.IsRaisingShield)	// This is the only different line to vanilla logic
			{
				this.m.IsLoweringShield = true;
				this.setRenderCallbackEnabled(true);
				this.m.RenderAnimationStartTime = ::Time.getVirtualTimeF();
			}
		}

		// Vanilla Fix: Update spearwall animation correctly if an NPC loses that effect while not visible to the player
		// A weapon can only be visually lowered/raised, while an entity is rendering (= visible to the player)
		// 	So if an NPC gets spearwall but is not visible; and then a little later loses spearwall, it will not get this.m.IsRaisingWeapon set to true;
		// 	Its weapon will appear lowered up until any other onAppearanceChanged call happens on them
		// We fix that bug here by also allowing this.m.IsRaisingWeapon to be set to true, while this.m.IsLoweringWeapon == true
		// This fix also requires a tweak in actor::setRenderCallbackEnabled to make sure, that both queued animations are correctly rendered
		if (this.hasSprite("arms_icon") && _appearance.Weapon.len() != 0)
		{
			local arms_icon = this.getSprite("arms_icon");
			local arms_rotation = arms_icon.Rotation;
			if (!this.m.IsRaisingWeapon && !_appearance.LowerWeapon && this.m.IsLoweringWeapon)	// This is the only different line to vanilla logic
			{
				this.m.IsRaisingWeapon = true;
				this.setRenderCallbackEnabled(true);
				this.m.RenderAnimationStartTime = ::Time.getVirtualTimeF();
			}
		}
	}

	q.onMovementFinish = @(__original) function( _tile )
	{
		__original(_tile);
		if (this.isPlayerControlled() && ::Settings.getGameplaySettings().AdjustCameraLevel)
		{
			local camera = ::Tactical.getCamera();
			camera.Level = camera.getBestLevelForTile(_tile);
		}

		if (!_tile.IsVisibleForPlayer) this.m.HD_IsDiscovered = false;
	}

	q.onTurnResumed = @(__original) function()
	{
		// Feat: force a newline into the next combat log that is produced, whenever a new turn resumes
		::Tactical.EventLog.m.HD_IsForcingNewLine = true;

		this.logDebug("Turn resumed for " + this.getName());	// Vanilla only prints this log for when the turn starts. But resuming a turn is just as interesting of a state
		__original();
	}

	q.onTurnStart = @(__original) function()
	{
		// Feat: force a newline into the next combat log that is produced, whenever a new turn starts
		::Tactical.EventLog.m.HD_IsForcingNewLine = true;

		__original();
	}

	q.onTurnEnd = @(__original) function()
	{
		// Feat: force a newline into the next combat log that is produced, whenever a turn ends
		::Tactical.EventLog.m.HD_IsForcingNewLine = true;

		__original();
	}

	q.setCurrentProperties = @(__original) function( _newCurrent )
	{
		if (!::Tactical.isActive())
		{
			return __original(_newCurrent);
		}

		// Vanilla Fix: changes to the maximum fatigue of a brother during combat no longer changes his usable fatigue
		// Vanilla has already implemented this behavior for swapping items
		// This fix will now make it so getting injuries does not take away fatigue and losing/ignoring injuries does not generate free usable fatigue
		// That was most notable around Adrenaline, when it makes you immune to Stamina related injuries
		local oldUsableFatigue = this.HD_getUsableFatigue();
		__original(_newCurrent);
		this.HD_setUsableFatigue(oldUsableFatigue);
	}

	q.spawnBloodEffect = @(__original) function( _tile, _mult = 1.0 )
	{
		// We prevent blood effects from appearing outside of the players view
		if (_tile.IsVisibleForPlayer)
		{
			__original(_tile, _mult);
		}
	}

// Modular Vanilla Functions
	// Reforged Fix: Rare script error, when DamageInflictedHitpoints is greater than getHitpointsMax
	q.MV_selectInjury = @(__original) function( _skill, _hitInfo )
	{
		// Reforged creates weighted container entries using a weight depending on the relation of DamageInflictedHitpoints, getHitpointsMax and the threshold of the respetive injury
		// That method can produce a weight of 0 or negative values, if the DamageInflictedHitpoints value is greater than getHitpointsMax
		// In unmodded reforged that can't happen currently, as those cases are filtered out earlier
		// But if selectInjury is called in isolution, then this can happen, like for example in our bone_breaker perk rework
		// We fix that shortcomming, by capping the DamageInflictedHitpoints to never be greater than getHitpointsMax
		_hitInfo.DamageInflictedHitpoints = ::Math.min(_hitInfo.DamageInflictedHitpoints, this.getHitpointsMax());

		return __original(_skill, _hitInfo);
	}

// Hardened Functions
	// Make all layers on this character blink briefly white, to signal, that this entity just went fleeing
	q.HD_onStartFleeing = @(__original) function()
	{
		if (this.isPlacedOnMap() && this.getTile().IsVisibleForPlayer)
		{
			this.HD_playFleeAnimation();

			// Todo: play these sounds delayed, so that they dont overlap with the death sound which might triggered this fleeing.
			// Todo: play these sounds staggered, so that they dont cause too high volume peaks. Or restrict maximum flee sounds in a time window
			this.playSound(::Const.Sound.ActorEvent.Flee, ::Const.Sound.Volume.Actor * this.m.SoundVolume[::Const.Sound.ActorEvent.Flee] * this.m.SoundVolumeOverall * 0.8, this.m.SoundPitch);
		}
	}

// New Functions
	// Make all layers on this character blink briefly white, to signal, that this entity just went fleeing
	q.HD_playFleeAnimation <- function()
	{
		// The third element of ShakeLayers corresponds to ::Const.BodyPart.All, but not every actor may defined this.
		//	The Vanilla WolfRider for example does not have this
		//	That's why we instead use whatever element is last in ShakeLayers
		if (this.m.ShakeLayers.len() == 0)
		{
			::logWarning("Hardened::HD_playFleeAnimation: The entity " + this.getName() + " has no ShakeLayers defined");
			return;
		}
		local layers = this.m.ShakeLayers.top();

		::Tactical.getShaker().cancel(this);
		::Tactical.getShaker().shake(this, this.getTile(), 1, ::Const.Combat.ShakeEffectArmorHitColor, ::Const.Combat.ShakeEffectArmorHitHighlight, ::Const.Combat.ShakeEffectArmorHitFactor, ::Const.Combat.ShakeEffectArmorSaturation, layers, 1.0);
	}

	// Play a dodge animation that dodges an incoming attack in a 90% angle in to either side
	q.HD_dodgeSidewaysAnimation <- function( _attackerTile )
	{
		::Tactical.getShaker().shake(this, _attackerTile, 4);
	}

	// Make all layers on this character blink briefly in a passed color, to highlight something
	q.HD_playColoredJumpAnimation <- function( _color )
	{
		// The third element of ShakeLayers corresponds to ::Const.BodyPart.All, but not every actor may defined this.
		//	The Vanilla WolfRider for example does not have this; though we fix that here
		//	That's why we instead use whatever element is last in ShakeLayers
		if (this.m.ShakeLayers.len() == 0)
		{
			::logWarning("Hardened::HD_playColoredJumpAnimation: The entity " + this.getName() + " has no ShakeLayers defined");
			return;
		}
		local layers = this.m.ShakeLayers.top();

		::Tactical.getShaker().cancel(this);
		::Tactical.getShaker().shake(this, this.getTile(), 3, _color, _color, ::Const.Combat.ShakeEffectArmorHitFactor, ::Const.Combat.ShakeEffectArmorSaturation, layers, 1.0);
	}

	// This is called either when onDiscovered or when setDiscovered(true) on this actor are called
	q.HD_onDiscovered <- function()
	{
		// Feat: stop player movement midway, when he discovers an enemy/ally
		// This is related to the setDiscovered hook in this script and the onMovementStep hook in the player.nut
		if (!this.m.HD_IsDiscovered && !this.isPlayerControlled() && ::Tactical.isActive())	// We must check for tactical to be active, because vanilla also calls setDiscovered(true) during initialization of a player object
		{
			this.m.HD_IsDiscovered = true;	// We use this variable, so that we don't trigger the following behavior repeatidly on already discovered entities
			local activeEntity = ::Tactical.TurnSequenceBar.getActiveEntity();
			if (activeEntity != null && activeEntity.isPlayerControlled() && ::MSU.isKindOf(activeEntity, "player"))
			{
				if (this.isAlliedWithPlayer() && ::Hardened.Mod.ModSettings.getSetting("HoldOnDiscoverAlly").getValue())
					activeEntity.m.HD_HasDiscoveredSomething = true;
				if (!this.isAlliedWithPlayer() && ::Hardened.Mod.ModSettings.getSetting("HoldOnDiscoverHostile").getValue())
					activeEntity.m.HD_HasDiscoveredSomething = true;

				if (activeEntity.m.HD_HasDiscoveredSomething) ::Tactical.TurnSequenceBar.HD_protectTurnEnd();
			}
		}
	}
});

::Hardened.HooksMod.hookTree("scripts/entity/tactical/actor", function(q) {
	// If any character ever gets the sprite "dirt" added, we treat that as if they can handle glowy eyes
	// So we add our new glowy eyes sprite to them and the effect, which controls glowy eyes
	q.onInit = @(__original) function()
	{
		local mockObject;
		mockObject = ::Hardened.mockFunction(this, "addSprite", function( _spriteName ) {
			if (_spriteName == "dirt")
			{
				local ret = { done = true, value = mockObject.original(_spriteName) };

				local frenzyEyes = mockObject.original("HD_frenzy_eyes");		// We add the new sprite HD_frenzy_eyes directly after "dirt"
				frenzyEyes.setBrush("zombie_rage_eyes");
				frenzyEyes.Alpha = 200;
				this.getSkills().add(::new("scripts/skills/special/hd_frenzy_eyes_manager"));	// We add the new frenzy eyes manager special skill, that spawns the effect
				return ret;
			}
			return { done = false };
		});
		__original();
		mockObject.cleanup();
	}

// Reforged Events
	// This must happen as hookTree because there is no guarantee that someone overwriting it will call the child function
	q.onSpawned = @(__original) function()
	{
		// Since we now preserve available fatigue during combat, that causes newly created entities to spawn fully fatigued,
		//	because in the creation process they start with 0 Stamina
		// In order to fix that, we automatically set the fatigue of every freshly spawned entity to 0. That is in line with Vanilla behavior anyways
		// We do this both here (so it affects entities spawned-in mid battle), and during onRoundStart (so it keeps their initiative honest for the turn order)
		this.setFatigue(0);

		__original();

		this.getSkills().onSpawned();
	}
});
