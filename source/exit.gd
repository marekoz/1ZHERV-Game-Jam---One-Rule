extends Node3D

@onready var world = get_tree().get_root().get_child(0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.visible = world.objective_completed


func _on_area_3d_body_entered(body):
	if world.objective_completed:
		world.complete_level()
