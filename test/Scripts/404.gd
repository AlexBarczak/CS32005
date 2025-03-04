extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ControlNode = get_tree().root.get_child(0)
	assert(ControlNode != self)
	get_node("VBoxContainer/Button").connect("pressed", ControlNode._open_menu, 0)
