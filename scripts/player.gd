extends CharacterBody3D

@export var move_speed: float = 4.5
@export var acceleration: float = 14.0
@export var gravity: float = 18.0

var outfit_material: StandardMaterial3D

func _ready() -> void:
    _setup_input()
    _build_humanoid_operator()

func _setup_input() -> void:
    var keys := {
        "move_left": KEY_A, "move_right": KEY_D,
        "move_forward": KEY_W, "move_back": KEY_S,
        "jump": KEY_SPACE
    }
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var event := InputEventKey.new()
            event.physical_keycode = keys[action]
            InputMap.action_add_event(action, event)

func _make_capsule(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = node_name
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)
    return part

func _make_sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = node_name
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)
    return part

func _build_humanoid_operator() -> void:
    var uniform := StandardMaterial3D.new()
    uniform.albedo_color = Color(0.105, 0.12, 0.13)
    uniform.roughness = 0.92
    outfit_material = uniform

    var dark_gear := StandardMaterial3D.new()
    dark_gear.albedo_color = Color(0.045, 0.055, 0.06)
    dark_gear.roughness = 0.85

    var mask_material := StandardMaterial3D.new()
    mask_material.albedo_color = Color(0.72, 0.70, 0.63)
    mask_material.roughness = 0.95

    var black := StandardMaterial3D.new()
    black.albedo_color = Color(0.012, 0.015, 0.018)

    var skin := Node3D.new()
    skin.name = "HumanoidGhostStyleOperator"
    add_child(skin)

    # Human proportions: torso, pelvis, head and separate articulated-looking limbs.
    _make_capsule(skin, "Torso", 0.34, 0.82, Vector3(0, 1.12, 0), uniform)
    _make_capsule(skin, "ShoulderRig", 0.39, 0.34, Vector3(0, 1.48, 0), dark_gear)
    _make_capsule(skin, "Pelvis", 0.27, 0.42, Vector3(0, 0.69, 0), dark_gear)

    _make_capsule(skin, "LeftUpperArm", 0.115, 0.48, Vector3(-0.43, 1.28, 0), uniform)
    _make_capsule(skin, "LeftForearm", 0.095, 0.43, Vector3(-0.47, 0.91, -0.015), dark_gear)
    _make_capsule(skin, "RightUpperArm", 0.115, 0.48, Vector3(0.43, 1.28, 0), uniform)
    _make_capsule(skin, "RightForearm", 0.095, 0.43, Vector3(0.47, 0.91, -0.015), dark_gear)

    _make_capsule(skin, "LeftThigh", 0.145, 0.56, Vector3(-0.17, 0.40, 0), uniform)
    _make_capsule(skin, "LeftShin", 0.105, 0.48, Vector3(-0.17, 0.13, 0), dark_gear)
    _make_capsule(skin, "RightThigh", 0.145, 0.56, Vector3(0.17, 0.40, 0), uniform)
    _make_capsule(skin, "RightShin", 0.105, 0.48, Vector3(0.17, 0.13, 0), dark_gear)

    _make_sphere(skin, "Head", 0.205, Vector3(0, 1.88, 0), dark_gear)
    _make_sphere(skin, "SkullStyleMask", 0.17, Vector3(0, 1.86, -0.105), mask_material)
    _make_sphere(skin, "LeftEyeLens", 0.052, Vector3(-0.078, 1.89, -0.255), black)
    _make_sphere(skin, "RightEyeLens", 0.052, Vector3(0.078, 1.89, -0.255), black)
    _make_sphere(skin, "Helmet", 0.225, Vector3(0, 2.035, 0.005), dark_gear)

    # Chest rig and compact utility pouches add readable tactical detail.
    _make_capsule(skin, "ChestRig", 0.245, 0.48, Vector3(0, 1.25, -0.035), dark_gear)
    _make_sphere(skin, "LeftShoulderPad", 0.14, Vector3(-0.39, 1.48, 0), dark_gear)
    _make_sphere(skin, "RightShoulderPad", 0.14, Vector3(0.39, 1.48, 0), dark_gear)

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
