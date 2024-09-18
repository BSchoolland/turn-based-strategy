extends CanvasLayer

signal play
signal settings
signal help

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_help_pressed() -> void:
	help.emit()

func _on_settings_pressed() -> void:
	settings.emit()

func _on_play_pressed() -> void:
	play.emit()
