extends Node2D

signal selected
# Variable to store the ShaderMaterial
var move_glow_material : ShaderMaterial
var attack_glow_material : ShaderMaterial

var gridX : int
var gridY : int

var currentUnit : Node2D
var action: String = "nothing"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a new ShaderMaterial
	move_glow_material = ShaderMaterial.new()
	attack_glow_material = ShaderMaterial.new()
	
	# Load the shader from the .gdshader file
	var move_shader = load("res://scenes/stages/tiles/glow.gdshader")
	var attack_shader = load("res://scenes/stages/tiles/attackGlow.gdshader")

	
	# Assign the shader to the ShaderMaterial
	move_glow_material.shader = move_shader
	attack_glow_material.shader = attack_shader

# Function to highlight (apply glow effect) and remove it after a delay
func highlight(type="move") -> void:
	if type =="move":
		# Apply the glow material to the $Sprite2D node
		$Area2D/Sprite2D.material = move_glow_material
	elif type == "attack":
		$Area2D/Sprite2D.material = attack_glow_material


func unHighlight() -> void:
	# Remove the glow material (set it to null to remove)
	$Area2D/Sprite2D.material = null

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
