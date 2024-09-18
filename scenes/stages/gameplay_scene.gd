extends Node2D


const unitScn = preload('res://scenes/units/unit.tscn')
var unitArray : Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unitArray.append(placeUnit(5,5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func placeUnit(x, y) -> Node2D:
	var newUnit = unitScn.instantiate()
	var tile = $Map.getSpace(x, y)
	newUnit.position = tile.position
	add_child(newUnit)
	return newUnit
