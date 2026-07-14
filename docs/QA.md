# QA matrix

- Parser/analyzer: `godot --wg check` — required clean (0 warnings).
- Unit/content: headless `tests/test_runner.gd` — CCL roundtrip + old-save truncation + lore + boons.
- Runtime smoke: title, Archive, Settings, Workshop, Credits, start, movement, attack, slip, resonance, pause/resume/abandon.
- Run gates: echo 2/5 boon choices; echo 7 Warden spawn; gate stays locked until boss; win -> verdict; loss -> result.
- Persistence: quit/relaunch after loss, win, purchase, setting, each verdict; corrupted/missing file falls back safely; `.bak` rotation.
- Display: 1280×720, 1920×1080, ultrawide; fullscreen/window switch; UI focus via keyboard/controller.
- Balance targets: Standard first clear 8–14 min; idle death 25–45 sec; two-boon builds materially distinct; Story mode keeps full narrative.
- Release: Windows export starts offline, clean user dir, no debugger errors, save survives update, credits/licensing accurate.
