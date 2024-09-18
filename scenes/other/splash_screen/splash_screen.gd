extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func do_splash():
	#await get_tree().create_timer(1).timeout
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Icon, "position", Vector2(-4950, -2869), 2)
	await get_tree().create_timer(2).timeout
	hide()
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
