extends CharacterBody3D


const SPEED = 1
var direction: Vector3 = Vector3(0,0,0)
var can_move = true
@onready var world = get_tree().get_root().get_child(0)
var player
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var blood = preload("res://blood_particle_oneshot.tscn")

func _ready():
	$AnimationPlayer.play("flying")

func _physics_process(delta):
	if can_move:
		var collision = move_and_collide(direction * SPEED)
		if collision:
			var col = collision.get_collider()
			can_move = false
			print(collision)
			$AnimationPlayer.play("attached")
			if col.is_in_group("Enemy"):
				var blood_instance = blood.instantiate()
				world.add_child(blood_instance)
				blood_instance.global_position = self.global_position
				self.reparent(col.model)
				col.hit()
			else:
				world.set_player_missed()



func _on_area_3d_body_entered(body):
	if not can_move:
		player = world.player
		player.add_knife(1)
		self.queue_free()
