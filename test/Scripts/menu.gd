extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ControlNode = get_tree().root.get_child(0)
	assert(ControlNode != self)
	get_node("VBoxContainer/b_NewGame").connect("pressed", ControlNode._on_b_new_game_pressed, 0)
	get_node("VBoxContainer/b_LoadGame").connect("pressed", ControlNode._on_b_load_game_pressed, 0)
	get_node("VBoxContainer/b_Settings").connect("pressed", ControlNode._on_b_settings_pressed, 0)
	get_node("VBoxContainer/b_Exit").connect("pressed", ControlNode._on_b_exit_pressed, 0)
