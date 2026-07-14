# LUMENFALL: The First Crossing — redesign contract

## Why

2026-07-14 playtest rejected v1: top-down camera/input, tiny arena, abstract models, text-first lore, repetitive audio, flat UI, single save, menu workshop. v1 release status revoked.

## Product

Third-person open-world fantasy adventure. Player is accidentally summoned into Hearthmere by Nia, a young rift mechanic. Village is safe and active. Tutorial happens through movement, props, gestures, and short spoken lines. First enemies appear only after player helps Nia activate a broken Waystone and witnesses a Rift tear above the forest.

Audience: approachable enough for a child to move/explore; expressive characters and immediate goals for broad players; layered companion/settlement/world consequences for adults.

## Non-negotiable UX

- Default third-person; mouse orbit only from mouse motion. Click never rotates camera.
- Wheel zoom 1.8–10 m; camera collision; optional invert/sensitivity/FOV.
- Movement always camera-relative; character smoothly faces travel/lock target.
- Recognizable human hero: face, hair, clothes, hands, legs, equipment; rigged animations.
- No enemies at spawn. Village teaches by interaction and visual events.
- Streamed world chunks; no arena wall. Landmarks and roads guide without text dumps.
- Dialogue max 1–2 short lines per beat; skippable. Story shown through action/cinematics/NPC behavior.
- Workshop is Bram's physical forge. Currency is introduced by NPC + visible object before HUD count.
- Named save profiles: create/load/delete/reset; autosave + backups.
- Game UI uses illustrated fantasy frames, icons, motion, controller focus—not generic flat panels.
- Music has multi-minute variation and contextual layers; ambience uses wind, birds, water, village work.

## Core loop

Explore → notice a lived problem → help a character → world physically changes → gain tool/relationship → reach new region. Combat is an event inside adventure, not the entire game.

## Campaign spine

1. **The Wrong Star:** summoning, village tour, repair Waystone, first Rift witnessed.
2. **Names in the Wind:** find three missing villagers via tracks and companion abilities.
3. **The Glass Road:** rebuild route/bridge; choose which settlement gets scarce lumen.
4. **The Borrowed Sky:** enter ruins, live Nia's failed expedition through playable echo.
5. **First Crossing:** decide whether to close, tame, or cross the Rift; village reflects relationships.

## Architecture

- `src/adventure/core`: app/session/profile/quest services.
- `src/adventure/player`: controller, abilities, interaction, animation state.
- `src/adventure/camera`: orbit/zoom/collision camera.
- `src/adventure/world`: streaming terrain, regions, weather, encounters.
- `src/adventure/characters`: NPC actors, schedules, dialogue, companion AI.
- `src/adventure/quests`: data + event-driven objectives/cinematics.
- `src/adventure/ui`: game-native HUD, menus, map, journal.
- `assets/adventure`: rigged characters, creatures, buildings, props, UI/audio.

## First proof gate

Fresh profile → cinematic summoning → free third-person village walk. Validate W/S/A/D camera-relative movement, continuous orbit, wheel zoom, camera collision, visible face, no camera snap/click rotation, no enemies, stable 10-minute roam. Do not build combat on unproven controls.
