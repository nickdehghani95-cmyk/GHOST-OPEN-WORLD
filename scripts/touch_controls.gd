extends Control

# Landscape mobile HUD: left virtual joystick, right jump button.
var joystick_id: int = -1
var jump_id: int = -1
var joystick_vector := Vector2.ZERO
var joystick_center := Vector2.ZERO
var jump_center := Vector2.ZERO
var joystick_radius := 82.0
var jump_radius := 58.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _ensure_action("move_left")
    _ensure_action("move_right")
    _ensure_action("move_forward")
    _ensure_action("move_back")
    _ensure_action("jump")
    _layout_controls()
    get_viewport().size_changed.connect(_layout_controls)
    queue_redraw()

func _ensure_action(action: String) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)

func _layout_controls() -> void:
    var size := get_viewport_rect().size
    joystick_center = Vector2(joystick_radius + 42.0, size.y - joystick_radius - 38.0)
    jump_center = Vector2(size.x - jump_radius - 48.0, size.y - jump_radius - 42.0)
    queue_redraw()

func _draw() -> void:
    draw_circle(joystick_center, joystick_radius, Color(0.05, 0.07, 0.09, 0.42))
    draw_arc(joystick_center, joystick_radius, 0.0, TAU, 64, Color(0.85, 0.88, 0.92, 0.72), 4.0)
    draw_circle(joystick_center + joystick_vector * joystick_radius, 34.0, Color(0.75, 0.79, 0.84, 0.72))
    draw_circle(jump_center, jump_radius, Color(0.12, 0.16, 0.20, 0.62))
    draw_arc(jump_center, jump_radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.85), 4.0)
    var font := ThemeDB.fallback_font
    if font:
        draw_string(font, jump_center + Vector2(-22, 9), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _screen_touch(event)
    elif event is InputEventScreenDrag:
        if event.index == joystick_id:
            _update_joystick(event.position)
        elif event.index == jump_id:
            pass
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _mouse_press(event.position)
        else:
            _release_mouse()
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        if joystick_id == -2:
            _update_joystick(event.position)

func _screen_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if event.position.distance_to(joystick_center) <= joystick_radius * 1.45 and joystick_id == -1:
            joystick_id = event.index
            _update_joystick(event.position)
        elif event.position.distance_to(jump_center) <= jump_radius * 1.35 and jump_id == -1:
            jump_id = event.index
            Input.action_press("jump")
    else:
        if event.index == joystick_id:
            joystick_id = -1
            joystick_vector = Vector2.ZERO
            _apply_movement()
            queue_redraw()
        if event.index == jump_id:
            jump_id = -1
            Input.action_release("jump")

func _mouse_press(pos: Vector2) -> void:
    if pos.distance_to(joystick_center) <= joystick_radius * 1.45:
        joystick_id = -2
        _update_joystick(pos)
    elif pos.distance_to(jump_center) <= jump_radius * 1.35:
        jump_id = -2
        Input.action_press("jump")

func _release_mouse() -> void:
    if joystick_id == -2:
        joystick_id = -1
        joystick_vector = Vector2.ZERO
        _apply_movement()
    if jump_id == -2:
        jump_id = -1
        Input.action_release("jump")
    queue_redraw()

func _update_joystick(pos: Vector2) -> void:
    var offset := pos - joystick_center
    if offset.length() > joystick_radius:
        offset = offset.normalized() * joystick_radius
    joystick_vector = offset / joystick_radius
    _apply_movement()
    queue_redraw()

func _apply_movement() -> void:
    Input.action_release("move_left")
    Input.action_release("move_right")
    Input.action_release("move_forward")
    Input.action_release("move_back")
    if joystick_vector.x < -0.18:
        Input.action_press("move_left", -joystick_vector.x)
    elif joystick_vector.x > 0.18:
        Input.action_press("move_right", joystick_vector.x)
    if joystick_vector.y < -0.18:
        Input.action_press("move_forward", -joystick_vector.y)
    elif joystick_vector.y > 0.18:
        Input.action_press("move_back", joystick_vector.y)
