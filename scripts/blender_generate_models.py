"""Generate the original low-poly PALIMPSEST cast as separate GLB assets."""

from pathlib import Path
import math
import bpy


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "models"
OUTPUT.mkdir(parents=True, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
        if datablocks != bpy.data.materials:
            continue


def material(name, color, metallic=0.0, roughness=0.65, emission=None, strength=0.0):
    existing = bpy.data.materials.get(name)
    if existing:
        return existing
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = strength
    return mat


INK = material("Ink Ceramic", (0.035, 0.095, 0.13), 0.05, 0.72)
BLUE = material("Drowned Blue", (0.075, 0.24, 0.31), 0.12, 0.62)
BRASS = material("Aged Brass", (0.55, 0.36, 0.13), 0.72, 0.34)
BONE = material("Archive Porcelain", (0.76, 0.82, 0.76), 0.0, 0.48)
CYAN = material("Memory Cyan", (0.08, 0.72, 0.7), 0.1, 0.25, (0.08, 0.9, 0.86), 5.0)
AMBER = material("Lantern Amber", (0.95, 0.53, 0.12), 0.05, 0.23, (1.0, 0.42, 0.06), 6.0)
MAGENTA = material("Revision Magenta", (0.63, 0.08, 0.34), 0.12, 0.42, (0.9, 0.07, 0.42), 3.2)
MOSS = material("Keeper Verdigris", (0.22, 0.31, 0.25), 0.3, 0.7)


def assign(obj, mat):
    if hasattr(obj.data, "materials"):
        obj.data.materials.append(mat)
    return obj


def cone(name, z, depth, bottom, top, mat, vertices=8):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=bottom, radius2=top, depth=depth, location=(0, 0, z + depth / 2))
    obj = bpy.context.object
    obj.name = name
    return assign(obj, mat)


