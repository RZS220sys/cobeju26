# Architecture contract

Dependency direction: `domain <- characters/gameplay/world/presentation <- application <- infrastructure wiring`. Domain catalogs never instantiate scenes or access storage.

Rules:

- One concept per catalog; never recreate a global “types” bucket.
- Every `class_name` equals its snake_case filename.
- `GameWorld` composes nodes only. Runtime behavior belongs to focused coordinators.
- UI creation/state lives in presentation classes, not world/location classes.
- Shared behavior goes in a real base class; character-specific routines/reactions stay in concrete NPC classes.
- New named NPC = concrete class + `NpcCatalog.Id` + factory registration + independent CCL file.
- No raw gameplay IDs/stages/choices. Persist enum integers directly.
- Avoid generic managers. Names describe the bounded responsibility: repository, catalog, coordinator, builder, controller.

NPC hierarchy:

`NpcActor -> HumanoidNpc -> NiaNpc/BramNpc/MaraNpc/PipNpc/IvenNpc/SolaNpc/OrinNpc`

`NpcActor -> AnimalNpc -> BeastNpc -> DogNpc/WolfNpc/RiftHoundNpc`

World storage:

```text
user://game_data/
  index.cclbin
  <world_id>/
    world.cclbin
    npcs/
      nia.cclbin
      bram.cclbin
      ...
```

The `<world_id>` directory is the backup/share unit. NPC files own mood, behavior, trust, fear, hope, position, important events, relationships, and choices.
