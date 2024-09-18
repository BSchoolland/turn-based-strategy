extends Camera2D

@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var drag_active: bool = false

# Called every frame
func _process(delta: float) -> void:
	# Handle movement and zooming
	handle_camera_movement(delta)
	handle_camera_zoom(delta)

# Called when there's input
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			drag_active = event.pressed  # Set drag_active based on button press
	handle_drag_camera(event)

# Function to handle keyboard camera movement (WASD or arrow keys)
func handle_camera_movement(delta: float) -> void:
	# Disable movement while dragging the camera
	if drag_active:
		return  # Stop movement when dragging

	var movement = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		movement.y -= 1
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1

	if movement != Vector2.ZERO:
		movement = movement.normalized() * move_speed * delta * (1 / zoom.x)
		global_position += movement

# Function to handle zooming in and out with the mouse wheel
func handle_camera_zoom(delta: float) -> void:
	# Disable zooming while dragging the camera
	if drag_active:
		return  # Stop zooming when dragging

	var zoom_change = 0.0

	if Input.is_action_just_pressed("zoom_in"):
		zoom_change = zoom_speed
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_change = -zoom_speed

	if zoom_change != 0.0:
		# Get the mouse position in world coordinates before zooming
		var mouse_pos = get_global_mouse_position()

		# Apply zoom change
		var new_zoom = zoom + Vector2(zoom_change, zoom_change)
		new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
		new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
		zoom = new_zoom

		# Get the mouse position in world coordinates after zooming
		var mouse_pos_new = get_global_mouse_position()

		# Calculate the difference and adjust the camera position
		var zoom_offset = mouse_pos - mouse_pos_new
		global_position += zoom_offset

# Function to handle click-and-drag camera movement
func handle_drag_camera(event: InputEvent) -> void:
	if drag_active and event is InputEventMouseMotion:
		position -= event.relative / zoom
