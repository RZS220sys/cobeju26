# LUMENFALL: The First Crossing

Third-person 3D fantasy adventure built with Godot/WGodot. Explore a living frontier, recover people and roads erased from memory, and make choices that physically reshape Hearthmere.

## Controls

- WASD: move
- Mouse: orbit camera
- Wheel: zoom
- E: interact
- Left click: strike
- Space: jump
- Shift: sprint
- Escape: pause

## Development

```powershell
godot --wg check
godot --headless --path . --script res://tests/test_runner.gd
godot --wg run
```

CCL models come from `ccl/save_data.ccl`; regenerate with `scripts/GenerateModels.ps1`. Never hand-edit `src/generated`.
