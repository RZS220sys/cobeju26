# LUMENFALL Agent Guide

LUMENFALL: The First Crossing is an established 3D third-person fantasy adventure intended for commercial release. Continue the existing game; do not restart, replace its identity, or invent a different project without explicit direction.

## Sources of truth

- `docs/STATUS.md`: implemented state, validation, next work.
- `docs/REDESIGN.md`: product pillars, audience, game loop, UX.
- `docs/ARCHITECTURE.md`: dependency boundaries and current structure.
- `docs/STORY.md`: narrative canon, implemented chapters, open mysteries.
- Keep docs short and current. Record decisions, architecture, canon, blockers, and validation—not routine implementation detail.

## Product bar

- The result must be production-ready, stable, tested, 3D, and easy to navigate.
- Preserve the meaningful core: exploration, repair, memory, relationships, consequence, and a world capable of years of expansion.
- Build enough mechanical and narrative depth for at least two strong hours for demanding players and continued play for the target audience.
- Keep pursuing the existing goal until the playable product is genuinely finished. A pretty prototype is not completion.

## Engineering rules

### Structure and responsibility

- Follow SOLID boundaries. Organize by layer and category using nested folders; never turn `src/core`, `src/world`, or another broad folder into a flat dumping ground.
- Keep dependency direction described in `docs/ARCHITECTURE.md`. Domain code must not depend on scenes, UI, or persistence.
- Every file and class has one bounded responsibility. Split a class before it becomes a god object.
- A world scene/script is a composition root: create and connect focused systems. It must not own player control, quest policy, UI flows, NPC behavior, navigation rules, persistence details, or workshop logic.
- Use focused names such as `Catalog`, `Repository`, `Coordinator`, `Controller`, `Builder`, and `Factory` only when that role is accurate. Do not add meaningless prefixes/suffixes such as `Adventure`, `Class`, or generic `Manager`.
- `class_name` is preferred and must match its snake_case filename (`QuestCatalog` -> `quest_catalog.gd`). Avoid names that collide with Godot built-ins.
- Eliminate duplicated behavior. Use inheritance for a genuine, stable *is-a* relationship; use composition and focused services for capabilities and orchestration.
- Keep APIs statically typed. Constants are for real primitive constants, not aliases for scripts. Use discoverable `class_name` types instead of script preloads.

### Enums and domain policy

- Never hardcode gameplay states, identifiers, choices, layers, or stages as magic strings/integers.
- Put each enum in the smallest responsible domain catalog/class. Do not create a global `Types`, `Enums`, or miscellaneous bucket.
- The owner of an enum also owns its closely related metadata and policy (labels, navigation target, validation, transitions) when appropriate. Presentation/world classes must not duplicate `match` tables for domain policy.
- Keep unrelated concepts separate even when each currently contains only a few values. Scale is achieved through boundaries, not one enormous convenience file.

### NPC architecture

- Preserve the hierarchy: `NpcActor` -> `HumanoidNpc`; `NpcActor` -> `AnimalNpc` -> `BeastNpc`, with concrete species/characters beneath them.
- Every named NPC gets its own class and file in a categorized folder. The concrete NPC owns its distinctive routine, decisions, reactions, and emotional behavior; shared mechanics remain in a valid base class/service.
- Register NPC identity and construction through bounded catalogs/factories. Do not centralize every character's behavior in the world or one NPC switchboard.
- Persist each NPC independently: mood, behavior, trust/fear/hope, position, relationships, choices, and important events. NPC state must support continuity and future simulation rather than cosmetic wandering.

### Persistence

- CCL binary is the persistence format. Never manually edit generated code and never name schema models/fields after Godot built-ins.
- Storage layout is portable by world:

  ```text
  user://game_data/index.cclbin
  user://game_data/<world_id>/world.cclbin
  user://game_data/<world_id>/npcs/<npc_id>.cclbin
  ```

- A `<world_id>` directory is the backup/share unit. Keep world-owned data inside it and use repositories plus atomic writes.
- The game is unreleased. Do not add migration shims or preserve obsolete development saves. Regenerate schemas and delete local test data when a breaking model change requires it. Define a compatibility policy before release.
- `#[StrictBinaryParsing(false)]` may remain where required by the CCL generator, but it is not permission to accumulate legacy compatibility code.

## Media and art policy

- Procedural geometry, code-drawn UI, primitives, and generated Blender blockouts are for prototyping, debugging, layout, and system validation. Clearly label placeholders; do not call them production art.
- Use GPT Image/image generation for authored production bitmap media where suitable: UI ornament, icons, illustrations, textures, loading art, key art, and concept exploration. Work from a coherent art brief, iterate deliberately, and reject visible AI artifacts or inconsistent style.
- Final 3D characters, creatures, props, environments, animation, and other specialist assets should come from the user's artists/friends or properly licensed asset stores. Blender remains useful for blockout, cleanup, rigging, optimization, collision, baking, and integration; scripted primitive models are not the default final-art pipeline.
- Never download or ship an asset without verified commercial rights. Track creator/source, license, permitted modifications, and required attribution in an asset manifest/third-party notice.
- Establish/update `docs/ART_DIRECTION.md` before broad final-media production. Maintain consistent shape language, palette, materials, lighting, typography, iconography, and cultural references.
- Media is accepted only after in-game review: correct import/compression, no artifacts, coherent lighting/perspective/materials, readable UI at supported resolutions, accessibility contrast, and acceptable performance.
- UI implementation should integrate authored assets without baking essential text into images. Keep layout responsive, controls discoverable, and keyboard/controller navigation complete.
- Use anchors, containers, and normalized width/height ratios for every viewport-dependent position, size, or custom-drawing calculation. Never tune screen-dependent geometry with fixed pixels for one resolution; reserve fixed values for true resolution-independent minima such as a one-pixel hairline.

## Validation

- After code, assets, scenes, or tests change, run `scripts/Verify.ps1`. This is the canonical verification entry point; do not launch the live game for routine agent validation.
- Maintain architecture tests: class/file naming, no global type bucket, bounded composition roots, NPC hierarchy/state, and portable storage.
- Do not use WinAPI or PowerShell for screenshots or input automation. Use WGodot's native commands.

## Tools

### WGodot

- Read `skills/wgodot-cli/SKILL.md` completely before using WGodot; reference `skills/wgodot-cli/features.md` as routed by the skill.
- If `godot --wg check` reports no running editor, launch this repository's `project.godot` in the background. If the editor is unresponsive, restart it.
- WGodot source is at `E:\woto\programming\cpp\wgodot` only if a fork bug truly requires investigation. Stop the editor before running its `build_godot.ps1`, then relaunch.

### CCL

- Existing reference project: `E:\woto\projects\DarkSurvivors\ccl\api_types\definitions.ccl`.
- Generator architecture reference: `E:\woto\projects\DarkSurvivors\scripts\GenerateApiTypes.ps1`.
- Prefer binary serialization to avoid WGodot strict-typing ambiguity.

### Blender and image generation

- Blender 5.1.1 is installed for the scoped production tasks described above.
- Use the built-in image-generation skill for bitmap creation/editing. Inspect results at gameplay size and in context; generation alone is not acceptance.
