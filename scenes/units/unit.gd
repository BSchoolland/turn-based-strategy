extends Node2D

signal selected

var gridX : int
var gridY : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func moveUnitTo(tile) -> void:
	gridX = tile.gridX
	gridY = tile.gridY
	position = tile.position

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print('clicked!')
			selected.emit(self)
