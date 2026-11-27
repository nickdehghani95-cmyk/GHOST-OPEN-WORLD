extends Node3D

# Original procedural futuristic Tehran district. This is a playable art blockout,
# not a finished AAA asset pack. All geometry is generated at runtime.
@export var blocks_per_side: int = 7
@export var block_size: float = 24.0
@export var road_width: float = 12.0
@export var building_height_min: float = 10.0
@export var building_height_max: float = 34.0

var rng := RandomNumberGenerator.new()
var ground_mat := StandardMaterial3D.new()
var road_mat := StandardMaterial3D.new()
var sidewalk_mat := StandardMaterial3D.new()
var line_mat := StandardMaterial3D.new()
var glass_mat := StandardMaterial3D.new()
var trim_mat := StandardMaterial3D.new()
var building_mats: Array[StandardMaterial3D] = []

func _ready() -> void:
    rng.seed = 2050
    ground_mat.albedo_color = Color(0.20, 0.22, 0.24)
    road_mat.albedo_color = Color(0.035, 0.045, 0.058)
    road_mat.roughness = 0.94
    sidewalk_mat.albedo_color = Color(0.42, 0.43, 0.42)
    line_mat.albedo_color = Color(0.88, 0.78, 0.48)
    glass_mat.albedo_color = Color(0.10, 0.30, 0.42)
    glass_mat.metallic = 0.35
    glass_mat.roughness = 0.22
    glass_mat.emission_enabled = true
    glass_mat.emission = Color(0.025, 0.12, 0.19)
    glass_mat.emission_energy_multiplier = 0.45
    trim_mat.albedo_color = Color(0.16, 0.18, 0.20)
    trim_mat.metallic = 0.55
    for tint in [Color(0.37, 0.38, 0.39), Color(0.48, 0.43, 0.37), Color(0.28, 0.34, 0.39), Color(0.53, 0.52, 0.48), Color(0.30, 0.31, 0.33)]:
        var material := StandardMaterial3D.new()
        material.albedo_color = tint
        material.roughness = 0.86
        building_mats.append(material)
    _build_city()

func _build_city() -> void:
    var total := blocks_per_side * block_size + (blocks_per_side + 1) * road_width
    _add_box("CityGround", Vector3(total + 90.0, 0.3, total + 150.0), Vector3(0, -0.22, 25.0), ground_mat, true)

    # Asphalt, sidewalks and clear lane markings.
    for i in range(blocks_per_side + 1):
        var offset := -total * 0.5 + road_width * 0.5 + i * (block_size + road_width)
        _add_box("Road_NS_%d" % i, Vector3(road_width, 0.07, total + 70.0), Vector3(offset, -0.035, 0), road_mat, false)
        _add_box("Road_EW_%d" % i, Vector3(total + 70.0, 0.07, road_width), Vector3(0, -0.035, offset), road_mat, false)
        _add_box("Sidewalk_NS_A_%d" % i, Vector3(1.7, 0.20, total + 70.0), Vector3(offset - road_width * 0.5 - 0.85, 0.02, 0), sidewalk_mat, false)
        _add_box("Sidewalk_NS_B_%d" % i, Vector3(1.7, 0.20, total + 70.0), Vector3(offset + road_width * 0.5 + 0.85, 0.02, 0), sidewalk_mat, false)
        _add_box("Sidewalk_EW_A_%d" % i, Vector3(total + 70.0, 0.20, 1.7), Vector3(0, 0.02, offset - road_width * 0.5 - 0.85), sidewalk_mat, false)
        _add_box("Sidewalk_EW_B_%d" % i, Vector3(total + 70.0, 0.20, 1.7), Vector3(0, 0.02, offset + road_width * 0.5 + 0.85), sidewalk_mat, false)
        # Broken center line dashes, not a single glowing stripe.
        for dash in range(0, int((total + 60.0) / 9.0)):
            var along := -total * 0.5 - 25.0 + float(dash) * 9.0
            _add_box("LaneDash_NS_%d_%d" % [i, dash], Vector3(0.13, 0.018, 3.8), Vector3(offset, 0.012, along), line_mat, false)
            _add_box("LaneDash_EW_%d_%d" % [i, dash], Vector3(3.8, 0.018, 0.13), Vector3(along, 0.012, offset), line_mat, false)
        if i % 2 == 0:
            _make_street_lamp(Vector3(offset - 3.0, 0, -total * 0.35))
            _make_street_lamp(Vector3(offset + 3.0, 0, total * 0.30))

    for x in range(blocks_per_side):
        for z in range(blocks_per_side):
            var center_x := -total * 0.5 + road_width + block_size * 0.5 + x * (block_size + road_width)
            var center_z := -total * 0.5 + road_width + block_size * 0.5 + z * (block_size + road_width)
            _make_building_block(Vector3(center_x, 0, center_z), x, z)

    _make_milad_tower(Vector3(0, 0, -total * 0.5 - 30.0))
    _make_mountain_ridge(total)
    _make_traffic_props(total)

