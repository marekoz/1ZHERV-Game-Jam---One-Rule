extends Node3D

@onready var world = get_tree().get_root().get_child(0)


func _on_area_3d_body_entered(body):
	if body.is_aggro:
		body.stop = true
		body.gong_start()
		
		


func _on_gong_timer_timeout():
	world.set_gong_activated()
	$ReinforcementTimer.start


func _on_reinforcement_timer_timeout():
	world.set_reinforcements()
