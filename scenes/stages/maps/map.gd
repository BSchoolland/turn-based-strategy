extends Node2D

const dimensionX : int = 15
const dimensionY : int = 15
const tileSize : float = 75

var mapSizeX : float = dimensionX * tileSize
var mapSizeY : float = dimensionY * tileSize

var mapArray : Array = []
var selectedUnit : Node2D

var selectableSpaces : Array = []
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
			newTile.gridX = x
			newTile.gridY = y
			# resolution of sprites is 300x300, so the scale should be 
			newTile.scale /= (3 / (tileSize / 100))
			add_child(newTile)
			row.append(newTile)
		mapArray.append(row)

func showValidActions(unit: Node2D) -> Array:
	if (unit.myTurn):
		clearSelections()
		selectedUnit = unit
		selectableSpaces = []
		showValidMoves(unit)
		showValidTargets(unit)
		return selectableSpaces
	else:
		# the unit was clicked but it can't move 
		return []

func showValidMoves(unit) -> void:
	if !unit.moveReady:
		return
	var currentSpace = getSpace(unit.gridX, unit.gridY)
	var moves = unit.speed
	var possibleSpacesArray = getReachableSpaces(currentSpace, moves)
	for tile in possibleSpacesArray:
		if !tile.currentUnit:
			tile.highlight('move')
			selectableSpaces.append(tile)
			tile.selected.connect(moveSelectedUnitToTile)
			tile.action = "move"
			
func showValidTargets(unit) -> void:
	if !unit.attackReady:
		return
	var currentSpace = getSpace(unit.gridX, unit.gridY)
	var range = unit.attackRange
	var possibleSpacesArray = getReachableSpaces(currentSpace, range, true) # ignore move penalty and 
	for tile in possibleSpacesArray:
		if tile.currentUnit and tile.currentUnit.team != unit.team:
			tile.highlight('attack')
			selectableSpaces.append(tile)
			tile.selected.connect(attackUnitOnTile)
			tile.currentUnit.myTurn = false
			tile.action = "attack"

			
	
func moveSelectedUnitToTile(tile, worksOnAI: bool = false) -> void:
	if !selectedUnit.is_ai or worksOnAI:
		selectedUnit.moveTo(tile)
		clearSelections()

func attackUnitOnTile(tile, worksOnAI: bool = false) -> void:
	if !selectedUnit.is_ai or worksOnAI:
		selectedUnit.attack(tile.currentUnit)
		clearSelections()

func clearSelections() -> void:
	for tile in selectableSpaces:
		tile.action = "nothing"
		# disconnect any functions it might have
		if tile.selected.is_connected(moveSelectedUnitToTile):
			tile.selected.disconnect(moveSelectedUnitToTile)
		if tile.selected.is_connected(attackUnitOnTile):
			tile.selected.disconnect(attackUnitOnTile)
		# unHighlight it
		tile.unHighlight()
# finds spaces within reach

func getReachableSpaces(startTile, maxMoves, ignorePenalty = false) -> Array:
	var reachableSpaces = []
	var queue = []
	var visited = []
	
	# Initialize the search from the startTile
	queue.append([startTile, 0])  # (tile, currentMoveCount)
	visited.append(startTile)
	
	# BFS loop
	while queue.size() > 0:
		var current = queue.pop_front()
		var currentTile = current[0]
		var currentMoves = current[1]
		
		# Add the current tile to reachable spaces
		reachableSpaces.append(currentTile)
		
		# If we have reached the maximum allowed moves, skip further expansion
		if currentMoves >= maxMoves:
			continue
		
		# Get neighbors of the current tile (up, down, left, right)
		var neighbors = getNeighbors(currentTile)
		
		for neighbor in neighbors:
			if neighbor in visited:
				continue  # Skip already visited tiles
			
			# Check movement penalty (if any) or ignore it
			var moveCost = 1 if ignorePenalty else getMoveCost(neighbor)
			
			# If adding this tile is within the allowed move limit
			if currentMoves + moveCost <= maxMoves:
				queue.append([neighbor, currentMoves + moveCost])
				visited.append(neighbor)
	# remove the start tile, as it cannot be moved to or targeted
	reachableSpaces.remove_at(0)
	
	return reachableSpaces

# Utility to get neighboring tiles
func getNeighbors(tile) -> Array:
	var neighbors = []
	var pos = tile.position / tileSize  # Convert world position to grid position
	var x = int(pos.x)
	var y = int(pos.y)
	
	# Up
	if y - 1 >= 0:
		neighbors.append(getSpace(x, y - 1))
	# Down
	if y + 1 < dimensionY:
		neighbors.append(getSpace(x, y + 1))
	# Left
	if x - 1 >= 0:
		neighbors.append(getSpace(x - 1, y))
	# Right
	if x + 1 < dimensionX:
		neighbors.append(getSpace(x + 1, y))
	
	return neighbors

# Example function to get the movement cost of a tile (can be modified)
func getMoveCost(tile) -> int:
	# Return the movement cost of this tile (default to 1 if no specific value)
	# This is where you would check tile properties, like terrain or obstacles
	return 1


func getSpace(x, y) -> Node2D:
	return(mapArray[y][x])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
