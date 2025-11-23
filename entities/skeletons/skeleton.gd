extends CharacterBody3D
class_name Skeleton

## ============================================================================
## SKELETON AI - State Machine with Smart Leash Logic
## ============================================================================
## Implements the "Combat Lock" + "Leash with Hysteresis" system
## See vision.md for design philosophy

enum State {
	FOLLOW,          # Orbit player, attack enemies within combat radius
	COMBAT_LOCKED,   # Locked in fight, won't rally until enemy dies or player is very far
	RALLY,           # Sprint to player, ignore enemies (except threats near player)
	SPAWN_GRACE,     # Invulnerable sprint to player after being raised
}

## ============================================================================
## CONFIGURATION (Export Variables for Easy Tuning)
## ============================================================================

@export_group("Leash Settings")
## Distance at which skeleton can engage enemies
@export var combat_radius: float = 6.0
## Distance at which skeleton triggers RALLY mode (breaks from combat)
@export var leash_break_distance: float = 15.0
## Distance at which skeleton exits RALLY and can fight again
@export var leash_restore_distance: float = 10.0
## Distance skeleton tries to maintain from player when following
@export var follow_radius: float = 3.0

@export_group("Movement Speeds")
## Normal movement speed (following/attacking)
@export var walk_speed: float = 7.0
## Speed when rallying back to player (must be faster than player)
@export var rally_speed: float = 10.0

@export_group("Combat Lock Settings")
## Maximum distance before skeleton abandons locked combat
@export var max_combat_lock_distance: float = 25.0

@export_group("Spawn Settings")
## Duration of invulnerable sprint after being raised
@export var spawn_grace_duration: float = 1.5

## ============================================================================
## INTERNAL STATE
## ============================================================================

var current_state: State = State.SPAWN_GRACE
var spawn_grace_timer: float = 0.0

## Reference to the necromancer player
var player: CharacterBody3D = null

## Enemy currently locked in combat with
var locked_to_enemy: Node3D = null

## Current target enemy (for attack state)
var current_target: Node3D = null

## Stats from GameBalance
var skeleton_type: GameBalance.SkeletonType = GameBalance.SkeletonType.WARRIOR
var max_hp: float = 20.0
var current_hp: float = 20.0
var damage: float = 5.0
var attack_range: float = 2.0

## Combat tracking
var last_hit_time: float = 0.0
var attack_cooldown: float = 1.0

## ============================================================================
## NODE REFERENCES
## ============================================================================

@onready var visual: Node3D = $Visual
@onready var hit_area: Area3D = $HitArea
@onready var detection_area: Area3D = $DetectionArea

## ============================================================================
## INITIALIZATION
## ============================================================================

func _ready() -> void:
	# Add to skeletons group for enemy detection
	add_to_group("skeletons")

	# Start in spawn grace period
	current_state = State.SPAWN_GRACE
	spawn_grace_timer = spawn_grace_duration

	# Find player in scene
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("Skeleton: No player found in scene! Add player to 'player' group.")

	# Load stats from GameBalance
	_load_stats()

func _load_stats() -> void:
	"""Load skeleton stats based on type from GameBalance"""
	if not GameBalance.SKELETON_STATS.has(skeleton_type):
		push_error("Skeleton: Invalid skeleton type %s! Using defaults." % skeleton_type)
		return

	var stats = GameBalance.SKELETON_STATS[skeleton_type]
	max_hp = stats.get("hp", 20.0)
	current_hp = max_hp
	damage = stats.get("damage", 5.0)
	walk_speed = stats.get("speed", 7.0)
	attack_range = stats.get("range", 2.0)

	# Rally speed is 40% faster than walk speed
	rally_speed = walk_speed * 1.4

