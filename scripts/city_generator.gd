extends Node3D

# Lightweight procedural city block for the first roaming prototype.
# Uses primitive meshes so the project has no external asset dependencies.

@export var blocks_per_side: int = 5
@export var block_size: float = 18.0
@export var road_width: float = 10.0
@export var building_height_min: float = 5.0
@export var building_height_max: float = 15.0

var rng := RandomNumberGenerator.new()
var concrete_mat := StandardMaterial3D.new()
var road_mat := StandardMaterial3D.new()
var building_mats: Array[StandardMaterial3D] = []

func _ready() -> void:
    rng.seed = 240519
    concrete_mat.albedo_color = Color(0.34, 0.35, 0.34)
    road_mat.albedo_color = Color(0.105, 0.115, 0.12)
    for tint in [Color(0.42, 0.40, 0.36), Color(0.36, 0.38, 0.39), Color(0.46, 0.43, 0.39)]:
        var material := StandardMaterial3D.new()
        material.albedo_color = tint
        building_mats.append(material)
    _build_city()

func _build_city() -> void:
    var total := blocks_per_side * block_size + (blocks_per_side + 1) * road_width
    _add_box("CityGround", Vector3(total, 0.2, total), Vector3(0, -0.2, 0), concrete_mat, false)

    # A regular road grid keeps navigation easy in this early prototype.
    for i in range(blocks_per_side + 1):
        var offset := -total * 0.5 + road_width * 0.5 + i * (block_size + road_width)
        _add_box("Road_NS_%d" % i, Vector3(road_width, 0.04, total), Vector3(offset, -0.07, 0), road_mat, false)
        _add_box("Road_EW_%d" % i, Vector3(total, 0.04, road_width), Vector3(0, -0.065, offset), road_mat, false)

    for x in range(blocks_per_side):
        for z in range(blocks_per_side):
            var center_x := -total * 0.5 + road_width + block_size * 0.5 + x * (block_size + road_width)
            var center_z := -total * 0.5 + road_width + block_size * 0.5 + z * (block_size + road_width)
            _make_building_block(Vector3(center_x, 0, center_z), x, z)

func _make_building_block(center: Vector3, grid_x: int, grid_z: int) -> void:
    var count := rng.randi_range(1, 3)
    for index in range(count):
        var width := rng.randf_range(5.0, 8.0)
        var depth := rng.randf_range(5.0, 8.0)
        var height := rng.randf_range(building_height_min, building_height_max)
        var local_x := rng.randf_range(-4.0, 4.0)
        var local_z := rng.randf_range(-4.0, 4.0)
        var pos := center + Vector3(local_x, height * 0.5, local_z)
        var size := Vector3(width, height, depth)
        var material: Material = building_mats[rng.randi_range(0, building_mats.size() - 1)]
        _add_box("Building_%d_%d_%d" % [grid_x, grid_z, index], size, pos, material, true)

func _add_box(node_name: String, box_size: Vector3, pos: Vector3, material: Material, solid: bool) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    var box := BoxMesh.new()
    box.size = box_size
    mesh_instance.mesh = box
    mesh_instance.position = pos
    mesh_instance.material_override = material
    add_child(mesh_instance)

    if solid:
        var body := StaticBody3D.new()
        body.name = node_name + "_Collision"
        body.position = pos
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = box_size
        collision.shape = shape
        body.add_child(collision)
        add_child(body)
