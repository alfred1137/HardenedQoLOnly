{
	// Restored infra constant. Hardened's original world_assets.nut set this alongside
	// balance churn we stripped; player.nut (QoL getTryoutCost) reads it. Only this value
	// is re-added — no balance scalars.
	::Const.World.Assets.TryoutCostPct <- 0.2;	// In Vanilla this is 0.1
}
