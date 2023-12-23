extends CharacterBody3D


@export var max_health = 1
@export var is_target = false
var health = 1

@export var detection_time = 2

@onready var world = get_tree().get_root().get_child(0)
@onready var player
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D


var is_aggro = false
var is_dead = false
var player_in_vision_area
var aggro_percent = 0
@onready var model = $samurai
var gong_pos
const SPEED = 10.0
var go_for_gong = false
var stop = false
var next_path_position

func _ready():
	player = world.get_node("Player")
	next_path_position = player.global_position
	

func _physics_process(delta):
	if is_dead:
		$Label3D.visible = false
		$Label3D2.visible = false
	elif is_aggro:
		$Label3D.visible = false
		$Label3D2.visible = true
	elif aggro_percent == 0:
		$Label3D.visible = false
		$Label3D2.visible = false
	elif aggro_percent > 0:
		$Label3D.visible = true
		$Label3D2.visible = false
	
	if player:
		$RayCast3D.look_at(player.global_position)
		
	if is_aggro:
		if player in $GrabArea.get_overlapping_areas():
			world.fail_level()
			

		if stop:
			$AnimationPlayer.play("RESET")
			return
		if go_for_gong and not world.gong_activated:
			nav_agent.target_position = gong_pos
		else:
			nav_agent.target_position = player.global_position

		if nav_agent.is_target_reachable():
			next_path_position = nav_agent.get_next_path_position()
	
		if not nav_agent.is_target_reachable() and (self.global_position - nav_agent.get_next_path_position()).length() < 0.1:
			$AnimationPlayer.play("RESET")
			return
			
		var direction = nav_agent.get_next_path_position() - self.global_position
		direction = direction.normalized()
		
		velocity = direction * SPEED
		self.look_at(nav_agent.get_next_path_position())
		self.rotation.x = 0
		if not is_dead:
			$AnimationPlayer.play("run")
		move_and_slide()



func _on_area_3d_body_entered(body):
	player = body
	player_in_vision_area = true
	print("huh")


func _on_area_3d_body_exited(body):
	player_in_vision_area = false
	print("left")

func _on_aggro_timer_timeout():
	if is_aggro or is_dead:
		return
	if player_in_vision_area and player == $RayCast3D.get_collider():
		aggro_percent += 1
	else:
		aggro_percent -= 1
	if aggro_percent > 19:
		gong_pos = world.gong.global_position
		is_aggro = true
		$ChaseTimer.start(randf_range(0, 20))
		$AudioLegs.play()
		$AudioHuh.play()
	aggro_percent = clamp(aggro_percent, 0, 20)
	
func hit():
	for enemy in $ScreamArea.get_overlapping_bodies():
		if not enemy.is_dead:
			enemy.is_aggro = true
			enemy.chase_start()
	print("au")
	health -= 1
	if health < 1:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	is_aggro = false
	self.collision_layer = 0
	world.target_killed()
	$AnimationPlayer.play("die")
	#$AudioLegs.playing = false
	$AudioDie.play()
	$AudioHuh.stop()
	$AudioLegs.stop()
	print("dead")
	

func gong_start():
	$GongTimer.start()
	
func chase_start():
	if not is_dead:
		gong_pos = world.gong.global_position
		$AudioHuh.play()
		$AudioLegs.play()
		$ChaseTimer.start()
	
func _on_grab_area_body_entered(body):
	if not is_dead:
		world.fail_level()


func _on_chase_timer_timeout():
	go_for_gong = true


func _on_gong_timer_timeout():
	if not self.is_dead and not world.gong_activated:
		print()
		$AudioGong.play()
		$ReinfTimer.start()
		world.set_gong_activated()


func _on_reinf_timer_timeout():
	world.set_reinforcements()
