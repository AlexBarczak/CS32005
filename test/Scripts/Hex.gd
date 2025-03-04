extends CanvasItem

var hex_directions # array of Hexes

var layout_pointy # Orientation constant for pointy orientation
var layout_flat # Orientation constant for flat orientation

var used_layout : Layout;
var hexes = {};

@export var hex_origin: Vector2
@export var hex_scale: Vector2 

class FractionalHex:
	var q: float
	var r: float
	var s: float

	func _init(_q: float, _r: float, _s: float) -> void:
		q = _q
		r = _r
		s = _s

class Hex:
	var q: int
	var r: int
	var s: int
	
	func _init(_q: int, _r: int, _s: int) -> void:
		q = _q
		r = _r
		s = _s
	
	func equals(b: Hex):
		return self.q == b.q && self.r == b.r && self.s == b.s
	
	func valid() -> bool:
		return (self.q + self.r + self.s) == 0

func hex_round(h: FractionalHex) -> Hex:
	var q: int = int(round(h.q))
	var r: int = int(round(h.r))
	var s: int = int(round(h.s))
	
	var q_diff: float = abs(q - h.q)
	var r_diff: float = abs(r - h.r)
	var s_diff: float = abs(s - h.s)
	
	if (q_diff > r_diff && q_diff > s_diff):
		q = -r - s;
	elif (r_diff > s_diff):
		r = -q - s;
	else:
		s = -q - r
	
	return Hex.new(q, r, s)

func hex_add(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q + b.q, a.r + b.r, a.s + b.s)

func hex_subtract(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q - b.q, a.r - b.r, a.s - b.s)

func hex_multiply(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q * b.q, a.r * b.r, a.s * b.s)

func hex_length(hex: Hex) -> int:
	return int((abs(hex.q) + abs(hex.r) + abs(hex.s)) / 2);

func hex_distance(a: Hex, b: Hex):
	return hex_length(hex_subtract(a, b))

func hex_direction(direction: int) -> Hex:
	return hex_directions[(6 + (direction % 6)) % 6]

func hex_neighbour(hex: Hex, direction: int):
	return hex_add(hex, hex_direction(direction))

func hex_linedraw(a: Hex, b: Hex):
	var N: int = hex_distance(a, b);
	var a_nudge = FractionalHex.new(a.q, a.r, a.s);
	var b_nudge = FractionalHex.new(b.q, b.r, b.s);
	var results = []
	
	var step: float = 1.0/ max(N,1);
	for i in range(N+1):
		results.append(hex_round(hex_lerp(a_nudge, b_nudge, step * i)))
		draw_circle(fractional_hex_to_pixel(used_layout, hex_lerp(a_nudge, b_nudge, step * i)), 4.0, Color(1,0,0))
	
	return results;

# hash 32 bits from each of the q and r variables into the bits of an integer return value
# s needs not be hashed since it is dependent on the other two variables anyways
# breaks if coord value exceeds 2^31 in either direction
func hash_hex(hex: Hex) -> int:
	var rv : int = 0;
	
	rv = rv | (hex.q & 0xFFFFFFFF)
	rv = (rv << 32) | (hex.r & 0xFFFFFFFF)
	
	return rv 

class Orientation extends RefCounted:
	var f0
	var f1
	var f2
	var f3
	
	var b0
	var b1
	var b2
	var b3
	
	var start_angle
	
	func _init(_f0: float, _f1: float, _f2: float, _f3: float,
				_b0: float, _b1: float, _b2: float, _b3: float,
				_start_angle: float):
		self.f0 = _f0
		self.f1 = _f1
		self.f2 = _f2
		self.f3 = _f3
		
		self.b0 = _b0
		self.b1 = _b1
		self.b2 = _b2
		self.b3 = _b3
		
		self.start_angle = _start_angle

func hex_lerp(a: FractionalHex, b: FractionalHex, t: float) -> FractionalHex:
	return FractionalHex.new(lerp(a.q, b.q, t),
							lerp(a.r, b.r, t),
							lerp(a.s, b.s, t))

class Layout:
	var orientation
	var size
	var origin
	
	func _init(_orientation, _size: Vector2, _origin: Vector2) -> void:
		self.orientation = _orientation
		self.size = _size
		self.origin = _origin

func hex_to_pixel(layout: Layout, h: Hex) -> Vector2:
	var M = layout.orientation
	var x = (M.f0 * h.q + M.f1 * h.r) * layout.size.x
	var y = (M.f2 * h.q + M.f3 * h.r) * layout.size.y
	return Vector2(x + layout.origin.x, y + layout.origin.y)

func fractional_hex_to_pixel(layout: Layout, h: FractionalHex) -> Vector2:
	var M = layout.orientation
	var x = (M.f0 * h.q + M.f1 * h.r) * layout.size.x
	var y = (M.f2 * h.q + M.f3 * h.r) * layout.size.y
	return Vector2(x + layout.origin.x, y + layout.origin.y)