def sphere(name, location, scale, mat, subdivisions=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return assign(obj, mat)


def box(name, location, scale, mat, rotation=(0, 0, 0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        modifier = obj.modifiers.new("Worn edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
    return assign(obj, mat)


def torus(name, location, major, minor, mat, rotation=(0, 0, 0), segments=12):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=segments, minor_segments=5, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    return assign(obj, mat)


def parent_all(root_name):
    root = bpy.data.objects.new(root_name, None)
    bpy.context.collection.objects.link(root)
    for obj in list(bpy.context.scene.objects):
        if obj != root and obj.parent is None:
            obj.parent = root
    return root


def export_model(filename, root):
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT / filename),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
    )


def build_archivist():
    clear_scene()
    cone("Eightfold robe", 0.0, 1.18, 0.48, 0.27, INK, 10)
    cone("Brass hem", 0.02, 0.12, 0.51, 0.48, BRASS, 10)
    cone("Shoulders", 1.05, 0.35, 0.3, 0.39, BLUE, 10)
    sphere("Porcelain mask", (0, -0.03, 1.63), (0.25, 0.2, 0.3), BONE, 2)
    box("Mask slit", (0, -0.197, 1.65), (0.12, 0.018, 0.022), CYAN)
    torus("Mantle", (0, 0, 1.31), 0.36, 0.055, BRASS, segments=16)
    # A sharply folded cape gives the top-down silhouette a readable direction.
    cape_verts = [(-0.35, 0.12, 1.33), (0.35, 0.12, 1.33), (0.28, 0.36, 0.2), (0, 0.62, 0.0), (-0.28, 0.36, 0.2)]
    cape_faces = [(0, 1, 2, 3, 4)]
    mesh = bpy.data.meshes.new("CapeFoldMesh")
    mesh.from_pydata(cape_verts, [], cape_faces)
    cape = bpy.data.objects.new("Memory Cape", mesh)
    bpy.context.collection.objects.link(cape)
    assign(cape, BLUE)
    sphere("Lantern heart", (0, -0.43, 1.1), (0.16, 0.16, 0.22), AMBER, 2)
    torus("Lantern cage upper", (0, -0.43, 1.26), 0.19, 0.025, BRASS, rotation=(math.pi / 2, 0, 0), segments=10)
    torus("Lantern cage lower", (0, -0.43, 0.94), 0.19, 0.025, BRASS, rotation=(math.pi / 2, 0, 0), segments=10)
    for x in (-0.17, 0.17):
        box("Lantern rail", (x, -0.43, 1.1), (0.025, 0.025, 0.2), BRASS)
    root = parent_all("Lamplighter")
    export_model("archivist.glb", root)


def build_hollow():
    clear_scene()
    cone("Torn memory", 0.0, 1.28, 0.5, 0.2, BLUE, 7)
    cone("Inverted collar", 1.12, 0.34, 0.24, 0.45, INK, 7)
    sphere("Empty face", (0, -0.04, 1.6), (0.26, 0.19, 0.3), INK, 1)
    sphere("Hungry index", (0, -0.185, 1.61), (0.085, 0.035, 0.085), MAGENTA, 2)
    for side in (-1, 1):
        box("Broken arm", (side * 0.41, 0, 0.88), (0.08, 0.08, 0.42), BLUE, rotation=(0, side * 0.16, side * 0.35))
    root = parent_all("Hollow")
    export_model("hollow.glb", root)


def build_murmur():
    clear_scene()
    cone("Whisper body", 0.12, 1.28, 0.33, 0.15, MAGENTA, 6)
    torus("Open mouth", (0, -0.18, 1.55), 0.22, 0.045, BONE, rotation=(math.pi / 2, 0, 0), segments=10)
    sphere("Spoken absence", (0, -0.2, 1.55), (0.14, 0.04, 0.14), INK, 1)
    for index, angle in enumerate((-0.8, 0, 0.8)):
        sphere(f"Orbit word {index}", (math.sin(angle) * 0.5, 0.1, 1.0 + math.cos(angle) * 0.38), (0.07, 0.07, 0.07), MAGENTA, 1)
    box("Spine", (0, 0.06, 0.83), (0.055, 0.055, 0.63), BRASS)
    root = parent_all("Murmur")
    export_model("murmur.glb", root)


def build_keeper():
    clear_scene()
    cone("Keeper mass", 0.0, 1.48, 0.68, 0.42, MOSS, 8)
    box("Index chest", (0, -0.35, 1.02), (0.47, 0.11, 0.36), BRASS, bevel=0.035)
    sphere("Sealed face", (0, -0.02, 1.7), (0.34, 0.27, 0.3), INK, 1)
    box("Single clause", (0, -0.25, 1.72), (0.14, 0.025, 0.035), AMBER)
    for side in (-1, 1):
        box("Catalogue shield", (side * 0.56, -0.02, 0.9), (0.17, 0.28, 0.57), MOSS, rotation=(0, 0, side * 0.08), bevel=0.035)
        box("Shield inlay", (side * 0.56, -0.305, 0.9), (0.08, 0.015, 0.37), BRASS)
    root = parent_all("Keeper")
    export_model("keeper.glb", root)


def build_warden():
    clear_scene()
    cone("Warden robe", 0.0, 2.12, 0.86, 0.4, MAGENTA, 10)
    cone("Warden breast", 1.5, 0.72, 0.45, 0.72, INK, 10)
    sphere("Erased librarian", (0, -0.03, 2.48), (0.43, 0.31, 0.42), BONE, 2)
    box("Final index", (0, -0.294, 2.49), (0.22, 0.024, 0.055), MAGENTA)
    for index, radius in enumerate((0.57, 0.76, 0.95)):
        torus(f"Mandate halo {index}", (0, 0.12, 2.5), radius, 0.025 + index * 0.007, BRASS if index != 1 else MAGENTA, rotation=(math.pi / 2, 0, 0), segments=18)
    for side in (-1, 1):
        box("Archive arm", (side * 0.83, 0, 1.35), (0.14, 0.17, 0.72), INK, rotation=(0, side * 0.08, side * 0.22), bevel=0.025)
        sphere("Warden hand", (side * 1.0, -0.02, 0.78), (0.2, 0.17, 0.2), BRASS, 1)
    root = parent_all("IndexWarden")
    export_model("warden.glb", root)


if __name__ == "__main__":
    build_archivist()
    build_hollow()
    build_murmur()
    build_keeper()
    build_warden()
    print(f"Generated PALIMPSEST models in {OUTPUT}")
