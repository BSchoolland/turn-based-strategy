extends Node2D

const dimensionX : int = 15
const dimensionY : int = 15
const tileSize : float = 75

var mapSizeX : float = dimensionX * tileSize
var mapSizeY : float = dimensionY * tileSize

var mapArray : Array = []

const tileScn = preload('res://scenes/stages/tiles/tile.tscn')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# loop through x and y and fill the 2D array with tiles
	for y in range(dimensionY):
		var row = []
		for x in range(dimensionX):
			var newTile = tileScn.instantiate()
			newTile.position.x = (x * tileSize)
			newTile.position.y = (y * tileSize)
			# resolution of sprites is 300x300, so the scale should be 
			newTile.scale /= (3 / (tileSize / 100))
			add_child(newTile)
			row.append(newTile)
		mapArray.append(row)

func getSpace(x, y) -> Node2D:
	return(mapArray[y][x])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
