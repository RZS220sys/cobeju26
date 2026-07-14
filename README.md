# PALIMPSEST: Lanterns of the Drowned Archive

Original 3D action-exploration roguelite built with Godot/WGodot. Recover living memories from a submerged archive, assemble a combat build during each descent, and decide whether the past should be preserved, released, or revised.

## Play

- WASD: move
- Mouse / J: aim and cast
- Space: invulnerable slip
- Q: resonance field
- Escape: pause

Each descent requires seven echoes and an Index Warden dispersal before extraction. Two recovered echoes offer run-changing annotations. Victories advance a four-descent narrative spine; the campaign has three non-binary endings and remains replayable afterward.

## Development

```powershell
godot --wg check
godot --headless --path . --script res://tests/test_runner.gd
godot --wg run
```

CCL save models are generated from `ccl/save_data.ccl` with `scripts/GenerateModels.ps1`; never edit `src/generated` manually.

All narrative, code, procedural geometry, synthesized audio, and project-specific art are original to this project. No telemetry, ads, network requirement, or paid progression.


