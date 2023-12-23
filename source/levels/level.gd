extends Node3D

const level_objectives = ["kill targets", "kill all", "steal item", "destroy item"]
const rules = ["dont be seen", "dont kill anyone", "dont touch ground",
				 "dont sound alarm", "leave before reinforcements", "dont miss"]
@onready var objective_completed = false
@onready var gong = $GongLocation
@export var current_objective = "steal item"
@export var one_rule = "dont sound alarm"
@onready var player = get_node("Player")
@onready var targets = get_node("Targets")
@onready var enemies = get_node("Enemies")

#@onready var exit = $Exit

var gong_activated = false
var player_seen = false
var player_missed = false
var reinforcement = false

func _ready():
	player.set_objective(current_objective)
	player.set_rule(one_rule)

func _process(delta):
	
	if Input.is_action_just_pressed("Esc"):
		get_tree().change_scene_to_file("res://menu.tscn")

func fail_level():
	get_tree().change_scene_to_file("res://menu_fail.tscn")

func complete_level():
	get_tree().change_scene_to_file("res://menu_success.tscn")
	
	
func set_gong_activated():
	gong_activated = true
	#if one_rule == "dont sound alarm":
		#fail_level()

func set_player_seen():
	player_seen = true
	if one_rule == "dont be seen":
		fail_level()

func set_player_missed():
	player_missed = true
	if one_rule == "dont miss":
		fail_level()
		
func set_reinforcements():
	reinforcement = true
	if one_rule == "dont sound alarm":
		fail_level()
		
func target_killed():
	if current_objective == "kill targets":
		var all_killed = true
		for target in targets.get_children():
			if not target.is_dead:
				all_killed = false
		if all_killed:
			objective_completed = true
	elif current_objective == "kill all":
		var all_killed = true
		for target in targets.get_children():
			if not target.is_dead:
				all_killed = false
		for enemy in enemies.get_children():
			if not enemy.is_dead:
				all_killed = false
		if all_killed:
			objective_completed = true
			



func _on_area_3d_body_entered(body):
	if one_rule == "dont touch ground":
		self.fail_level()
