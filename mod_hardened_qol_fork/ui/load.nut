::Hooks.registerJS("ui/mods/mod_hardened_qol_fork/setup.js");

foreach (file in ::IO.enumerateFiles("ui/mods/mod_hardened_qol_fork/js_hooks"))
{
	::Hooks.registerJS(file + ".js");
}

foreach (file in ::IO.enumerateFiles("ui/mods/mod_hardened_qol_fork/js_hooks_late"))
{
	::Hooks.registerLateJS(file + ".js");
}

foreach (file in ::IO.enumerateFiles("ui/mods/mod_hardened_qol_fork/css_hooks"))
{
	::Hooks.registerCSS(file + ".css");
}
