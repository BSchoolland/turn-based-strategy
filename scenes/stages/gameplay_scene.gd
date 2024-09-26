extends Node2D


const unitScn = preload('res://scenes/units/unit.tscn')
var unitArray : Array = []

# variables to keep track of turns and who's turn it is
var round : int
var turn : int
const startingTeams = 2
var numTeams = startingTeams

class Player:
	var name: String
	var is_ai: bool
	
	# Constructor with default values
	func _init(input_name: String = "Bot", ai: bool = true):
		name = input_name
		is_ai = ai


class Team:
	var num: int
	var units: Array
	var leader: Player

	# Constructor with leader and team number
	func _init(val: int, leader: Player):
		num = val
		self.leader = leader
		units = []  # Initialize an empty array for units


var teams: Array = []  # Initialize the teams array

# Called when the node enters the scene tree for the first time.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	teams = []
	
	# Create and add the first player (human player)
	var player1 = Player.new("Player1", false)
	create_team(0, player1, Vector2(6, 12))
	
	# Create and add the second player (AI/bot)
	var bot = Player.new("Bot", true)
	create_team(1, bot, Vector2(6, 6))
	
	# Initialize round and turn
	var round = 0
	var turn = 0
	
# Function to create a team, add leader, place units, and connect signals
func create_team(team_num: int, leader: Player, unit_position: Vector2) -> void:
	var new_team = Team.new(team_num, leader)
	teams.append(new_team)
	# Place a unit for the team
	var new_unit = place_unit(unit_position.x, unit_position.y)
	if leader.is_ai:
		new_unit.is_ai = true
		new_unit.intelligence = 1
	new_unit.selected.connect(on_unit_clicked)
	new_unit.team = team_num
	
	# Add unit to the team
	teams[team_num].units.append(new_unit)

func on_unit_clicked(unit) -> void:
	if !unit.myTurn:
		return
	print(unit.gridX, " ", unit.gridY)
	$Map.showValidActions(unit)

# Called every frame. 'delta' is the elapsed time since the previous frame. 
func _process(delta: float) -> void:
	pass

func place_unit(x, y) -> Node2D:
	var newUnit = unitScn.instantiate()
	var tile = $Map.getSpace(x, y)
	newUnit.position = tile.position
	newUnit.gridX = x
	newUnit.gridY = y
	newUnit.currentTile = tile
	newUnit.map = $Map
	tile.currentUnit = newUnit
	add_child(newUnit)
	unitArray.append(newUnit)
	return newUnit


func _on_button_pressed() -> void:
	$Map.clearSelections()
	for unit in unitArray:
		if unit.team == turn:
			unit.endTurn()
	turn += 1
	if turn >= numTeams:
		turn = 0
		round += 1
	for unit in unitArray:
		if unit.team == turn:
			await unit.upkeep()
	if teams[turn].leader.is_ai:
		_on_button_pressed()
