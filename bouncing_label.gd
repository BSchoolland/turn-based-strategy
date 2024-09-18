extends Node2D

var velocity = Vector2(150, 150)
var phrases = ["Lasers!", "Lava!", "Dragons?", "Danger!", "Story!", "Upgrades!"]

func _ready():
	# Randomize starting text
	$Label.text = phrases[randi() % phrases.size()]
	# Random initial direction
	velocity.x *= -1 if randf_range(-1, 1) < 0 else 1
	velocity.y *= -1 if randf_range(-1, 1) < 0 else 1
	# Ensure the random functions are truly random
	randomize()

func _process(delta):
	# Move the label
	position += velocity * delta


	# Bounce off screen edges
	if position.x < 0 or position.x + 200 > get_viewport_rect().size.x:
		velocity.x *= -1
		# Change text on bounce
		$Label.text = phrases[randi() % phrases.size()]

	if position.y < 0 or position.y + 50 > get_viewport_rect().size.y:
		velocity.y *= -1
		# Change text on bounce
		$Label.text = phrases[randi() % phrases.size()]
