{
	// Restored infra constant. Hardened's original world_assets.nut set this alongside
	// balance churn we stripped; player.nut (QoL getTryoutCost) reads it. Only this value
	// is re-added — no balance scalars.
	::Const.World.Assets.TryoutCostPct <- 0.2;	// In Vanilla this is 0.1
}

// QoL infra constant read by the kept retinue_manager.nut upgradeInventory /
// HD_getInventoryUpdateAmount and the inventory tooltip. Upstream used
// [18, 27, 36] (balance change, larger late-game cart); fork keeps vanilla
// +9 slots per cart upgrade so the QoL display shows vanilla progression.
::Const.World.HD_InventoryUpgradeSlots <- [9, 9, 9];
