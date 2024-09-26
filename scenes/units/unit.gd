extends Node2D

signal selected

var gridX : int
var gridY : int
var currentTile : Node2D

var hurt_material : ShaderMaterial
var myTurn : bool = false
var moveReady : bool = false
var attackReady : bool = false

# stats
var speed : int = 3
var maxHealth : int = 10
var currentHealth : int = 10
var attackRange : int = 5
var attackDamage : int = 3

# smarts for bots
var is_ai: bool = false
var intelligence = 3

# team
var team : int
var dead : int

# reference to the $Map
var map: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurt_material = ShaderMaterial.new()
		# Load the shader from the .gdshader file
	var damageShader = load("res://scenes/stages/tiles/hurt.gdshader")
	
	# Assign the shader to the ShaderMaterial
	hurt_material.shader = damageShader
	dead = false
	endTurn()

# Called every frame. "delta" is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func upkeep() -> void:
	if dead:
		# dead units don't get to move
		return
	myTurn = true
	moveReady = true
	attackReady = true
	if (is_ai):
		if intelligence == 1: # very dumb, just do a random action
			await bot_intelegence_1()
			await get_tree().create_timer(0.33).timeout

			await bot_intelegence_1()


func bot_intelegence_1():
	var possibleActions = map.showValidActions(self)
	await get_tree().create_timer(0.33).timeout

	# Separate the actions into two categories: 'move' and 'attack'
	var move_actions = []
	var attack_actions = []

	for action in possibleActions:
		if action.action == "move":
			move_actions.append(action)
		elif action.action == "attack":
			attack_actions.append(action)

	# Initialize the random number generator
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# Decide randomly if the unit will move or attack (50/50 chance)
	var action_type = rng.randi_range(0, 1) # 0 = move, 1 = attack

	var selected_action = null

	# Select a random action from the chosen category, if there are valid actions
	if action_type == 0 and move_actions.size() > 0:
		selected_action = move_actions[rng.randi_range(0, move_actions.size() - 1)]
	elif action_type == 1 and attack_actions.size() > 0:
		selected_action = attack_actions[rng.randi_range(0, attack_actions.size() - 1)]

	# If no valid action was found in the selected category, try the other category
	if selected_action == null:
		if action_type == 0 and attack_actions.size() > 0:
			selected_action = attack_actions[rng.randi_range(0, attack_actions.size() - 1)]
		elif action_type == 1 and move_actions.size() > 0:
			selected_action = move_actions[rng.randi_range(0, move_actions.size() - 1)]
	
	# Perform the action
	if selected_action != null:
		if selected_action.action == "move":
			map.moveSelectedUnitToTile(selected_action, true)
		elif selected_action.action == "attack":
			map.attackUnitOnTile(selected_action, true)
	else:
		print("Waiting because no action found")
			
	
func endTurn() -> void:
	myTurn = false
	moveReady = false
	attackReady = false
	
func takeDamage(amount, damage_type="physical"):
	# Update health
	currentHealth -= amount
	$Area2D/Sprite2D.material = hurt_material

	# Define minimum and maximum shake intensities
	var min_shake = 2  # Minimum shake intensity (in pixels)
	var max_shake = 10  # Maximum shake intensity (in pixels)
	
	# Calculate the ratio of damage to max health
	var damage_ratio = clamp(amount / maxHealth, 0, 1)  # Clamped between 0 and 1

	# The power can be adjusted to make the scaling stronger or weaker
	var shake_intensity = lerp(min_shake, max_shake, pow(damage_ratio, 2))

	# Apply shake using a Tween
	var tween = create_tween()
	var original_position = $Area2D.position

	# Shake the sprite by moving it randomly within the calculated shake range
	for i in range(4):
		tween.tween_property($Area2D, "position", original_position + Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity)), 0.05)
		tween.tween_property($Area2D, "position", original_position, 0.05)
	await tween.finished

	# Reset the material after the hurt effect
	$Area2D/Sprite2D.material = null

	# Handle death
	if currentHealth <= 0:
		currentTile.currentUnit = null
		print("Unit was killed")
		$Area2D/Sprite2D.material = hurt_material
		
		# Create a new Tween to handle the death rotation
		var death_tween = create_tween()
		death_tween.tween_property($Area2D, "rotation_degrees", 90, 0.75)

		# Call a method when the tween finishes
		death_tween.connect("finished", Callable(self, "die"))

# Callback to remove the unit after the tween finishes
func die():
	await get_tree().create_timer(0.2).timeout
	# hide the unit, and prevent it from ever readying up.
	$Area2D.hide()
	position.x = 99999
	position.y = 99999
	dead = true
	endTurn() # make sure no actions can be taken anymore
	
func moveTo(tile) -> void:
	if !moveReady:
		print("LOGIC WARNING: move should not have been possible")
	moveReady = false
	if tile.currentUnit != null:
		print("LOGIC WARNING: space is already occupied!")
		return
	# update position
	gridX = tile.gridX
	gridY = tile.gridY
	position = tile.position
	# remove self from old tile
	currentTile.currentUnit = null
	# create references to tell which unit is on which tile
	currentTile = tile
	tile.currentUnit = self

func attack(targetUnit: Node2D) -> void:
	if !attackReady:
		print("LOGIC WARNING: attack should not have been possible")
	attackReady = false
	# Create a new red projectile
	var projectile = Node2D.new()
	var projectile_sprite = Sprite2D.new()
	projectile_sprite.texture = preload("res://assets/placeholder/fire.webp")  # Load the red texture
	projectile.add_child(projectile_sprite)
	projectile_sprite.scale *= 0.05

	# Set projectile's initial position to the attacker's position
	projectile.global_position = global_position  # This refers to the attacking unit's position

	# Add the projectile to the scene
	get_parent().add_child(projectile)

	# Create a tween to move the projectile to the target unit's position
	var tween = create_tween()
	tween.tween_property(projectile, "global_position", targetUnit.global_position, 0.4) 

	# Bind arguments (projectile and targetUnit) and connect the signal
	await tween.finished
	_on_projectile_hit(projectile, targetUnit)

# Callback for when the projectile reaches the target
func _on_projectile_hit(projectile: Node2D, targetUnit: Node2D):
	# Destroy the projectile
	projectile.queue_free()
	
	# Deal damage to the target unit
	targetUnit.takeDamage(attackDamage)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (is_ai):
		# ai cannot be manually controlled
		return
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
