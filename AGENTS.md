# Agents Guide

Imagine you want to create a game with the main goal of production.
After completing the game, you will be selling it yourself in Steam or other shops.

This project (cobeju26) is about such a game. Rules:

  - Topic, mode and details of the game are all decided by you.
  - The game **MUST** be production ready, bugfree and tested.
  - You will be provided with the tools to properly debug and test the game.
  - The game **MUST** have proper assets and mechanisms.
  - The game must be 3D and have proper and easy to navigate user UI.
  - Documenting is important, but don't over-document. because you will be wasting too much tokens writing and (then later) reading them. Only document what's important. things such as goals, architecture, bugs, etc. and make sure they are extremely summerized and compressed, since you are the one who is going to read them later. Don't waste your tokens on proper English grammar in docs; being short and understandable for yourself is what's important.
  - Keep the project properly structured. Avoid adding thousands of lines of code to a single file. Prefer using `class_name` because that will make it easier to discover classes, etc. Avoid naming your classes same name as builtin godot stuff.
  - Make sure the game mechanism, lores and story is actually enjoyable by the users. For the most strictest players, you have to keep them happy/entertained for at least 2 hours. For the normal players, at least days. And for the players who become the game's fans, you should make sure the game has the potential to properly be expanded by future updates, add new mechanisms, features, etc. Be creative and fun, but most importantly: **meaningful**. Perhaps the game can have lots of psychological aspects, lessons, conclusions, etc. so it's not meaningless to play it.
  - You do **NOT** have to constantly report back to the user. As you will be on your own and work on the project on your own. This will be your own project.


## Tools

### WGodot

This is my own custom Godot fork that has lots of extra features on top of the latest Godot features.
For its features, check [features.md](./skills/wgodot-cli/features.md) file.
For the full agent skill, check [wgodot-cli skill](./skills\wgodot-cli\SKILL.md).

After adding new files, assets, code, etc, you do **not** need to scan every single files individually or run normal godot re-import commands. this command is your best friend:
`godot --wg check`
it automatically re-scans, checks for errors, warnings, etc.
If you see this message: `wgodot: No running WGodot editor was found for this project.`; then just simply launch the `project.godot` file at the root of this repo in the background. if godot hangs or becomes unresponsive, you can kill it and launch it again.
You really don't need to read the source code of my fork, but if it's truly required: `E:\woto\programming\cpp\wgodot`.

You are prohibited from using winapi/powershell for screenshot, user input, etc. Use the wgodot's native commands, they are far more efficient.

You are allowed to change the project's settings in the `project.godot` to your liking to make it fit the game style that you want to create. it's all up to you.

Prefer using GDScript as much as possible, as it's going to be much easier to debug, put breakpoints, etc. Don't do dumb shit like this:

```gd
const SomeType = preload(res://some/path/some_type.gd)
```

Prefer using `class_name`; and while you are using that, then you no longer need to do these stuff.
Keep constants to **real** primitive constant values, because WGodot has de-const feature for its export.

### CCL

For data serialization and deserialization, use CCL. it's an alternative to protobuf, but it's so much easier and has 0 runtime deps.

Examples from my previous projects:

E:\woto\projects\DarkSurvivors\ccl\api_types\definitions.ccl

generating stuff:

E:\woto\projects\DarkSurvivors\scripts\GenerateApiTypes.ps1

You can follow a similar architecture here as well. In that place, I used it for stuff like API requests, etc. but it can also be used for player data storage, world data storage, etc etc. use the binary serialization to not get errors about strict type checking in wgodot.

For serialization version compatibility (basically when you update the schema): use `#[StrictBinaryParsing(false)]`; and always add new fields to the last. this way, when the new version of the parser wants to read the old data, it will still return a valid result with old data (greedy algorithm, take as much as is valid).

Avoid naming your models or fields same name as builtin godot stuff, that will get conflicts. also avoid **manually** editing auto-generated source code, as your changes will be overwritten later and hence wasted.

### Blender

Blender v5.1.1 is installed on this machine, feel free to use it for assets and stuff (you can use its Python API, write/run Python scripts, etc).


### Image gen

You are allowed to use your built-in image gen tool/skill as much as possible. For generating textures, etc. Just make sure they are not slop-looking and are actually suitable for a production-ready game. 


