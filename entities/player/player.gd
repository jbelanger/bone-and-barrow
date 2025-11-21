extends CharacterBody3D

## ============================================================================
## PLAYER / NECROMANCER
## ============================================================================
## The player character - a lonely lich defending their graveyard

# --- TUNING KNOBS ---
@export var speed: float = 8.0
@export var acceleration: float = 50.0
@export var friction: float = 80.0

@export_group("Necromancy")
## Distance from which player can raise corpses
@export var interact_range: float = 2.5

@export_group("Combat")
## Soul bolt projectile scene
@export var soul_bolt_scene: PackedScene
## Direction player is facing (for shooting)
@export var shoot_direction: Vector3 = Vector3.FORWARD

## ============================================================================
## COMBAT TRACKING (for Skeleton Vengeance System)
## ============================================================================

## Last enemy that damaged the player (for skeleton AI vengeance trigger)
var last_attacker: Node3D = null
var last_attack_time: float = 0.0

## Health tracking
var max_hp: float = 100.0
var current_hp: float = 100.0

## Combat tracking
var last_shot_time: float = 0.0
var shot_cooldown: float = 0.5  # From GameBalance

# --- NODES ---
@onready var visual: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	add_to_group("player")
	
	# Load stats from GameBalance
	max_hp = GameBalance.PLAYER_BASE_HP
	current_hp = max_hp
	shot_cooldown = GameBalance.SOUL_BOLT_COOLDOWN

func _physics_process(delta: float) -> void:
	# 1. GET INPUT
	# We switched to "ui_" actions which exist by default (Arrow Keys / WASD)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Convert 2D input (X, Y) to 3D direction (X, Z)
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		# --- WE ARE MOVING ---
		# Accelerate towards the direction
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)

		# Update facing direction for shooting
		shoot_direction = direction

		# Play animation (only if it's not already playing)
		if not visual.is_playing():
			visual.play("idle")

		# Flip sprite based on direction
		if direction.x < 0:
			visual.flip_h = true
		elif direction.x > 0:
			visual.flip_h = false
			
	else:
		# --- WE ARE STOPPING ---
		# Apply friction to slow down
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
		# If we are basically stopped, freeze the animation
		if velocity.length() < 0.1:
			visual.frame = 0  # Snap to the first frame (Standing still)
			visual.stop()     # Stop playing the loop

	# Apply the physics
	move_and_slide()

	# 4. HANDLE SHOOTING (Soul Bolt)
	if Input.is_action_pressed("shoot"):
		_try_shoot()

	# 5. HANDLE INTERACTION (Raise Dead)
	if Input.is_action_just_pressed("interact"):
		_try_raise_dead()

## ============================================================================
## COMBAT FUNCTIONS
## ============================================================================

func take_damage(amount: float, attacker: Node3D = null) -> void:
	"""Called when player takes damage"""
	current_hp -= amount
	
	# Track attacker for skeleton vengeance system
	if attacker != null:
		last_attacker = attacker
		last_attack_time = Time.get_ticks_msec() / 1000.0
	
	# Visual feedback
	if visual:
		visual.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		visual.modulate = Color.WHITE
	
	print("[Player] Took %d damage! HP: %d/%d" % [amount, current_hp, max_hp])
	
	if current_hp <= 0:
		_die()

func get_last_attacker() -> Node3D:
	"""Get the last enemy that attacked the player (for skeleton vengeance)"""
	# Only return attacker if attack was recent (within last 2 seconds)
	if last_attacker != null:
		var time_since_attack = (Time.get_ticks_msec() / 1000.0) - last_attack_time
		if time_since_attack < 2.0 and is_instance_valid(last_attacker):
			return last_attacker
	return null

func _die() -> void:
	"""Handle player death"""
	print("[Player] Died!")
	# TODO: Game over logic
	# TODO: Play death animation
	# For now, just reset HP (for testing)
	current_hp = max_hp

func _try_shoot() -> void:
	"""Shoot soul bolt if cooldown is ready"""
	var current_time = Time.get_ticks_msec() / 1000.0

	# Check cooldown
	if current_time - last_shot_time < shot_cooldown:
		return

	if soul_bolt_scene == null:
		push_error("Player: No soul bolt scene assigned!")
		return

	# Spawn projectile
	var bolt = soul_bolt_scene.instantiate()
	get_parent().add_child(bolt)

	# Position slightly in front of player
	var spawn_offset = shoot_direction * 0.5
	bolt.global_position = global_position + spawn_offset + Vector3(0, 0.5, 0)

	# Setup projectile with direction and damage
	if bolt.has_method("setup"):
		bolt.setup(bolt.global_position, shoot_direction, self)
		bolt.damage = GameBalance.SOUL_BOLT_DAMAGE

	last_shot_time = current_time
	print("[Player] Shot soul bolt!")

	# TODO: Play shoot animation
	# TODO: Play shoot sound effect

## ============================================================================
## NECROMANCY
## ============================================================================

func _try_raise_dead() -> void:
	"""Find nearest corpse and raise it"""
	var corpses = get_tree().get_nodes_in_group("corpses")
	var nearest: Node3D = null
	var nearest_dist: float = interact_range

	for corpse in corpses:
		if not is_instance_valid(corpse):
			continue

		var dist = global_position.distance_to(corpse.global_position)
		if dist < nearest_dist:
			nearest = corpse
			nearest_dist = dist

	if nearest and nearest.has_method("raise"):
		nearest.raise()
		print("[Player] Raised corpse at distance %.1fm" % nearest_dist)
		# TODO: Play "Cast Spell" animation
		# TODO: Play raise spell sound effect
	else:
		print("[Player] No corpses nearby to raise.")
