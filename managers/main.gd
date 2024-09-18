extends Node2D

var isGameRunning : bool = false
var isGameOver : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# show and hide scenes initially
	$splash_screen.show()
	$main_menu.hide()
	$help_menu.hide()
	# set variable inital values
	isGameRunning = false
	isGameOver = false
	
	await $splash_screen.do_splash()
	print("done")
	$main_menu.show()

func _on_main_menu_play() -> void:
	gameplay_start()
	
func gameplay_start() -> void:
		# set variables and 
	isGameRunning = true
	isGameOver = false
	$main_menu.hide()
	fake_gameplay_loop()
	
func gameplay_stop() -> void:
	isGameRunning = false
	if isGameOver:
		pass
	$main_menu.show()
	
	
func fake_gameplay_loop():
	await get_tree().create_timer(15).timeout
	isGameOver = true
	gameplay_stop()


func _on_main_menu_help() -> void:
	$help_menu.show()


func _on_main_menu_settings() -> void:
	$"settings-scene".show()
