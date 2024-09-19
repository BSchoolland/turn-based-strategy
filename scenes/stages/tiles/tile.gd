extends Node2D

signal selected
# Variable to store the ShaderMaterial
var glow_material : ShaderMaterial

var gridX : int
var gridY : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a new ShaderMaterial
	glow_material = ShaderMaterial.new()
	
	# Load the shader from the .gdshader file
	var shader = load("res://scenes/stages/tiles/glow.gdshader")
	
	# Assign the shader to the ShaderMaterial
	glow_material.shader = shader

# Function to highlight (apply glow effect) and remove it after a delay
func highlight() -> void:
	# Apply the glow material to the $Sprite2D node
	$Area2D/Sprite2D.material = glow_material

func unHighlight() -> void:
	# Remove the glow material (set it to null to remove)
	$Area2D/Sprite2D.material = null

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print('clicked!')
			selected.emit(self)
