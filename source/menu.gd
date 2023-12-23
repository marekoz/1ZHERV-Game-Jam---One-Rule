extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_button_level_1_pressed():
	get_tree().change_scene_to_file("res://levels/level_1.tscn")


func _on_button_pressed():
	get_tree().quit()


func _on_button_level_2_pressed():
	get_tree().change_scene_to_file("res://levels/level_2.tscn")


func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://levels/level_3.tscn")
