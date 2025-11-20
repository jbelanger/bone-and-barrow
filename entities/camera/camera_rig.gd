extends Node3D

@export var target_path: NodePath
@export var smooth_speed: float = 5.0

var target: Node3D

func _ready() -> void:
	# Find the player in the scene tree
	if target_path:
		target = get_node(target_path)
	else:
		# Auto-find if not assigned
		target = get_parent().find_child("Player")

func _process(delta: float) -> void:
	if not is_instance_valid(target): return
	
	# Smoothly interpolate position
	global_position = global_position.lerp(target.global_position, smooth_speed * delta)
