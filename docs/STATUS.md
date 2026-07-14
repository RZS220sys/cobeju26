# Status

- Goal: production-ready third-person open-world adventure.
- Current: v1 rejected by hands-on playtest; ground-up LUMENFALL redesign active 2026-07-14.
- Proof gate passed: camera-relative third-person controller, stable orbit/zoom/collision, safe village, recognizable animated hero/NPCs, unlimited 25-chunk streaming.
- Playable path: summoning → Nia/Waystone → 3 riftglass → physical Bram bench/lens → Mara escort/hound/memory → 3 selectable regional instruments → rescue Iven/Sola/Orin → forge Memory Compass → floating Echo Causeway puzzle → persistent shelter/bridge/witness choice.
- Systems: named CCL profiles/backups/confirmed reset+delete, autosave, pause/traveler book, vitality/combat telegraphs, region-aware prime-length soundscape, saved volume/orbit/FOV/invert/fullscreen/reduce-motion settings.
- World: Hearthmere + Glasswood/Amberfen/Bellscar biomes and authored landmarks; 16 Blender GLBs; 2 authored terrain textures.
- Validation: `godot --wg check` clean; headless 6-suite test completes all quest branches through Memory Compass with no errors/leaks.
- Current: expand chapters, companion/event depth, rigged animation/VFX/audio polish, settings/accessibility, performance/export/release gates.
- Preserve only: strict typed architecture, CCL generator workflow, WGodot automation, export pipeline.
- Remove after replacement: top-down arena, abstract Archive story/UI/audio, single-slot save, menu workshop.
- Source of truth: `docs/REDESIGN.md`.
