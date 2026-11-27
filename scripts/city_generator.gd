extends Node3D

# Procedural futuristic Tehran blockout. Static ground collision keeps the player grounded.
@export var blocks_per_side: int = 7
@export var block_size: float = 24.0
@export var road_width: float = 12.0
@export var building_height_min: float = 8.0
@export var building_height_max: float = 28.0

var rng := RandomNumberGenerator.new()
var concrete_mat := StandardMaterial3D.new()
var road_mat := StandardMaterial3D.new()
var building_mats: Array[StandardMaterial3D] = []
var window_mat := StandardMaterial3D.new()

func _ready() -> void:
    rng.seed = 2050
    concrete_mat.albedo_color = Color(0.27, 0.29, 0.31)
    road_mat.albedo_color = Color(0.045, 0.055, 0.07)
    window_mat.albedo_color = Color(0.22, 0.68, 0.92)
    window_mat.emission_enabled = true
    window_mat.emission = Color(0.08, 0.38, 0.72)
    window_mat.emission_energy_multiplier = 0.65
    for tint in [Color(0.31, 0.34, 0.39), Color(0.38, 0.36, 0.34), Color(0.25, 0.31, 0.36), Color(0.43, 0.40, 0.36)]:
        var material := StandardMaterial3D.new()
        material.albedo_color = tint
        material.roughness = 0.9
        building_mats.append(material)
    _build_city()

func _build_city() -> void:
    var total := blocks_per_side * block_size + (blocks_per_side + 1) * road_width
    _add_box("CityGround", Vector3(total, 0.3, total), Vector3(0, -0.18, 0), concrete_mat, true)

    for i in range(blocks_per_side + 1):
        var offset := -total * 0.5 + road_width * 0.5 + i * (block_size + road_width)
        _add_box("Road_NS_%d" % i, Vector3(road_width, 0.06, total), Vector3(offset, -0.035, 0), road_mat, false)
        _add_box("Road_EW_%d" % i, Vector3(total, 0.06, road_width), Vector3(0, -0.03, offset), road_mat, false)
        _add_box("RoadLine_NS_%d" % i, Vector3(0.12, 0.012, total), Vector3(offset, 0.002, 0), window_mat, false)
        _add_box("RoadLine_EW_%d" % i, Vector3(total, 0.012, 0.12), Vector3(0, 0.004, offset), window_mat, false)

    for x in range(blocks_per_side):
        for z in range(blocks_per_side):
            var center_x := -total * 0.5 + road_width + block_size * 0.5 + x * (block_size + road_width)
            var center_z := -total * 0.5 + road_width + block_size * 0.5 + z * (block_size + road_width)
            _make_building_block(Vector3(center_x, 0, center_z), x, z)

func _make_building_block(center: Vector3, grid_x: int, grid_z: int) -> void:
    var count := rng.randi_range(1, 3)
    for index in range(count):
        var width := rng.randf_range(7.0, 11.0)
        var depth := rng.randf_range(7.0, 11.0)
        var height := rng.randf_range(building_height_min, building_height_max)
        var local_x := rng.randf_range(-4.0, 4.0)
        var local_z := rng.randf_range(-4.0, 4.0)
        var pos := center + Vector3(local_x, height * 0.5, local_z)
        var size := Vector3(width, height, depth)
        var material: Material = building_mats[rng.randi_range(0, building_mats.size() - 1)]
        _add_box("Building_%d_%d_%d" % [grid_x, grid_z, index], size, pos, material, true)
        for floor_index in range(int(height / 3.2)):
            _add_box("Window_%d_%d_%d_%d" % [grid_x, grid_z, index, floor_index], Vector3(width * 0.72, 0.12, 0.035), Vector3(pos.x, 1.8 + float(floor_index) * 3.2, pos.z - depth * 0.5 - 0.025), window_mat, false)

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
