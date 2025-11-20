extends CharacterBody3D

# --- TUNING KNOBS ---
@export var speed: float = 8.0
@export var acceleration: float = 50.0
@export var friction: float = 80.0

# --- NODES ---
@onready var visual: AnimatedSprite3D = $AnimatedSprite3D

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
