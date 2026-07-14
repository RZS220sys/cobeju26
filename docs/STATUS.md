# Status

- Goal: production-ready third-person open-world adventure.
- Current: LUMENFALL redesign active 2026-07-14; obsolete Palimpsest runtime/assets/schema/docs/saves deleted.
- Proof gate passed: camera-relative third-person controller, stable orbit/zoom/collision, safe village, recognizable animated hero/NPCs, unlimited 25-chunk streaming.
- Playable path: summoning → Nia/Waystone → 3 riftglass → physical Bram bench/lens → Mara escort/hound/memory → 3 selectable regional instruments → rescue Iven/Sola/Orin → forge Memory Compass → floating Echo Causeway puzzle → persistent shelter/bridge/witness choice.
- Systems: portable CCL world folders/backups/confirmed reset+delete, per-NPC state, autosave, pause/traveler book, vitality/combat telegraphs, region-aware soundscape, saved accessibility settings.
- World: Hearthmere + Glasswood/Amberfen/Bellscar biomes and authored landmarks; 16 Blender GLBs; 2 authored terrain textures.
- Architecture: bounded domain catalogs; polymorphic NPC hierarchy + concrete character classes; focused player/interaction/navigation/overlay/travel/quest/persistence services; `LumenfallWorld` is composition-only.
- Storage: `user://game_data/<world_id>/world.cclbin` + `npcs/<npc_id>.cclbin`; folder is directly archive/shareable.
- Validation: strict WGodot clean; 7 suites cover architecture/storage/NPC state and every campaign stage through Glass Road.
- Current: expand chapters, companion/event depth, rigged animation/VFX/audio polish, settings/accessibility, performance/export/release gates.
- Source of truth: `docs/REDESIGN.md`.
