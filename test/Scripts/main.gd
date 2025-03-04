extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene = preload("res://Scenes/Menu.tscn").instantiate()
	add_child(scene)

func _open_menu() -> void:
	get_child(0).queue_free()
	var scene = preload("res://Scenes/Menu.tscn").instantiate()
	add_child(scene)

func _on_b_new_game_pressed() -> void:
	get_child(0).queue_free()
	var scene = preload("res://Scenes/Test.tscn").instantiate()
	add_child(scene)

func _on_b_load_game_pressed() -> void:
	get_child(0).queue_free()
	var scene = preload("res://Scenes/404.tscn").instantiate()
	add_child(scene)

func _on_b_settings_pressed() -> void:
	get_child(0).queue_free()
	var scene = preload("res://Scenes/404.tscn").instantiate()
	add_child(scene)

func _on_b_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
