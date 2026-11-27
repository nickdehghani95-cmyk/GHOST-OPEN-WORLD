extends CharacterBody3D

@export var move_speed: float = 4.5
@export var acceleration: float = 14.0
@export var gravity: float = 18.0

var outfit_material: StandardMaterial3D

func _ready() -> void:
    _setup_input()
    _build_reference_outfit_character()

func _setup_input() -> void:
    var keys := {"move_left": KEY_A, "move_right": KEY_D, "move_forward": KEY_W, "move_back": KEY_S, "jump": KEY_SPACE}
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var event := InputEventKey.new()
            event.physical_keycode = keys[action]
            InputMap.action_add_event(action, event)

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.88
    return m

func _capsule(parent: Node3D, label: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)

func _sphere(parent: Node3D, label: String, radius: float, pos: Vector3, material: Material) -> void:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)

func _box(parent: Node3D, label: String, size: Vector3, pos: Vector3, material: Material) -> void:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := BoxMesh.new()
    mesh.size = size
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)

func _build_reference_outfit_character() -> void:
    # Original avatar inspired by the supplied black streetwear reference.
    var jacket := _mat(Color(0.035, 0.04, 0.045))
    outfit_material = jacket
    var fabric := _mat(Color(0.075, 0.08, 0.085))
    var pants := _mat(Color(0.025, 0.03, 0.035))
    var hair := _mat(Color(0.018, 0.014, 0.012))
    var skin := _mat(Color(0.62, 0.43, 0.32))
    var shoes := _mat(Color(0.025, 0.028, 0.032))
    var trim := _mat(Color(0.62, 0.62, 0.60))

    var avatar := Node3D.new()
    avatar.name = "BlackStreetwearAvatar"
    add_child(avatar)

    _capsule(avatar, "HoodieTorso", 0.34, 0.82, Vector3(0, 1.12, 0), jacket)
    _capsule(avatar, "Shoulders", 0.38, 0.30, Vector3(0, 1.48, 0), jacket)
    _capsule(avatar, "Neck", 0.105, 0.18, Vector3(0, 1.66, 0), skin)
    _sphere(avatar, "Head", 0.205, Vector3(0, 1.88, 0), skin)

    # Dense curls create the rounded curly hairstyle seen in the reference.
    _sphere(avatar, "HairBase", 0.225, Vector3(0, 2.015, 0.015), hair)
    for row in range(3):
        for i in range(10):
            var angle := TAU * float(i) / 10.0 + float(row) * 0.2
            var radius := 0.16 if row < 2 else 0.11
            _sphere(avatar, "Curl_%d_%d" % [row, i], 0.073, Vector3(cos(angle) * radius, 2.00 + float(row) * 0.065, sin(angle) * radius), hair)
    for i in range(5):
        _sphere(avatar, "TopCurl_%d" % i, 0.07, Vector3((float(i) - 2.0) * 0.07, 2.14, 0), hair)

    _capsule(avatar, "LeftSleeve", 0.12, 0.52, Vector3(-0.43, 1.27, 0), jacket)
    _capsule(avatar, "LeftForearm", 0.095, 0.38, Vector3(-0.46, 0.91, 0), fabric)
    _capsule(avatar, "RightSleeve", 0.12, 0.52, Vector3(0.43, 1.27, 0), jacket)
    _capsule(avatar, "RightForearm", 0.095, 0.38, Vector3(0.46, 0.91, 0), fabric)
    _sphere(avatar, "LeftGlove", 0.09, Vector3(-0.46, 0.68, 0), shoes)
    _sphere(avatar, "RightGlove", 0.09, Vector3(0.46, 0.68, 0), shoes)

    _capsule(avatar, "Waist", 0.27, 0.35, Vector3(0, 0.72, 0), pants)
    _capsule(avatar, "LeftCargoLeg", 0.14, 0.62, Vector3(-0.17, 0.34, 0), pants)
    _capsule(avatar, "RightCargoLeg", 0.14, 0.62, Vector3(0.17, 0.34, 0), pants)
    _box(avatar, "LeftCargoPocket", Vector3(0.12, 0.20, 0.08), Vector3(-0.29, 0.43, -0.015), fabric)
    _box(avatar, "RightCargoPocket", Vector3(0.12, 0.20, 0.08), Vector3(0.29, 0.43, -0.015), fabric)
    _box(avatar, "LeftSneaker", Vector3(0.19, 0.12, 0.32), Vector3(-0.17, 0.055, -0.07), shoes)
    _box(avatar, "RightSneaker", Vector3(0.19, 0.12, 0.32), Vector3(0.17, 0.055, -0.07), shoes)
    _box(avatar, "LeftSole", Vector3(0.195, 0.035, 0.325), Vector3(-0.17, 0.012, -0.07), trim)
    _box(avatar, "RightSole", Vector3(0.195, 0.035, 0.325), Vector3(0.17, 0.012, -0.07), trim)

    _sphere(avatar, "HoodBehindHead", 0.24, Vector3(0, 1.66, 0.12), fabric)
    _box(avatar, "LeftChestPocket", Vector3(0.13, 0.16, 0.035), Vector3(-0.19, 1.30, -0.30), fabric)
    _box(avatar, "RightChestPocket", Vector3(0.13, 0.16, 0.035), Vector3(0.19, 1.30, -0.30), fabric)
    _box(avatar, "SleevePatchLeft", Vector3(0.11, 0.10, 0.025), Vector3(-0.53, 1.35, -0.015), trim)
    _box(avatar, "SleevePatchRight", Vector3(0.11, 0.10, 0.025), Vector3(0.53, 1.35, -0.015), trim)
    _sphere(avatar, "ChainPendant", 0.035, Vector3(0, 1.02, -0.32), trim)

func _physics_process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    direction = $CameraPivot.global_transform.basis * direction
    direction.y = 0.0
    direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = 5.0
    if direction.length() > 0.1:
        look_at(global_position + direction, Vector3.UP)
    move_and_slide()

func set_outfit_color(color: Color) -> void:
    if outfit_material:
        outfit_material.albedo_color = color
