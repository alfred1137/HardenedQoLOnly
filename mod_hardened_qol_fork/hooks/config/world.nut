// Re-point the vanilla time-of-day index constants so the period labels
// (::Const.Strings.World.TimeOfDay, indexed by floor(Hours / 2)) match the
// Hardened schedule: Sunrise 0-1, Morning 2-7, Midday 8-9, Afternoon 10-15,
// Sunset 16-17, Dusk 18-19, Midnight 20-21, Dawn 22-23.
::Const.World.TimeOfDay <- {
	function isDay( _time ) { return !this.isNight(_time) }

	function isNight( _time ) { return _time == this.Dusk || _time == this.Midnight || _time == this.Dawn }

	function isDusk( _time ) { return _time == this.Dusk }

	Sunrise = 0,
	Morning = 1,
	Evening = 7,	// End of Afternoon
	Midday = 4,
	Afternoon = 5,
	Sunset = 8,
	Dusk = 9,
	Night = 9,
	Midnight = 10,
	Dawn = 11,
}