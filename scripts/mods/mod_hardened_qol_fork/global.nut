// World scaling subsystem removed - QoL-only fork reverts to base Reforged scaling.
// The only remaining Global value is the world label background alpha (visual QoL).
::MSU.Table.merge(::Hardened.Global, {
	// World
	LabelBackgroundAlpha = 150,		// Alpha value for the backgrounds of the world party and location labels
});