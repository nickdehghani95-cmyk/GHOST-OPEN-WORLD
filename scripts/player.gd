extends CharacterBody3D

@export var move_speed: float = 4.5
@export var acceleration: float = 14.0
@export var gravity: float = 18.0

var outfit_material: StandardMaterial3D

func _ready() -> void:
    _setup_input()
    outfit_material = StandardMaterial3D.new()
    outfit_material.albedo_color = Color(0.12, 0.14, 0.17)
    var body := MeshInstance3D.new()
    body.name = "OperatorBody"
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.38
    mesh.height = 1.8
    body.mesh = mesh
    body.position.y = 0.9
    body.material_override = outfit_material
    add_child(body)

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
