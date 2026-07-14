# Status

- Goal: production-ready third-person open-world adventure.
- Current: LUMENFALL redesign active 2026-07-14; obsolete Palimpsest runtime/assets/schema/docs/saves deleted.
- Proof gate passed: camera-relative third-person controller, stable orbit/zoom/collision, safe village, recognizable animated hero/NPCs, unlimited 25-chunk streaming.
- Playable path: summoning → Nia/Waystone → 3 riftglass → physical Bram bench/lens → Mara escort/hound/memory → 3 selectable regional instruments → rescue Iven/Sola/Orin → forge Memory Compass → floating Echo Causeway puzzle → persistent shelter/bridge/witness choice.
- Systems: named CCL profiles/backups/confirmed reset+delete, autosave, pause/traveler book, vitality/combat telegraphs, region-aware prime-length soundscape, saved volume/orbit/FOV/invert/fullscreen/reduce-motion settings.
- World: Hearthmere + Glasswood/Amberfen/Bellscar biomes and authored landmarks; 16 Blender GLBs; 2 authored terrain textures.
- Architecture: clean top-level domains; gameplay stages/quests/NPCs/interactions/items/recipes/regions/choices/assets/physics layers are enums; CCL persists enum ints directly.
- Validation: strict WGodot check clean; 6-suite campaign test covers all stages through the Glass Road handoff.
- Current: expand chapters, companion/event depth, rigged animation/VFX/audio polish, settings/accessibility, performance/export/release gates.
- Source of truth: `docs/REDESIGN.md`.
