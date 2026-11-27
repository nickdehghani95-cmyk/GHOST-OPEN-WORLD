extends CanvasLayer

var money: int = 1200
var owned := {"Street Ops": true}
var outfit_data := [
    {"name": "Street Ops", "price": 0, "color": Color(0.12, 0.14, 0.17)},
    {"name": "Desert Scout", "price": 250, "color": Color(0.48, 0.39, 0.25)},
    {"name": "Arctic Watch", "price": 350, "color": Color(0.62, 0.68, 0.72)},
    {"name": "Night Patrol", "price": 500, "color": Color(0.035, 0.045, 0.065)},
    {"name": "Olive Recon", "price": 450, "color": Color(0.20, 0.27, 0.16)}
]

var panel: PanelContainer
var status_label: Label
var money_label: Label
var player: CharacterBody3D

func _ready() -> void:
    player = get_node("../Player")
    _build_ui()

func _build_ui() -> void:
    var open_button := Button.new()
    open_button.text = "لباس‌فروشی"
    open_button.position = Vector2(18, 18)
    open_button.size = Vector2(150, 52)
    open_button.pressed.connect(_toggle_shop)
    add_child(open_button)

    panel = PanelContainer.new()
    panel.position = Vector2(18, 82)
    panel.custom_minimum_size = Vector2(310, 360)
    panel.visible = false
    add_child(panel)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    panel.add_child(column)

    var heading := Label.new()
    heading.text = "فروشگاه لباس اپراتور"
    heading.add_theme_font_size_override("font_size", 22)
    column.add_child(heading)

    money_label = Label.new()
    column.add_child(money_label)

    var hint := Label.new()
    hint.text = "لباس را انتخاب کن؛ بعضی لباس‌ها پولی هستند."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(hint)

    for outfit in outfit_data:
        var button := Button.new()
        button.text = "%s  |  %s" % [outfit.name, "رایگان" if outfit.price == 0 else str(outfit.price) + " سکه"]
        button.custom_minimum_size.y = 46
        button.pressed.connect(_choose_outfit.bind(outfit))
        column.add_child(button)

    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(status_label)

    var close_button := Button.new()
    close_button.text = "بستن"
    close_button.pressed.connect(_toggle_shop)
    column.add_child(close_button)
    _refresh_money()

func _toggle_shop() -> void:
    panel.visible = not panel.visible
    _refresh_money()

func _choose_outfit(outfit: Dictionary) -> void:
    var outfit_name: String = outfit.name
    var price: int = outfit.price
    if not owned.has(outfit_name):
        if money < price:
            status_label.text = "سکه کافی نداری."
            return
        money -= price
        owned[outfit_name] = true
    player.set_outfit_color(outfit.color)
    status_label.text = "لباس «%s» انتخاب شد!" % outfit_name
    _refresh_money()

func _refresh_money() -> void:
    if money_label:
        money_label.text = "موجودی: %s سکه" % money
