extends CharacterBody3D

@export var move_speed: float = 5.2
@export var acceleration: float = 18.0
@export var gravity: float = 20.0
@export var jump_velocity: float = 5.2

var jacket_material: StandardMaterial3D

func _ready() -> void:
    _setup_input()
    _build_ghost_character()

func _setup_input() -> void:
    var keys := {"move_left": KEY_A, "move_right": KEY_D, "move_forward": KEY_W, "move_back": KEY_S, "jump": KEY_SPACE}
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var event := InputEventKey.new()
            event.physical_keycode = keys[action]
            InputMap.action_add_event(action, event)

func _mat(color: Color, metallic: float = 0.0, roughness: float = 0.82) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m

func _capsule(parent: Node3D, label: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)
    return part

func _sphere(parent: Node3D, label: String, radius: float, pos: Vector3, material: Material, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    part.mesh = mesh
    part.position = pos
    part.scale = scale_value
    part.material_override = material
    parent.add_child(part)
    return part

func _box(parent: Node3D, label: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = label
    var mesh := BoxMesh.new()
    mesh.size = size
    part.mesh = mesh
    part.position = pos
    part.material_override = material
    parent.add_child(part)
    return part

func _build_ghost_character() -> void:
    var black := _mat(Color(0.018, 0.022, 0.028))
    jacket_material = black
    var fabric := _mat(Color(0.055, 0.065, 0.075))
    var armor := _mat(Color(0.085, 0.095, 0.105), 0.18)
    var pants := _mat(Color(0.025, 0.03, 0.038))
    var mask := _mat(Color(0.78, 0.79, 0.76), 0.05, 0.62)
    var dark := _mat(Color(0.008, 0.01, 0.014))
    var metal := _mat(Color(0.42, 0.46, 0.5), 0.72, 0.32)
    var boot := _mat(Color(0.012, 0.016, 0.022))

    var avatar := Node3D.new()
    avatar.name = "GhostOperator"
    add_child(avatar)

    # Hood and skull-pattern mask: original procedural game model, not a copied game asset.
    _capsule(avatar, "TacticalTorso", 0.34, 0.82, Vector3(0, 1.15, 0), black)
    _capsule(avatar, "ShoulderArmor", 0.39, 0.28, Vector3(0, 1.49, 0), fabric)
    _sphere(avatar, "Hood", 0.29, Vector3(0, 1.69, 0.07), black, Vector3(1.0, 1.12, 0.92))
    _sphere(avatar, "HeadUnderMask", 0.205, Vector3(0, 1.88, 0), dark, Vector3(0.95, 1.12, 0.9))
    _sphere(avatar, "SkullMask", 0.19, Vector3(0, 1.88, -0.105), mask, Vector3(0.94, 1.08, 0.48))
    _sphere(avatar, "LeftEyeSocket", 0.052, Vector3(-0.078, 1.925, -0.194), dark, Vector3(1.0, 0.85, 0.38))
    _sphere(avatar, "RightEyeSocket", 0.052, Vector3(0.078, 1.925, -0.194), dark, Vector3(1.0, 0.85, 0.38))
    _sphere(avatar, "NoseMark", 0.035, Vector3(0, 1.84, -0.205), dark, Vector3(0.8, 1.0, 0.45))
    for i in range(5):
        _box(avatar, "MaskTeeth_%d" % i, Vector3(0.022, 0.055, 0.018), Vector3((float(i) - 2.0) * 0.035, 1.785, -0.197), dark)
    _sphere(avatar, "LeftHeadset", 0.09, Vector3(-0.205, 1.88, 0.015), armor)
    _sphere(avatar, "RightHeadset", 0.09, Vector3(0.205, 1.88, 0.015), armor)

    _capsule(avatar, "LeftUpperArm", 0.115, 0.48, Vector3(-0.42, 1.28, 0), fabric)
    _capsule(avatar, "RightUpperArm", 0.115, 0.48, Vector3(0.42, 1.28, 0), fabric)
    _capsule(avatar, "LeftForearm", 0.095, 0.38, Vector3(-0.45, 0.91, -0.015), black)
    _capsule(avatar, "RightForearm", 0.095, 0.38, Vector3(0.45, 0.91, -0.015), black)
    _sphere(avatar, "LeftGlove", 0.09, Vector3(-0.45, 0.68, -0.02), dark)
    _sphere(avatar, "RightGlove", 0.09, Vector3(0.45, 0.68, -0.02), dark)

    _box(avatar, "TacticalVest", Vector3(0.57, 0.52, 0.18), Vector3(0, 1.23, -0.235), armor)
    for i in range(4):
        _box(avatar, "VestPouch_%d" % i, Vector3(0.105, 0.16, 0.09), Vector3((float(i) - 1.5) * 0.13, 1.12, -0.345), fabric)
    _box(avatar, "ChestLabel", Vector3(0.20, 0.07, 0.018), Vector3(0, 1.40, -0.337), dark)
    _box(avatar, "Backpack", Vector3(0.43, 0.54, 0.19), Vector3(0, 1.28, 0.23), fabric)
    _box(avatar, "LeftShoulderPatch", Vector3(0.13, 0.10, 0.035), Vector3(-0.49, 1.37, -0.04), metal)

    _capsule(avatar, "Waist", 0.27, 0.32, Vector3(0, 0.72, 0), pants)
    _capsule(avatar, "LeftCargoLeg", 0.135, 0.62, Vector3(-0.17, 0.34, 0), pants)
    _capsule(avatar, "RightCargoLeg", 0.135, 0.62, Vector3(0.17, 0.34, 0), pants)
    _box(avatar, "LeftCargoPocket", Vector3(0.13, 0.19, 0.09), Vector3(-0.28, 0.42, -0.04), fabric)
    _box(avatar, "RightCargoPocket", Vector3(0.13, 0.19, 0.09), Vector3(0.28, 0.42, -0.04), fabric)
    _box(avatar, "LeftCombatBoot", Vector3(0.20, 0.16, 0.34), Vector3(-0.17, 0.08, -0.065), boot)
    _box(avatar, "RightCombatBoot", Vector3(0.20, 0.16, 0.34), Vector3(0.17, 0.08, -0.065), boot)
    _box(avatar, "LeftBootSole", Vector3(0.205, 0.035, 0.35), Vector3(-0.17, 0.012, -0.065), metal)
    _box(avatar, "RightBootSole", Vector3(0.205, 0.035, 0.35), Vector3(0.17, 0.012, -0.065), metal)

func _physics_process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    if direction.length() > 0.01:
        direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    if direction.length() > 0.1:
        look_at(global_position + direction, Vector3.UP)
    move_and_slide()

func set_outfit_color(color: Color) -> void:
    if jacket_material:
        jacket_material.albedo_color = color
