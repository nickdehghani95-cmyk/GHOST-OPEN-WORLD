extends CharacterBody3D

@export var move_speed: float = 5.2
@export var acceleration: float = 18.0
@export var gravity: float = 20.0
@export var jump_velocity: float = 5.2

var jacket_material: StandardMaterial3D
var avatar: Node3D
var animation_clock: float = 0.0
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D

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

    avatar = Node3D.new()
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

    left_arm_pivot = Node3D.new()
    left_arm_pivot.name = "LeftArmJoint"
    left_arm_pivot.position = Vector3(-0.42, 1.48, 0)
    avatar.add_child(left_arm_pivot)
    _capsule(left_arm_pivot, "LeftUpperArm", 0.115, 0.48, Vector3(0, -0.24, 0), fabric)
    _capsule(left_arm_pivot, "LeftForearm", 0.095, 0.38, Vector3(-0.025, -0.57, -0.015), black)
    _sphere(left_arm_pivot, "LeftGlove", 0.09, Vector3(-0.03, -0.80, -0.02), dark)

    right_arm_pivot = Node3D.new()
    right_arm_pivot.name = "RightArmJoint"
    right_arm_pivot.position = Vector3(0.42, 1.48, 0)
    avatar.add_child(right_arm_pivot)
    _capsule(right_arm_pivot, "RightUpperArm", 0.115, 0.48, Vector3(0, -0.24, 0), fabric)
    _capsule(right_arm_pivot, "RightForearm", 0.095, 0.38, Vector3(0.025, -0.57, -0.015), black)
    _sphere(right_arm_pivot, "RightGlove", 0.09, Vector3(0.03, -0.80, -0.02), dark)

    _box(avatar, "TacticalVest", Vector3(0.57, 0.52, 0.18), Vector3(0, 1.23, -0.235), armor)
    for i in range(4):
        _box(avatar, "VestPouch_%d" % i, Vector3(0.105, 0.16, 0.09), Vector3((float(i) - 1.5) * 0.13, 1.12, -0.345), fabric)
    _box(avatar, "ChestLabel", Vector3(0.20, 0.07, 0.018), Vector3(0, 1.40, -0.337), dark)
    _box(avatar, "Backpack", Vector3(0.43, 0.54, 0.19), Vector3(0, 1.28, 0.23), fabric)
    _box(avatar, "LeftShoulderPatch", Vector3(0.13, 0.10, 0.035), Vector3(-0.49, 1.37, -0.04), metal)

    _capsule(avatar, "Waist", 0.27, 0.32, Vector3(0, 0.72, 0), pants)
    left_leg_pivot = Node3D.new()
    left_leg_pivot.name = "LeftLegJoint"
    left_leg_pivot.position = Vector3(-0.17, 0.62, 0)
    avatar.add_child(left_leg_pivot)
    _capsule(left_leg_pivot, "LeftCargoLeg", 0.135, 0.62, Vector3(0, -0.31, 0), pants)
    _box(left_leg_pivot, "LeftCargoPocket", Vector3(0.13, 0.19, 0.09), Vector3(-0.11, -0.20, -0.04), fabric)
    _box(left_leg_pivot, "LeftCombatBoot", Vector3(0.20, 0.16, 0.34), Vector3(0, -0.54, -0.065), boot)
    _box(left_leg_pivot, "LeftBootSole", Vector3(0.205, 0.035, 0.35), Vector3(0, -0.608, -0.065), metal)

    right_leg_pivot = Node3D.new()
    right_leg_pivot.name = "RightLegJoint"
    right_leg_pivot.position = Vector3(0.17, 0.62, 0)
    avatar.add_child(right_leg_pivot)
    _capsule(right_leg_pivot, "RightCargoLeg", 0.135, 0.62, Vector3(0, -0.31, 0), pants)
    _box(right_leg_pivot, "RightCargoPocket", Vector3(0.13, 0.19, 0.09), Vector3(0.11, -0.20, -0.04), fabric)
    _box(right_leg_pivot, "RightCombatBoot", Vector3(0.20, 0.16, 0.34), Vector3(0, -0.54, -0.065), boot)
    _box(right_leg_pivot, "RightBootSole", Vector3(0.205, 0.035, 0.35), Vector3(0, -0.608, -0.065), metal)

func _physics_process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var camera := get_viewport().get_camera_3d()
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    if camera:
        var camera_basis := camera.global_transform.basis
        var camera_right := camera_basis.x
        var camera_forward := -camera_basis.z
        direction = camera_right * input_2d.x + camera_forward * input_2d.y
        direction.y = 0.0
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
    # Animate articulated limbs only while grounded; feet remain aligned with the floor.
    animation_clock += delta
    if avatar:
        var horizontal_speed := Vector2(velocity.x, velocity.z).length()
        var moving := is_on_floor() and horizontal_speed > 0.35
        var gait_speed := clampf(horizontal_speed / move_speed, 0.0, 1.35)
        var swing := sin(animation_clock * 8.5) * 0.48 * gait_speed if moving else 0.0
        if left_leg_pivot:
            left_leg_pivot.rotation.x = swing
        if right_leg_pivot:
            right_leg_pivot.rotation.x = -swing
        if left_arm_pivot:
            left_arm_pivot.rotation.x = -swing * 0.72
        if right_arm_pivot:
            right_arm_pivot.rotation.x = swing * 0.72
        # No vertical bob: the character model stays planted instead of appearing to walk in mid-air.
        avatar.position.y = 0.0
        avatar.rotation.z = 0.0

func set_outfit_color(color: Color) -> void:
    if jacket_material:
        jacket_material.albedo_color = color
