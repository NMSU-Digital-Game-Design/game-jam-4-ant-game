extends Camera2D

# Exported variables for easy tweaking in the inspector
@export var scroll_speed: float = 1000.0  # Pixels per second for edge scrolling
@export var drag_speed: float = 1.0      # Multiplier for middle mouse drag speed
@export var zoom_speed: float = 0.1      # How much to zoom per wheel tick
@export var zoom_min: float = 0.75        # Minimum zoom level (e.g., zoomed out)
@export var zoom_max: float = 1.3        # Maximum zoom level (e.g., zoomed in)
@export var position_limits: Rect2 = Rect2(800, 700, 2100, 200)  # Camera position bounds (x, y, width, height)
@export var starting_position: Vector2 = Vector2(800, 800)  # Initial camera position

var is_dragging: bool = false
var drag_start_pos: Vector2
var camera_start_pos: Vector2

func _ready() -> void:
	# Set starting position
	position = starting_position
	# Ensure zoom starts at 1.0 (default)
	zoom = Vector2(0.8, 0.8)

func _process(delta: float) -> void:
	# Edge scrolling ONLY if not dragging
	if not is_dragging:
		var viewport_size: Vector2 = get_viewport_rect().size
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var move_dir: Vector2 = Vector2.ZERO
		
		# Check edges (adjust edge_margin as needed, e.g., 10 pixels from edge)
		var edge_margin: float = 10.0
		if mouse_pos.x < edge_margin:
			move_dir.x = -1
		elif mouse_pos.x > viewport_size.x - edge_margin:
			move_dir.x = 1
		if mouse_pos.y < edge_margin:
			move_dir.y = -1
		elif mouse_pos.y > viewport_size.y - edge_margin:
			move_dir.y = 1
		
		if move_dir != Vector2.ZERO:
			position += move_dir.normalized() * scroll_speed * delta / zoom.x  # Adjust speed based on zoom
	
	# Clamp position after any movement (always runs)
	clamp_position()

func _input(event: InputEvent) -> void:
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom -= Vector2(zoom_speed, zoom_speed)
			zoom = zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom += Vector2(zoom_speed, zoom_speed)
			zoom = zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
		
		# Middle mouse button drag
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
				camera_start_pos = position
			else:
				is_dragging = false
	
	# Handle drag motion
	elif event is InputEventMouseMotion and is_dragging:
		var drag_delta: Vector2 = (drag_start_pos - event.position) / zoom.x * drag_speed
		position = camera_start_pos + drag_delta
		clamp_position()

func clamp_position() -> void:
	# Clamp camera position within limits
	position.x = clamp(position.x, position_limits.position.x, position_limits.position.x + position_limits.size.x)
	position.y = clamp(position.y, position_limits.position.y, position_limits.position.y + position_limits.size.y)
