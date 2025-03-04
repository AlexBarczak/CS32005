extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var zoomedIn: bool = false
var zoomKeyState = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_key_pressed(KEY_A)):
		position -= Vector2(10, 0) 
	if (Input.is_key_pressed(KEY_D)):
		position += Vector2(10, 0)
		
	if (Input.is_key_pressed(KEY_S)):
		position += Vector2(0, 10) 
	if (Input.is_key_pressed(KEY_W)):
		position -= Vector2(0, 10)
	
	if (Input.is_action_just_pressed("zoom_in")):
		if (zoomedIn):
			zoom *= 2
		else:
			zoom *= 0.5
		zoomedIn = !zoomedIn