## ============================================================================
## MAIN PHYSICS LOOP
## ============================================================================

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	# Handle spawn grace period
	if current_state == State.SPAWN_GRACE:
		_handle_spawn_grace(delta)
		return
	
	# Get distance to player
	var dist_to_player = global_position.distance_to(player.global_position)
	
	# === PRIORITY 1: Combat Lock (don't abandon active fights) ===
	if locked_to_enemy != null:
		if is_instance_valid(locked_to_enemy) and not _is_enemy_dead(locked_to_enemy):
			if dist_to_player < max_combat_lock_distance:
				current_state = State.COMBAT_LOCKED
				_attack_enemy(locked_to_enemy, delta)
				return
		# Enemy died or player too far - unlock
		locked_to_enemy = null
	
	# === PRIORITY 2: Vengeance (player took damage) ===
	if player.has_method("get_last_attacker"):
		var attacker = player.get_last_attacker()
		if attacker != null and is_instance_valid(attacker):
			var dist_to_attacker = global_position.distance_to(attacker.global_position)
			if dist_to_attacker < 12.0:  # Bodyguard radius
				locked_to_enemy = attacker
				current_state = State.COMBAT_LOCKED
				_attack_enemy(attacker, delta)
				return
	
	# === PRIORITY 3: Leash (player too far) ===
	if dist_to_player > leash_break_distance:
		current_state = State.RALLY
		_rally_to_player(delta)
		return
	
	# === PRIORITY 4: Restore from rally ===
	if current_state == State.RALLY and dist_to_player < leash_restore_distance:
		current_state = State.FOLLOW
	
	# === PRIORITY 5: Combat (enemies nearby) ===
	var nearest_enemy = _find_nearest_enemy_in_radius(combat_radius)
	if nearest_enemy != null:
		locked_to_enemy = nearest_enemy
		current_state = State.COMBAT_LOCKED
		_attack_enemy(nearest_enemy, delta)
		return
	
	# === PRIORITY 6: Follow/Orbit ===
	_orbit_player(delta)

## ============================================================================
## STATE HANDLERS
## ============================================================================

func _handle_spawn_grace(delta: float) -> void:
	"""Sprint to player with invulnerability for spawn_grace_duration"""
	spawn_grace_timer -= delta

	if spawn_grace_timer <= 0:
		current_state = State.FOLLOW
		# Reset color when spawn grace ends
		if visual is MeshInstance3D:
			var mesh = visual as MeshInstance3D
			var mat = mesh.get_active_material(0)
			if mat is StandardMaterial3D:
				(mat as StandardMaterial3D).albedo_color = Color(0.8, 0.9, 1, 1)
		elif visual is Sprite3D:
			visual.modulate = Color.WHITE
		return
	
	# Sprint directly to player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * rally_speed
	move_and_slide()

	# Visual: Green tint to show invulnerability during spawn grace
	if visual is MeshInstance3D:
		var mesh = visual as MeshInstance3D
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			(mat as StandardMaterial3D).albedo_color = Color(0.5, 1.0, 0.5, 1.0)
	elif visual is Sprite3D:
		visual.modulate = Color(0.5, 1.0, 0.5, 0.7)

func _rally_to_player(_delta: float) -> void:
	"""Sprint to player, ignore enemies unless threatening player"""
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * rally_speed
	move_and_slide()
	
	# Check for enemies threatening player (within 3m of player)
	var threats = _find_enemies_near_position(player.global_position, 3.0)
	if threats.size() > 0:
		# Defend player from closest threat
		locked_to_enemy = threats[0]
		current_state = State.COMBAT_LOCKED

func _orbit_player(delta: float) -> void:
	"""Stay near player, maintain follow_radius distance"""
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player > follow_radius:
		# Move towards player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * walk_speed
		move_and_slide()
	else:
		# Close enough, idle
		velocity = velocity.move_toward(Vector3.ZERO, walk_speed * delta)
		move_and_slide()

func _attack_enemy(enemy: Node3D, _delta: float) -> void:
	"""Move to enemy and attack"""
	var dist_to_enemy = global_position.distance_to(enemy.global_position)
	
	if dist_to_enemy > attack_range:
		# Move towards enemy
		var direction = (enemy.global_position - global_position).normalized()
		velocity = direction * walk_speed
		move_and_slide()
	else:
		# In range, attack
		velocity = Vector3.ZERO
		move_and_slide()
		
		# Attack cooldown
		if Time.get_ticks_msec() - last_hit_time > attack_cooldown * 1000:
			_deal_damage(enemy)
			last_hit_time = Time.get_ticks_msec()

