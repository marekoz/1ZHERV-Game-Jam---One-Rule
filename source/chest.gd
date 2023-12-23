extends Node3D

@onready var world = get_tree().get_root().get_child(0)
var opened = false

func _on_area_3d_body_entered(body):
	if not self.opened:
		if world.current_objective == "steal item":
			world.objective_completed = true
		self.opened = true
		$AnimationPlayer.play("Open")
		$GPUParticles3D.emitting = true
