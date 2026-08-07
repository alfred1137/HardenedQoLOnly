# Build → Release Process (HardenedQoLFork)

- **When to use:** publishing a new fork release (version tag mirrors upstream, e.g. `1.22.4`) or a patch on top of the current base (`1.22.4-patch.1`).
- **Scope:** `pwsh ./build.ps1` → verify → commit → tag → GitHub Release → retire old releases.
- **Reminders:** `README.md` / `tasks/` are **not** packaged in the zip (build excludes `doc`, `tasks`, `.bbbuilder`, `unpacked_braces`); tag the commit that **reproduces the shipped zip** (Version + code + conflictWith must all be in the tagged commit).

## 1. Pre-flight

1. `git status` — only intended edits staged; no stray test logs staged (they are tracked but gitignored under `.bbbuilder/`).
2. Confirm `scripts/!mods_preload/main_hardened_qol_fork.nut` → `Version = "<target>"` and `conflictWith` entries present.

## 2. Build

```
pwsh ./build.ps1
```

Produces `mod_hardened_qol_fork_<Version>.zip` at repo root (gitignored via `*.zip`). Confirm stdout ends `Done: ...\.zip`.

## 3. Verify payload (no extraction needed)

```
$zip = Get-Item mod_hardened_qol_fork_1.22.3.zip
tar -xf $zip -O scripts/!mods_preload/main_hardened_qol_fork.nut | Select-String 'Version = '
tar -xf $zip -O mod_hardened_qol_fork/api/hooks/skills/skill.nut | Select-String 'isGarbage'
tar -tf $zip | Measure-Object   # expect top-level mod_hardened_qol_fork / scripts / ui / gfx / sounds / brushes
```

Must NOT contain `doc/`, `tasks/`, `.bbbuilder/`, `unpacked_brushes/`.

## 4. Commit + push

```
git add -A -- README.md mod_hardened_qol_fork/api/hooks/skills/skill.nut scripts/!mods_preload/main_hardened_qol_fork.nut
git commit -m "feat: ..." ; git push origin develop
```

Explicit paths only — avoids accidentally committing staged test-log deletions.

## 5. Tag (annotated)

Tag schema mirrors upstream: version-bump release uses the bare version (`1.22.4`); a patch on top of that base uses `1.22.4-patch.N`.

```
git tag -a 1.22.4 -m "Hardened QoL Fork v1.22.4 (...)"
git push origin 1.22.4
```

Use `gh release create --verify-tag` to anchor the release to this tag.

> **Footgun:** upstream also tags `1.22.x`. Local tag refs are a flat namespace, so the fork tag **replaces** the upstream tag of the same name fetched earlier. Never `git fetch --tags` afterwards — it will re-point `1.22.4` at the upstream commit and your release anchor goes stale. Fetch upstream with `git fetch upstream --no-tags`.

## 6. Publish GitHub Release

- New: `gh release create 1.22.4 mod_hardened_qol_fork_1.22.4.zip --repo alfred1137/HardenedQoLOnly --title "Hardened QoL Fork v1.22.4" --notes-file tasks/release-notes-<v>.md --verify-tag`
- Update existing: `gh release edit 1.22.4 --repo alfred1137/HardenedQoLOnly --notes-file ...`
- Verify: `gh release view 1.22.4 --repo alfred1137/HardenedQoLOnly --json name,tagName,assets`

## 7. Retire superseded releases (IRREVERSIBLE — confirm first)

```
gh release list --repo alfred1137/HardenedQoLOnly
gh release delete 1.22.4-patch.K --repo alfred1137/HardenedQoLOnly -y    # deletes release + asset; keeps git tag
```

Prefer deleting the GitHub **Release** only; retain git tags as history unless explicit retire of the tag is requested (force-push a tag = destructive).

## 8. Update task trackers

- `tasks/todo.md` — append a session block: tag, tip commit, release URL.
- `tasks/lessons.md` — append any correction (e.g. install-guide rewrite, tag↔asset mismatch) per the self-improvement loop.

## Gotchas / Pitfalls

- **Install is drop-zip-as-is into `/data/`** (do not extract). BB + MSU load `.zip` mods directly. README must say this, never "unzip into /data/".
- **Tag ↔ asset coherence:** a tag whose `Version` reads `1.22.2` while its release ships a `1.22.3.zip` makes bug reports un-reproducible — version bump, code, and conflict decls ride the same commit as the tag.
- **Conflict declaration lives in the loader:** `::Hardened.HooksMod.conflictWith([...])` (MSU/Modern Hooks enforces it); prose-only notes are insufficient.
- `enumerateFiles` on a truly empty packaged dir throws — keep packaged dirs non-empty.
- README + tasks are NOT inside the zip — their doc commits may trail the tag, but README version refs must stay consistent for humans.