func pixel_to_hex(layout: Layout, p : Vector2):
	var M = layout.orientation
	var pt = Vector2((p.x - layout.origin.x) / layout.size.x, 
					(p.y - layout.origin.y) / layout.size.y);
	var q = M.b0 * pt.x + M.b1 * pt.y;
	var r = M.b2 * pt.x + M.b3 * pt.y;
	return FractionalHex.new(q, r, -q - r);

func hex_corner_offset(layout: Layout, corner: int):
	var size = layout.size
	var angle = 2.0 * PI * (layout.orientation.start_angle + corner) / 6
	
	return Vector2(size.x * cos(angle), size.y * sin(angle))

func polygon_corners(layout: Layout, h: Hex):
	var corners = [];
	var center = hex_to_pixel(layout, h)
	for i in range(0, 7):
		var offset = hex_corner_offset(layout, i)
		corners.append(Vector2(center.x + offset.x,
								center.y + offset.y))
	return corners;

func generate_hexagonal_map(size: int):
	size = max(size, 0);
	
	var map = {}
	
	for q in range(-size, size+1):
		var r1: int = max(-size, -q - size);
		var r2: int = min( size, -q + size);
		for r in range(r1, r2+1):
			var hex = Hex.new(q, r, -q-r)
			map[hash_hex(hex)] = hex
	return map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hex_directions = [Hex.new(1, 0, -1), Hex.new(1, -1, 0), Hex.new(0, -1, 1),Hex.new(-1, 0, 1), Hex.new(-1, 1, 0), Hex.new(0, 1, -1)]
	
	layout_pointy = Orientation.new(sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
										sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
										0.5)
	layout_flat = Orientation.new(3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
										2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
										0.0)
	
	used_layout = Layout.new(layout_flat, hex_scale, hex_origin);
	
	
	hexes = generate_hexagonal_map(8)

var selectedHexes = [null, null]
var highlightedhex : Hex

var overUI = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var pos : Vector2 = get_global_mouse_position()
	
	var approximate :FractionalHex = pixel_to_hex(used_layout, pos)	
	var exact: Hex = hex_round(approximate)
	
	var hashedValue = hash_hex(hex_round(pixel_to_hex(used_layout, pos)))
	if hexes.has(hashedValue):
		highlightedhex = hexes[hashedValue]
	else:
		highlightedhex = null
	
	if (Input.is_action_just_pressed("mouse_1") && !overUI):
		hashedValue = hash_hex(hex_round(pixel_to_hex(used_layout, pos)))
		if hexes.has(hashedValue):
			# if selected 1 is null, set as selected 1
			if (selectedHexes[0] == null):
				selectedHexes[0] = hashedValue
			# elif equal to selected 1, deselect both
			elif (selectedHexes[0] == hashedValue):
				selectedHexes[0] = null
				selectedHexes[1] = null
			# elif selected 2 is null, set as selected 2
			elif (selectedHexes[1] == null):
				selectedHexes[1] = hashedValue
			# elif equal to selected 2, deselect selected 2
			elif (selectedHexes[1] == hashedValue):
				selectedHexes[1] = null
	
	queue_redraw()

func _draw():
	var corners
	for hex in hexes.values():
		corners = PackedVector2Array(polygon_corners(used_layout, hex))
		draw_polyline(corners, Color(1,1,1))
	
	if (selectedHexes.size() == 1):
		pass
	elif (selectedHexes.size() == 2):
		pass
	
	if (highlightedhex != null):
		corners = PackedVector2Array(polygon_corners(used_layout, highlightedhex))
		draw_polyline(corners, Color(1,0,0))
	
	if (selectedHexes[0] != null):
		corners = PackedVector2Array(polygon_corners(used_layout, hexes[selectedHexes[0]]))
		draw_polyline(corners, Color(1,1,0))
		
		if (selectedHexes[1] != null):
			corners = PackedVector2Array(polygon_corners(used_layout, hexes[selectedHexes[1]]))
			draw_polyline(corners, Color(0,1,1))
			
			draw_line(hex_to_pixel(used_layout, hexes[selectedHexes[0]]), hex_to_pixel(used_layout, hexes[selectedHexes[1]]), Color(1,1,1))
			
			var lineOfHexes = hex_linedraw(hexes[selectedHexes[0]], hexes[selectedHexes[1]])
			
			for hex in lineOfHexes:
				draw_circle(hex_to_pixel(used_layout, hex), 4.0, Color(1,1,1))

func _mouse_enter_ui():
	overUI = true
	pass # Replace with function body.

func _mouse_exit_ui():
	overUI = false
	pass # Replace with function body.