func _make_building_block(center: Vector3, grid_x: int, grid_z: int) -> void:
    var count := rng.randi_range(1, 3)
    for index in range(count):
        var width := rng.randf_range(6.5, 10.0)
        var depth := rng.randf_range(6.5, 10.0)
        var height := rng.randf_range(building_height_min, building_height_max)
        var local_x := rng.randf_range(-4.2, 4.2)
        var local_z := rng.randf_range(-4.2, 4.2)
        var pos := center + Vector3(local_x, height * 0.5, local_z)
        var size := Vector3(width, height, depth)
        var material: Material = building_mats[rng.randi_range(0, building_mats.size() - 1)]
        _add_box("Building_%d_%d_%d" % [grid_x, grid_z, index], size, pos, material, true)
        _add_box("RoofRim_%d_%d_%d" % [grid_x, grid_z, index], Vector3(width + 0.25, 0.24, depth + 0.25), Vector3(pos.x, height + 0.12, pos.z), trim_mat, false)
        var floors := int(height / 3.2)
        for floor_index in range(floors):
            var wy := 2.0 + float(floor_index) * 3.2
            # Front and back window bands.
            for side in [-1.0, 1.0]:
                _add_box("WindowFront_%d_%d_%d_%d_%d" % [grid_x, grid_z, index, floor_index, int(side)], Vector3(width * 0.72, 1.05, 0.045), Vector3(pos.x, wy, pos.z + side * (depth * 0.5 + 0.026)), glass_mat, false)
                _add_box("WindowSide_%d_%d_%d_%d_%d" % [grid_x, grid_z, index, floor_index, int(side)], Vector3(0.045, 1.05, depth * 0.68), Vector3(pos.x + side * (width * 0.5 + 0.026), wy, pos.z), glass_mat, false)
        # A visible entrance helps establish scale and street-level detail.
        _add_box("Entrance_%d_%d_%d" % [grid_x, grid_z, index], Vector3(1.7, 2.6, 0.12), Vector3(pos.x, 1.3, pos.z - depth * 0.5 - 0.07), trim_mat, false)

func _make_street_lamp(pos: Vector3) -> void:
    var pole_mat := trim_mat
    _add_cylinder("LampPole", 0.075, 5.2, pos + Vector3(0, 2.6, 0), pole_mat, false)
    _add_box("LampArm", Vector3(1.0, 0.09, 0.09), pos + Vector3(0.42, 5.05, 0), pole_mat, false)
    var lamp_mat := StandardMaterial3D.new()
    lamp_mat.albedo_color = Color(1.0, 0.82, 0.55)
    lamp_mat.emission_enabled = true
    lamp_mat.emission = Color(1.0, 0.62, 0.28)
    lamp_mat.emission_energy_multiplier = 1.2
    _add_box("LampHead", Vector3(0.42, 0.14, 0.28), pos + Vector3(0.82, 4.98, 0), lamp_mat, false)

