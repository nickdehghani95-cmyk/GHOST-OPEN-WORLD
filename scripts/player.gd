extends CharacterBody3D

@export var move_speed: float = 4.5
@export var acceleration: float = 14.0
@export var gravity: float = 18.0

@onready var camera_pivot: Node3D = $CameraPivot

func _physics_process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    direction = camera_pivot.global_transform.basis * direction
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
