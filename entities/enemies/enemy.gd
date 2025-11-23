extends CharacterBody3D
class_name Enemy

## ============================================================================
## ENEMY BASE CLASS - Implements Aggro System for Bone & Barrow
## ============================================================================
## Enemies march toward Crypt Heart/Player by default
## They only attack skeletons when:
## 1. They collide with a skeleton
## 2. They take damage from a skeleton

enum EnemyState {
	MARCHING,      # Moving toward primary target (Heart or Player)
	ATTACKING,     # Fighting a skeleton that provoked them
}

## ============================================================================
## CONFIGURATION
## ============================================================================

@export_group("Enemy Type")
@export var enemy_type: GameBalance.EnemyType = GameBalance.EnemyType.SQUIRE

@export_group("Target Settings")
## Primary target (Crypt Heart or Player if none)
@export var primary_target: Node3D = null

@export_group("Drops")
## Corpse scene to spawn when this enemy dies
@export var corpse_scene: PackedScene

## ============================================================================
## INTERNAL STATE
## ============================================================================

var current_state: EnemyState = EnemyState.MARCHING
var current_target: Node3D = null
var aggro_target: Node3D = null  # Skeleton that provoked us

## Stats from GameBalance
var max_hp: float = 30.0
var current_hp: float = 30.0
var damage: float = 10.0
var speed: float = 7.5
var attack_range: float = 2.0

## Combat tracking
var last_hit_time: float = 0.0
var attack_cooldown: float = 1.0

## ============================================================================
## NODE REFERENCES
## ============================================================================

@onready var visual: Node3D = $Visual
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

## ============================================================================
## INITIALIZATION
## ============================================================================

func _ready() -> void:
	add_to_group("enemies")
	
	# Load stats from GameBalance
	_load_stats()
	
	# Find primary target (Crypt Heart)
	if primary_target == null:
		primary_target = get_tree().get_first_node_in_group("crypt_heart")
	
	# If no heart, target player
	if primary_target == null:
		primary_target = get_tree().get_first_node_in_group("player")
	
	if primary_target == null:
		push_error("Enemy: No primary target (Crypt Heart or Player) found!")
	
	current_target = primary_target

func _load_stats() -> void:
	"""Load enemy stats based on type from GameBalance"""
	if not GameBalance.ENEMY_STATS.has(enemy_type):
		push_error("Enemy: Invalid enemy type %s! Using defaults." % enemy_type)
		return

	var stats = GameBalance.ENEMY_STATS[enemy_type]
	max_hp = stats.get("hp", 30.0)
	current_hp = max_hp
	speed = stats.get("speed", 7.5)
	damage = stats.get("damage", 10.0)
	attack_range = stats.get("attack_range", 2.0)

## ============================================================================
## MAIN PHYSICS LOOP
## ============================================================================

func _physics_process(_delta: float) -> void:
	if current_target == null:
		return

	# Check if aggro target is still valid
	if aggro_target != null:
		if not is_instance_valid(aggro_target) or _is_target_dead(aggro_target):
			# Skeleton died - return to marching
			aggro_target = null
			current_target = primary_target
			current_state = EnemyState.MARCHING

	# Move toward current target
	var dist_to_target = global_position.distance_to(current_target.global_position)

	if dist_to_target > attack_range:
		# Move toward target
		var direction = (current_target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Check for collisions with skeletons after moving
		_check_collision_aggro()
	else:
		# In range, attack
		velocity = Vector3.ZERO
		move_and_slide()

		# Attack cooldown
		if Time.get_ticks_msec() - last_hit_time > attack_cooldown * 1000:
			_deal_damage(current_target)
			last_hit_time = Time.get_ticks_msec()

## ============================================================================
## AGGRO SYSTEM
## ============================================================================

func _check_collision_aggro() -> void:
	"""Check if we collided with a skeleton during move_and_slide"""
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider is Node and collider.is_in_group("skeletons"):
			_aggro_onto(collider)
			break

func take_damage(amount: float, attacker: Node3D = null) -> void:
	"""Damage Aggro: When skeleton damages us"""
	current_hp -= amount

	# Visual feedback
	if visual is MeshInstance3D:
		var mesh = visual as MeshInstance3D
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			(mat as StandardMaterial3D).albedo_color = Color.WHITE
			await get_tree().create_timer(0.1).timeout
			(mat as StandardMaterial3D).albedo_color = Color(1, 0.3, 0.3, 1)
	elif visual:
		visual.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		visual.modulate = Color(1, 0.3, 0.3, 1)
	
	# Switch target to attacker if it's a skeleton
	if attacker != null and attacker.is_in_group("skeletons"):
		_aggro_onto(attacker)
	
	if current_hp <= 0:
		_die()

func _aggro_onto(skeleton: Node3D) -> void:
	"""Switch target to a skeleton that provoked us"""
	aggro_target = skeleton
	current_target = skeleton
	current_state = EnemyState.ATTACKING
	print("[Enemy] Aggro'd onto skeleton!")

## ============================================================================
## COMBAT
## ============================================================================

func _deal_damage(target: Node3D) -> void:
	"""Deal damage to current target"""
	if target.has_method("take_damage"):
		target.take_damage(damage, self)
		print("[Enemy] Hit target for %d damage" % damage)

func _die() -> void:
	"""Handle enemy death"""
	print("[Enemy] Died!")

	# Spawn corpse at death location
	if corpse_scene:
		var corpse = corpse_scene.instantiate()
		get_parent().add_child(corpse)
		corpse.global_position = global_position
		corpse.global_rotation = global_rotation
		print("[Enemy] Spawned corpse at position %s" % global_position)
	else:
		push_warning("Enemy: No corpse scene assigned! Cannot spawn corpse.")

	# TODO: Drop souls for player
	# TODO: Play death animation/particles

	queue_free()

## ============================================================================
## UTILITY
## ============================================================================

func _is_target_dead(target: Node3D) -> bool:
	"""Check if a target is dead"""
	if target.has_method("is_dead"):
		return target.is_dead()
	return false

func is_dead() -> bool:
	"""Check if this enemy is dead"""
	return current_hp <= 0

func get_state_name() -> String:
	"""Get current state as string for debugging"""
	match current_state:
		EnemyState.MARCHING: return "MARCHING"
		EnemyState.ATTACKING: return "ATTACKING"
		_: return "UNKNOWN"
