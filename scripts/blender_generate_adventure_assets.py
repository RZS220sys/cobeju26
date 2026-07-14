"""Generate LUMENFALL's first authored character and village asset library."""

from pathlib import Path
import math
import bpy


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "models"
OUT.mkdir(parents=True, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def mat(name, color, metallic=0.0, roughness=0.65, emission=None, strength=0.0):
    found = bpy.data.materials.get(name)
    if found:
        return found
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1.0)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1.0)
        shader.inputs["Emission Strength"].default_value = strength
    return value


SKIN_A = mat("Warm Skin", (0.66, 0.39, 0.25), 0.0, 0.72)
SKIN_B = mat("Rose Skin", (0.78, 0.52, 0.39), 0.0, 0.72)
SKIN_C = mat("Deep Skin", (0.32, 0.17, 0.12), 0.0, 0.72)
INK = mat("Night Cloth", (0.025, 0.055, 0.09), 0.0, 0.82)
BLUE = mat("Wayfarer Blue", (0.055, 0.25, 0.42), 0.05, 0.58)
TEAL = mat("Nia Teal", (0.04, 0.42, 0.4), 0.05, 0.5)
RED = mat("Rift Red", (0.56, 0.08, 0.09), 0.05, 0.55)
GOLD = mat("Hearth Gold", (0.77, 0.46, 0.1), 0.62, 0.32)
STEEL = mat("Worn Steel", (0.29, 0.34, 0.38), 0.72, 0.3)
LEATHER = mat("Brown Leather", (0.19, 0.075, 0.027), 0.0, 0.84)
CREAM = mat("Village Linen", (0.73, 0.68, 0.55), 0.0, 0.88)
GREEN = mat("Warden Green", (0.12, 0.31, 0.19), 0.08, 0.66)
YELLOW = mat("Pip Scarf", (0.95, 0.58, 0.08), 0.0, 0.55)
HAIR_DARK = mat("Dark Hair", (0.035, 0.018, 0.015), 0.0, 0.9)
HAIR_RED = mat("Copper Hair", (0.48, 0.12, 0.035), 0.0, 0.84)
HAIR_GREY = mat("Grey Hair", (0.28, 0.3, 0.31), 0.0, 0.88)
WHITE = mat("Eye White", (0.92, 0.9, 0.82), 0.0, 0.5)
EYE = mat("Lumen Iris", (0.04, 0.48, 0.68), 0.0, 0.34)
WOOD = mat("Hearth Wood", (0.19, 0.09, 0.035), 0.0, 0.9)
WOOD_LIGHT = mat("Fresh Wood", (0.39, 0.22, 0.08), 0.0, 0.84)
STONE = mat("Village Stone", (0.25, 0.28, 0.27), 0.0, 0.95)
ROOF = mat("Moss Roof", (0.14, 0.22, 0.12), 0.0, 0.96)
LUMEN = mat("Lumen Crystal", (0.1, 0.72, 0.86), 0.08, 0.25, (0.08, 0.72, 1.0), 4.0)
RIFT = mat("Rift Violet", (0.43, 0.05, 0.64), 0.06, 0.22, (0.62, 0.08, 1.0), 5.0)


def assign(obj, material):
    if hasattr(obj.data, "materials"):
        obj.data.materials.append(material)
    return obj