## ============================================================================
## COMBAT FUNCTIONS
## ============================================================================

func _deal_damage(enemy: Node3D) -> void:
	"""Deal damage to an enemy"""
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, self)
		print("[Skeleton] Hit enemy for %d damage" % damage)

func take_damage(amount: float, attacker: Node3D = null) -> void:
	"""Called when skeleton takes damage"""
	current_hp -= amount

	# Visual feedback - flash red when hit
	if visual is MeshInstance3D:
		var mesh = visual as MeshInstance3D
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			(mat as StandardMaterial3D).albedo_color = Color.RED
			await get_tree().create_timer(0.1).timeout
			(mat as StandardMaterial3D).albedo_color = Color(0.8, 0.9, 1, 1)  # Return to normal skeleton color
	elif visual is Sprite3D:
		visual.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		visual.modulate = Color.WHITE

	if current_hp <= 0:
		_die()

func _die() -> void:
	"""Handle skeleton death - turn back into corpse"""
	print("[Skeleton] Crumbled!")

	# NOTE: Skeletons don't spawn corpses when they die to avoid circular dependency
	# (corpse.tscn references skeleton.tscn, so skeleton can't preload corpse.tscn)
	# Only enemies spawn corpses when they die.

	# Log telemetry
	Telemetry.event("skeleton_died", "", "", "", 0, 0, 0, 0)

	# TODO: Play death animation/particle effect

	queue_free()

## ============================================================================
## ENEMY DETECTION
## ============================================================================

func _find_nearest_enemy_in_radius(radius: float) -> Node3D:
	"""Find the nearest enemy within detection radius"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var nearest_dist: float = radius + 1.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or _is_enemy_dead(enemy):
			continue
		
		var dist = global_position.distance_to(enemy.global_position)
		if dist < radius and dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	
	return nearest

func _find_enemies_near_position(pos: Vector3, radius: float) -> Array:
	"""Find all enemies within radius of a position"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearby: Array = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or _is_enemy_dead(enemy):
			continue
		
		var dist = pos.distance_to(enemy.global_position)
		if dist < radius:
			nearby.append(enemy)
	
	# Sort by distance (closest first)
	nearby.sort_custom(func(a, b): return pos.distance_to(a.global_position) < pos.distance_to(b.global_position))
	
	return nearby

func _is_enemy_dead(enemy: Node3D) -> bool:
	"""Check if an enemy is dead"""
	if enemy.has_method("is_dead"):
		return enemy.is_dead()
	return false

## ============================================================================
## DEBUG VISUALIZATION
## ============================================================================

func _draw() -> void:
	"""Draw debug circles showing detection/leash radii (only in editor)"""
	if not Engine.is_editor_hint():
		return
	
	# Draw combat radius (green)
	_draw_circle_3d(Vector3.ZERO, combat_radius, Color.GREEN)
	
	# Draw leash break distance (red)
	_draw_circle_3d(Vector3.ZERO, leash_break_distance, Color.RED)
	
	# Draw leash restore distance (yellow)
	_draw_circle_3d(Vector3.ZERO, leash_restore_distance, Color.YELLOW)

func _draw_circle_3d(_center: Vector3, _radius: float, _color: Color) -> void:
	"""Helper to draw a circle in 3D space"""
	# This would need to be implemented with ImmediateMesh or debug draw
	pass

## ============================================================================
## UTILITY
## ============================================================================

func get_state_name() -> String:
	"""Get current state as string for debugging"""
	match current_state:
		State.FOLLOW: return "FOLLOW"
		State.COMBAT_LOCKED: return "COMBAT_LOCKED"
		State.RALLY: return "RALLY"
		State.SPAWN_GRACE: return "SPAWN_GRACE"
		_: return "UNKNOWN"
