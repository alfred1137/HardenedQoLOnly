::Hardened.HooksMod.hook("scripts/skills/skill", function(q) {
	// Vanilla Fix: Prevent effects from spawning visual overlay icons, if they are removed during onAdded
	// Overwrite, because we move the logic for spawning an overlay icon to a later timing (see HD_spawnOnAddedIcon())
	q.setContainer = @() function( _container )
	{
		this.m.Container = this.WeakTableRef(_container);
	}
});