def box(name, location, scale, material, rotation=(0, 0, 0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new("Soft carved edge", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    return assign(obj, material)


def pivot_box(name, pivot, center, scale, material, rotation=(0, 0, 0), bevel=0.0):
    obj = box(name, center, scale, material, rotation, bevel)
    bpy.context.scene.cursor.location = pivot
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR", center="MEDIAN")
    obj.select_set(False)
    return obj


def sphere(name, location, scale, material, subdivisions=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return assign(obj, material)


def cylinder(name, location, radius, depth, material, vertices=10, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    return assign(obj, material)


def cone(name, location, radius1, radius2, depth, material, vertices=10, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    return assign(obj, material)


def torus(name, location, major, minor, material, rotation=(0, 0, 0), segments=16):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=segments, minor_segments=6, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    return assign(obj, material)


def root_all(name):
    root = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(root)
    for obj in list(bpy.context.scene.objects):
        if obj != root and obj.parent is None:
            obj.parent = root
    return root


def export(filename, root):
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=str(OUT / filename), export_format="GLB", use_selection=True,
        export_apply=True, export_yup=True, export_materials="EXPORT"
    )


def human(filename, root_name, skin, hair, coat, accent, height=1.0, broad=1.0, child=False, role="hero"):
    clear_scene()
    s = height
    # Feet and articulated legs. Origins sit at hips/knees for procedural animation.
    for side, x in (("L", -0.13 * broad), ("R", 0.13 * broad)):
        pivot_box(f"Thigh{side}", (x, 0, 0.94*s), (x, 0, 0.75*s), (0.105*broad, 0.12, 0.22*s), coat)
        pivot_box(f"Shin{side}", (x, 0, 0.55*s), (x, 0, 0.37*s), (0.09*broad, 0.105, 0.2*s), CREAM)
        box(f"Boot{side}", (x, -0.07, 0.12*s), (0.12*broad, 0.19, 0.11*s), LEATHER, bevel=0.025)
    # Tunic, belt, collar.
    cone("Tunic", (0, 0, 1.12*s), 0.34*broad, 0.25*broad, 0.62*s, coat, 10)
    box("Belt", (0, -0.01, 1.02*s), (0.34*broad, 0.22, 0.045*s), LEATHER, bevel=0.015)
    box("Buckle", (0, -0.235, 1.02*s), (0.055, 0.018, 0.055*s), GOLD, bevel=0.01)
    sphere("Neck", (0, 0, 1.46*s), (0.10*broad, 0.09, 0.13*s), skin, 2)
    sphere("Head", (0, 0, 1.68*s), (0.22*broad, 0.19, 0.27*s), skin, 3)
    # Hair is a readable cap with fringe, not a featureless helmet.
    sphere("HairCap", (0, 0.03, 1.82*s), (0.225*broad, 0.195, 0.17*s), hair, 2)
    box("HairFringeL", (-0.10*broad, -0.17, 1.78*s), (0.085*broad, 0.035, 0.09*s), hair, rotation=(0, 0, 0.18))
    box("HairFringeR", (0.08*broad, -0.175, 1.79*s), (0.07*broad, 0.035, 0.07*s), hair, rotation=(0, 0, -0.22))
    # Face points toward Blender -Y. Eye whites/irises make facing unambiguous in-game.
    for side, x in (("L", -0.085*broad), ("R", 0.085*broad)):
        sphere(f"EyeWhite{side}", (x, -0.184, 1.70*s), (0.047, 0.018, 0.034*s), WHITE, 2)
        sphere(f"Iris{side}", (x, -0.201, 1.70*s), (0.020, 0.010, 0.022*s), EYE, 2)
        box(f"Brow{side}", (x, -0.201, 1.755*s), (0.055, 0.009, 0.012*s), hair, rotation=(0, 0, -0.08 if side == "L" else 0.08))
    cone("Nose", (0, -0.215, 1.64*s), 0.025, 0.006, 0.07*s, skin, 7, rotation=(math.pi/2, 0, 0))
    box("Mouth", (0, -0.194, 1.59*s), (0.055, 0.009, 0.012*s), RED, bevel=0.006)
    for side, x in (("L", -0.27*broad), ("R", 0.27*broad)):
        pivot_box(f"UpperArm{side}", (x, 0, 1.39*s), (x, 0, 1.20*s), (0.09*broad, 0.10, 0.22*s), coat)
        pivot_box(f"Forearm{side}", (x, 0, 1.00*s), (x, -0.015, 0.85*s), (0.08*broad, 0.09, 0.18*s), skin)
        sphere(f"Hand{side}", (x, -0.02, 0.65*s), (0.09*broad, 0.075, 0.11*s), skin, 2)
    # Role props communicate character before any dialogue.
    if role == "hero":
        box("Scabbard", (0.25, 0.13, 1.02*s), (0.045, 0.055, 0.46*s), LEATHER, rotation=(0.12, 0.12, -0.42), bevel=0.015)
        box("SwordGrip", (0.43, 0.08, 1.37*s), (0.035, 0.035, 0.16*s), GOLD, rotation=(0.12, 0.12, -0.42))
        box("ShoulderScarf", (0, -0.23, 1.36*s), (0.26*broad, 0.035, 0.075*s), accent, bevel=0.02)
    elif role == "nia":
        box("ToolSatchel", (0.30, 0.02, 0.98*s), (0.16, 0.09, 0.18*s), LEATHER, bevel=0.025)
        torus("RiftLens", (0, -0.245, 1.28*s), 0.105, 0.023, GOLD, rotation=(math.pi/2, 0, 0), segments=12)
        sphere("LensCore", (0, -0.25, 1.28*s), (0.055, 0.018, 0.055*s), LUMEN, 2)
    elif role == "bram":
        box("ForgeApron", (0, -0.24, 1.16*s), (0.28*broad, 0.035, 0.37*s), LEATHER, bevel=0.02)
        box("HammerHead", (0.42, -0.02, 0.60*s), (0.17, 0.09, 0.10*s), STEEL, bevel=0.025)
        cylinder("HammerGrip", (0.42, -0.02, 0.86*s), 0.035, 0.48*s, WOOD, 8)
        box("Beard", (0, -0.20, 1.53*s), (0.15, 0.045, 0.16*s), hair, bevel=0.04)
    elif role == "mara":
        box("ChestGuard", (0, -0.24, 1.27*s), (0.29*broad, 0.04, 0.23*s), STEEL, bevel=0.025)
        cylinder("Spear", (0.45, 0.0, 1.15*s), 0.028, 1.9*s, WOOD, 8)
        cone("SpearTip", (0.45, 0.0, 2.13*s), 0.08, 0.0, 0.24*s, STEEL, 6)
    elif role == "pip":
        box("Scarf", (0, -0.22, 1.40*s), (0.25, 0.04, 0.07*s), accent, bevel=0.025)
        box("MapSatchel", (-0.26, 0.02, 0.9*s), (0.13, 0.08, 0.16*s), LEATHER, bevel=0.025)
    root = root_all(root_name)
    export(filename, root)


def cottage(filename, color_material, roof_material, width=4.8, depth=4.0):
    clear_scene()
    box("Foundation", (0, 0, 0.25), (width/2+0.2, depth/2+0.2, 0.25), STONE, bevel=0.08)
    box("House", (0, 0, 1.55), (width/2, depth/2, 1.3), color_material, bevel=0.09)
    # Sloped roof halves.
    box("RoofL", (-1.15, 0, 3.05), (width*0.32, depth*0.58, 0.18), roof_material, rotation=(0, 0.58, 0), bevel=0.06)
    box("RoofR", (1.15, 0, 3.05), (width*0.32, depth*0.58, 0.18), roof_material, rotation=(0, -0.58, 0), bevel=0.06)
    box("Door", (0, -depth/2-0.03, 1.15), (0.62, 0.08, 1.05), WOOD, bevel=0.06)
    torus("DoorRing", (0.38, -depth/2-0.13, 1.18), 0.07, 0.014, GOLD, rotation=(math.pi/2, 0, 0), segments=10)
    for x in (-1.45, 1.45):
        box("WindowFrame", (x, -depth/2-0.05, 1.65), (0.48, 0.07, 0.55), WOOD, bevel=0.03)
        box("WindowGlow", (x, -depth/2-0.13, 1.65), (0.36, 0.015, 0.43), YELLOW, bevel=0.02)
    cylinder("Chimney", (1.55, 0.7, 3.55), 0.28, 1.2, STONE, 8)
    root = root_all("Cottage")
    export(filename, root)


def waystone():
    clear_scene()
    cylinder("StoneBase", (0, 0, 0.22), 1.35, 0.44, STONE, 12)
    for index in range(3):
        angle = index / 3 * math.tau
        box(f"StandingStone{index}", (math.cos(angle)*0.78, math.sin(angle)*0.78, 1.2), (0.26, 0.34, 1.0), STONE, rotation=(0.08*index, -0.12*index, -angle), bevel=0.07)
    torus("LumenRing", (0, 0, 1.35), 0.68, 0.07, GOLD, rotation=(math.pi/2, 0, 0), segments=18)
    sphere("DormantCore", (0, 0, 1.35), (0.29, 0.16, 0.29), LUMEN, 2)
    root = root_all("Waystone")
    export("waystone.glb", root)


def village_props():
    clear_scene()
    # Well at origin.
    torus("WellRim", (0, 0, 0.55), 0.95, 0.22, STONE, rotation=(0, 0, 0), segments=14)
    cylinder("WellWall", (0, 0, 0.38), 0.9, 0.75, STONE, 14)
    for x in (-1.0, 1.0):
        box("WellPost", (x, 0, 1.65), (0.10, 0.12, 1.05), WOOD, bevel=0.03)
    cylinder("WellBeam", (0, 0, 2.45), 0.09, 2.2, WOOD, 8, rotation=(0, math.pi/2, 0))
    # Bench offset for extraction as a combined landmark prop set.
    box("BenchSeat", (3.0, 0, 0.55), (1.25, 0.35, 0.12), WOOD_LIGHT, bevel=0.05)
    box("BenchBack", (3.0, 0.28, 1.05), (1.25, 0.10, 0.45), WOOD_LIGHT, rotation=(-0.12, 0, 0), bevel=0.05)
    for x in (2.1, 3.9):
        box("BenchLeg", (x, 0, 0.25), (0.10, 0.2, 0.28), WOOD)
    root = root_all("VillageProps")
    export("village_props.glb", root)


def tree_asset(filename, pine=False):
    clear_scene()
    cylinder("Trunk", (0, 0, 2.0), 0.34, 4.0, WOOD, 9)
    if pine:
        for index, z in enumerate((2.5, 3.6, 4.6, 5.5)):
            cone(f"PineCrown{index}", (0, 0, z), 1.75-index*0.23, 0.15, 1.8, GREEN, 10)
    else:
        sphere("CrownA", (0, 0, 4.3), (1.8, 1.5, 1.45), GREEN, 2)
        sphere("CrownB", (-0.9, 0.15, 4.0), (1.2, 1.0, 1.1), ROOF, 2)
        sphere("CrownC", (0.95, 0.1, 4.15), (1.15, 1.0, 1.05), GREEN, 2)
    root = root_all("Pine" if pine else "Oak")
    export(filename, root)


def rift_hound():
    """Readable quadruped foe: a wounded animal silhouette, not an abstract blob."""
    clear_scene()
    dark_fur = mat("Hound Charcoal", (0.035, 0.045, 0.055), 0.0, 0.82)
    violet_fur = mat("Hound Violet", (0.16, 0.045, 0.22), 0.05, 0.7)
    tooth = mat("Hound Tooth", (0.72, 0.72, 0.62), 0.0, 0.6)
    # Body runs along Y; the creature faces -Y, consistent with the people.
    sphere("Body", (0, 0.12, 0.85), (0.48, 0.82, 0.48), dark_fur, 2)
    sphere("Chest", (0, -0.52, 0.92), (0.5, 0.52, 0.58), violet_fur, 2)
    sphere("Head", (0, -1.0, 1.12), (0.42, 0.5, 0.38), dark_fur, 2)
    sphere("Muzzle", (0, -1.43, 1.02), (0.28, 0.34, 0.22), violet_fur, 2)
    for side, x in (("L", -0.22), ("R", 0.22)):
        cone(f"Ear{side}", (x, -0.93, 1.53), 0.16, 0.0, 0.48, dark_fur, 7, rotation=(0.16, 0, 0))
        sphere(f"Eye{side}", (x*0.7, -1.37, 1.20), (0.065, 0.035, 0.065), RIFT, 2)
        # Origins at shoulder/hip provide leg animation pivots in Godot.
    for side, x in (("L", -0.32), ("R", 0.32)):
        pivot_box(f"FrontLeg{side}", (x, -0.48, 0.82), (x, -0.52, 0.42), (0.11, 0.13, 0.45), dark_fur, rotation=(0.08, 0, 0), bevel=0.025)
        pivot_box(f"BackLeg{side}", (x, 0.52, 0.74), (x, 0.55, 0.37), (0.12, 0.14, 0.42), violet_fur, rotation=(-0.12, 0, 0), bevel=0.025)
        box(f"PawFront{side}", (x, -0.64, 0.06), (0.13, 0.24, 0.09), dark_fur, bevel=0.025)
        box(f"PawBack{side}", (x, 0.42, 0.06), (0.14, 0.25, 0.09), dark_fur, bevel=0.025)
    cone("Tail", (0, 0.98, 1.02), 0.18, 0.04, 1.15, violet_fur, 8, rotation=(math.pi/2.7, 0, 0))
    for x in (-0.09, 0.09):
        cone("Fang", (x, -1.67, 0.96), 0.045, 0.0, 0.18, tooth, 6, rotation=(math.pi, 0, 0))
    # Crystalline scar makes the lore threat readable at a glance.
    for index, y in enumerate((-0.15, 0.15, 0.43)):
        cone(f"RiftSpine{index}", (0, y, 1.34 + index*0.04), 0.11, 0.0, 0.42, RIFT, 6, rotation=(0.18, 0, 0))
    root = root_all("RiftHound")
    export("rift_hound.glb", root)


def lantern_post():
    clear_scene()
    cylinder("Post", (0, 0, 1.5), 0.09, 3.0, WOOD, 8)
    box("Crossbar", (0, 0, 2.75), (0.5, 0.08, 0.08), WOOD, bevel=0.025)
    cylinder("LanternFrame", (0.38, 0, 2.42), 0.22, 0.48, GOLD, 8)
    sphere("LanternGlow", (0.38, 0, 2.42), (0.14, 0.14, 0.2), LUMEN, 2)
    cone("Cap", (0.38, 0, 2.75), 0.3, 0.04, 0.22, GOLD, 8)
    root = root_all("LanternPost")
    export("lantern_post.glb", root)


if __name__ == "__main__":
    human("wayfarer.glb", "Wayfarer", SKIN_B, HAIR_DARK, BLUE, RED, role="hero")
    human("nia.glb", "Nia", SKIN_A, HAIR_RED, TEAL, LUMEN, height=0.95, broad=0.92, role="nia")
    human("bram.glb", "Bram", SKIN_C, HAIR_GREY, CREAM, GOLD, height=1.08, broad=1.28, role="bram")
    human("mara.glb", "Mara", SKIN_C, HAIR_DARK, GREEN, STEEL, height=1.02, broad=1.02, role="mara")
    human("pip.glb", "Pip", SKIN_A, HAIR_RED, CREAM, YELLOW, height=0.72, broad=0.88, child=True, role="pip")
    human("iven.glb", "Iven", SKIN_B, HAIR_DARK, CREAM, BLUE, height=0.98, broad=0.94, role="pip")
    human("sola.glb", "Sola", SKIN_A, HAIR_GREY, RED, GOLD, height=1.04, broad=1.0, role="mara")
    human("orin.glb", "Orin", SKIN_C, HAIR_DARK, TEAL, YELLOW, height=1.02, broad=1.18, role="bram")
    cottage("cottage_blue.glb", CREAM, ROOF)
    cottage("cottage_red.glb", WOOD_LIGHT, RED, width=5.4, depth=4.5)
    waystone()
    village_props()
    tree_asset("oak.glb", False)
    tree_asset("pine.glb", True)
    rift_hound()
    lantern_post()
    print(f"Generated LUMENFALL adventure assets in {OUT}")