func _make_milad_tower(base: Vector3) -> void:
    var tower_mat := StandardMaterial3D.new()
    tower_mat.albedo_color = Color(0.62, 0.67, 0.70)
    tower_mat.metallic = 0.72
    tower_mat.roughness = 0.3
    var pod_mat := StandardMaterial3D.new()
    pod_mat.albedo_color = Color(0.24, 0.36, 0.43)
    pod_mat.metallic = 0.55
    pod_mat.roughness = 0.25
    _add_cylinder("MiladTowerShaft", 1.15, 54.0, base + Vector3(0, 27.0, 0), tower_mat, false)
    _add_cylinder("MiladTowerLowerPod", 4.6, 2.4, base + Vector3(0, 39.0, 0), pod_mat, false)
    _add_cylinder("MiladTowerUpperPod", 3.2, 2.0, base + Vector3(0, 42.0, 0), pod_mat, false)
    _add_cylinder("MiladTowerCrown", 1.7, 3.0, base + Vector3(0, 44.5, 0), tower_mat, false)
    _add_cylinder("MiladTowerAntenna", 0.18, 14.0, base + Vector3(0, 53.0, 0), tower_mat, false)

func _make_mountain_ridge(total: float) -> void:
    var mountain_mat := StandardMaterial3D.new()
    mountain_mat.albedo_color = Color(0.36, 0.42, 0.48)
    mountain_mat.roughness = 1.0
    for i in range(9):
        var cone := MeshInstance3D.new()
        cone.name = "AlborzPeak_%d" % i
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.0
        mesh.bottom_radius = rng.randf_range(24.0, 42.0)
        mesh.height = rng.randf_range(75.0, 120.0)
        mesh.radial_segments = 7
        cone.mesh = mesh
        cone.position = Vector3(-total * 0.65 + float(i) * total * 0.16, mesh.height * 0.28, -total * 0.5 - 100.0 - rng.randf_range(0.0, 28.0))
        cone.material_override = mountain_mat
        add_child(cone)

func _make_traffic_props(total: float) -> void:
    var car_paints: Array[Color] = [Color(0.055, 0.07, 0.085), Color(0.68, 0.66, 0.58), Color(0.55, 0.12, 0.08), Color(0.12, 0.25, 0.34)]
    for i in range(12):
        var car := Node3D.new()
        car.name = "ParkedCar_%d" % i
        var x := -total * 0.38 + float(i % 6) * 22.0
        var z := -total * 0.34 + float(i / 6) * 38.0
        car.position = Vector3(x, 0.0, z)
        add_child(car)
        var paint := StandardMaterial3D.new()
        paint.albedo_color = car_paints[i % car_paints.size()]
        paint.metallic = 0.55
        paint.roughness = 0.28
        var glass := StandardMaterial3D.new()
        glass.albedo_color = Color(0.035, 0.09, 0.12)
        glass.metallic = 0.3
        _add_child_box(car, "CarBody", Vector3(2.0, 0.62, 4.1), Vector3(0, 0.72, 0), paint)
        _add_child_box(car, "CarCabin", Vector3(1.55, 0.65, 2.0), Vector3(0, 1.28, 0.15), glass)
        for side in [-1.0, 1.0]:
            for front in [-1.0, 1.0]:
                _add_child_cylinder(car, "Wheel", 0.36, 0.22, Vector3(side * 1.0, 0.38, front * 1.25), trim_mat)

func _add_child_box(parent: Node3D, label: String, box_size: Vector3, pos: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = label
    var mesh := BoxMesh.new()
    mesh.size = box_size
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)

func _add_child_cylinder(parent: Node3D, label: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = label
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    mesh_instance.rotation_degrees.z = 90.0
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)

func _add_cylinder(label: String, radius: float, height: float, pos: Vector3, material: Material, solid: bool) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = label
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    mesh_instance.material_override = material
    add_child(mesh_instance)
    if solid:
        var body := StaticBody3D.new()
        body.position = pos
        var collision := CollisionShape3D.new()
        var shape := CylinderShape3D.new()
        shape.radius = radius
        shape.height = height
        collision.shape = shape
        body.add_child(collision)
        add_child(body)

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
