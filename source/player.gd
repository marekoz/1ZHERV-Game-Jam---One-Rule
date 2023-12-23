extends CharacterBody3D

const MOUSE_SENSE = 0.1
const SPEED = 6.0
const JUMP_VELOCITY = 4.5
@onready var world = get_tree().get_root().get_child(0)

@onready var throwing_knife = preload("res://knife.tscn")
@onready var left_hand = $Neck/Head/LeftHand
@onready var hook = $Neck/Head/LeftHand/grappler/Hook
@onready var rope = $Neck/Head/LeftHand/grappler/RopeAnchor/Rope
@onready var rope_anchor = $Neck/Head/LeftHand/grappler/RopeAnchor
@onready var flying_hook = $FlyingHook
@onready var right_hand = $Neck/Head/RightHand
@onready var head = $Neck/Head
@onready var grapple_raycast = $Neck/Head/GrappleRaycast
@onready var knife_raycast = $Neck/Head/KnifeRaycast
@onready var knife_spawn = $Neck/Head/KnifeSpawn

#@onready var 
@onready var Neck 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_grappling = false
var gpoint_distance
var grapple_point

var can_throw = true
@export var knife_count = 5

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSE))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSE))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
		
func _physics_process(delta):
	$UI/GameUI/KnivesCnt.text = str(knife_count)
	throw_knife_check()
	grapple(delta)
	if not is_grappling:
		move(delta)
		lean(delta)


func add_knife(amount):
	knife_count += amount
	if knife_count > 0:
		$Neck/Head/RightHand/kunai.visible = true
		
func throw_knife_check():	
	if Input.is_action_just_pressed("LeftClick"):
		if can_throw and knife_count > 0 and $RightHandPlayer.current_animation != "throw":
				$RightHandPlayer.play("throw")
				can_throw = false
	
func throw_knife():
	var knife: CharacterBody3D = throwing_knife.instantiate()
	knife.rotation = head.global_rotation
	knife.direction = knife_raycast.get_collision_point() - knife_spawn.global_position
	knife.direction = knife.direction.normalized()
	world.add_child(knife)
	knife.global_position = knife_spawn.global_position
	knife_count -= 1
	can_throw = true
	if knife_count < 1:
		$Neck/Head/RightHand/kunai.visible = false

	
func move(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func grapple(delta):
	if Input.is_action_just_pressed("F"):
		var body = grapple_raycast.get_collider()
		print(body)
		if body != null and body != self:
			grapple_point = grapple_raycast.get_collision_point()
			is_grappling = true
	if is_grappling == true:
		if grapple_point:
			left_hand.look_at(grapple_point, Vector3(0,1,0))
			left_hand.rotate_object_local(Vector3(0,1,0), 3.14)
		hook.visible = false
		rope.visible = true
		rope.scale.y = rope_anchor.global_position.distance_to(grapple_point)
		flying_hook.visible = true
		flying_hook.global_position = grapple_point
		
		flying_hook.look_at(left_hand.global_position) 
		self.gravity = -9.8
		gpoint_distance = grapple_point.distance_to(self.transform.origin)
		if grapple_point.distance_to(self.transform.origin) > 1:
			self.transform.origin = lerp(self.transform.origin, grapple_point, delta * 4)
		if self.position.y > grapple_point.y + 3:
			self.gravity = 9.8
	else:
		self.gravity = 9.8
		rope.visible = false
		hook.visible = true
		flying_hook.visible = false
		$HookPlayer.play("RESET")
	if Input.is_action_just_pressed("Space"):
		if is_grappling:
			self.velocity.y = JUMP_VELOCITY
			is_grappling = false
	move_and_slide()

		
func lean(delta):
	var target_rotation
	if Input.is_action_pressed("E"):
		target_rotation = deg_to_rad(-30)
	elif Input.is_action_pressed("Q"):
		target_rotation = deg_to_rad(30)
	else:
		target_rotation = 0.0
	$Neck.rotation.z = lerp_angle($Neck.rotation.z, target_rotation, 10 * delta)


func set_objective(objective):
	$UI/GameUI/Objective2.text = objective
	
func set_rule(rule):
	$UI/GameUI/Rule2.text = rule
