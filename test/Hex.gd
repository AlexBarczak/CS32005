extends CanvasItem

var hex_directions # array of Hexes

var layout_pointy # Orientation constant for pointy orientation
var layout_flat # Orientation constant for flat orientation

class FractionalHex:
	var q: float
	var r: float
	var s: float
	
	func _init(_q: float, _r: float, _s: float) -> void:
		q = _q
		r = _r
		s = _s

class Hex extends RefCounted:
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

var used_layout : Layout;
var hexes = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hex_directions = [Hex.new(1, 0, -1), Hex.new(1, -1, 0), Hex.new(0, -1, 1),Hex.new(-1, 0, 1), Hex.new(-1, 1, 0), Hex.new(0, 1, -1)]
	
	layout_pointy = Orientation.new(sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
										sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
										0.5)
	layout_flat = Orientation.new(3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
										2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
										0.0)
	
	used_layout = Layout.new(layout_pointy, Vector2(30,30), Vector2(300, 300));
	
	
	for q in range(-5, 5):
		for r in range(-5, 5):
			hexes.append(Hex.new(q, r, -q - r))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw():
	for hex in hexes:
		var corners = PackedVector2Array(polygon_corners(used_layout, hex))
		draw_polyline(corners, Color(1,1,1))
