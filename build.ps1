# build.ps1 - Package HardenedQoLOnly into a Battle Brothers submod zip.
# Usage:  pwsh ./build.ps1
# Output: mod_hardened_qol_fork_<version>.zip at repo root (gitignored via *.zip).
# Version follows the x.y.z-patch.N convention: nearest release tag (e.g. 1.22.4-patch.1),
# falling back to the ::Hardened.Version from the bootstrap when not a git checkout.
#
# Packages the same top-level dirs a release zip contains. Run from repo root.

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

# Directories that go into the mod zip (bootstrap + hooks + MSU + UI + assets).
$PackDirs = @(
	"mod_hardened_qol_fork",   # Squirrel hooks, MSU settings, api, reforged integration
	"scripts",        # bootstrap main_hardened.nut + mod-owned scripts
	"ui",             # JS/CSS UI hooks
	"gfx",            # textures/brushes
	"sounds",         # audio
	"brushes"         # compiled brush defs (sprite id -> atlas); BB registers these at runtime
)

# Never package these even if present.
$ExcludeDirs = @("doc", "unpacked_brushes", ".bbbuilder", "tasks", ".git")

foreach ($d in $PackDirs) {
	if (-not (Test-Path -LiteralPath $d)) {
		throw "Required package dir missing: $d"
	}
}

# Read version from the bootstrap.
$bootstrap = Get-Content -Raw -LiteralPath "scripts/!mods_preload/main_hardened_qol_fork.nut"
$m = [regex]::Match($bootstrap, 'Version\s*=\s*"([^"]+)"')
if (-not $m.Success) { throw "Could not parse ::Hardened.Version from bootstrap" }
$Version = $m.Groups[1].Value

# Release name per convention x.y.z-patch.N (git tag); fallback to bootstrap version.
$ReleaseVersion = $Version
$tag = & git describe --tags --abbrev=0 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrEmpty($tag)) {
	$ReleaseVersion = $tag.TrimStart("v")
}

$ZipName = "mod_hardened_qol_fork_$ReleaseVersion.zip"
$ZipPath = Join-Path $Root $ZipName

if (Test-Path -LiteralPath $ZipPath) {
	Remove-Item -LiteralPath $ZipPath -Force
}

Write-Host "Packaging $ZipName ..."

# Stage into a temp dir that mirrors the release layout, excluding junk dirs.
$Stage = Join-Path $Root ".build_stage"
if (Test-Path -LiteralPath $Stage) {
	Remove-Item -LiteralPath $Stage -Recurse -Force
}
New-Item -ItemType Directory -Path $Stage | Out-Null

foreach ($d in $PackDirs) {
	Copy-Item -LiteralPath $d -Destination $Stage -Recurse
}

# Remove excluded dirs from the staged copy.
foreach ($d in $ExcludeDirs) {
	$target = Join-Path $Stage $d
	if (Test-Path -LiteralPath $target) {
		Remove-Item -LiteralPath $target -Recurse -Force
	}
}

# Also drop any stray nested copies of junk inside staged dirs.
Get-ChildItem -Path $Stage -Recurse -Directory -Force |
	Where-Object { $_.Name -in $ExcludeDirs } |
	ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }

Compress-Archive -Path (Join-Path $Stage "*") -DestinationPath $ZipPath -CompressionLevel Optimal

Remove-Item -LiteralPath $Stage -Recurse -Force

Write-Host "Done: $ZipPath"
Write-Host "Install: drop zip into <Battle Brothers>/data/ as-is, requires MSU + Reforged + Dynamic Spawns."
