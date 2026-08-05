::Hardened.HooksMod.hook("scripts/ai/tactical/strategy", function(q) {
	// QoL-supporting stats that the kept skill_container.nut (HD_WasHitByEnemy /
	// HD_DealtHitToEnemy) writes to and that the purge previously deleted.
	// No gameplay override is restored here (upstream's updateDefending change is
	// a Feat: balance-related AI, deliberately dropped); only the member slots
	// needed by the kept writer are re-added so the += 1 writes stop crashing.
	q.m.Stats.HD_DealtHitToEnemy <- 0;
	q.m.Stats.HD_WasHitByEnemy <- 0;
});
