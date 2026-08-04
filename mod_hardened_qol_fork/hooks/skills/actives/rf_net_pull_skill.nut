::Hardened.HooksMod.hook("scripts/skills/actives/rf_net_pull_skill", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Icon = "skills/hd_net_pull_skill.png";	// This modified icon has more contrast and is brighter
	}
});
