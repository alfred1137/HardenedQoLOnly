// generate all msu related things. This should happen early because other parts of the code might expect these to be fetchable at an early point
::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/msu"));

// Our adjustments to Unified Perk Descriptions mod are in here and it needs priority over the strings/strings inclusion
::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/api/hooks/mods"));

// Namespaces are not self-contained and usualy dont require other namespaces. They should load very early
::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/namespaces"));

// Load global variables
::include("scripts/mods/mod_hardened_qol_fork/const");
::include("scripts/mods/mod_hardened_qol_fork/global");

::include("mod_hardened_qol_fork/hooks/config/strings/strings");	// This needs priority, because perk_defs hooks build upon this

::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/reforged"));

// API Hooks
::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/api"));

// Regular Hooks
::includeFiles(::IO.enumerateFiles("mod_hardened_qol_fork/hooks"));
