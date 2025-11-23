extends Node3D
## Crypt Heart - The objective that must be defended
##
## The Crypt Heart is the necromancer's phylactery and the core of their power.
## If it's destroyed, the run ends. Enemies will pathfind to it and attack it.

# SCENE SETUP:
# - Root: Node3D
# - Add MeshInstance3D child for visual representation
# - Add Area3D child named "HitBox" with CollisionShape3D
# - Add to group "crypt_heart" in Scene panel (Groups tab)
#
# INSPECTOR:
# @export var max_hp: int = 500  # Maximum health from GameBalance

signal health_changed(new_hp: int, max_hp: int)
signal heart_destroyed

@export var max_hp: int = GameBalance.CRYPT_HEART_BASE_HP

var current_hp: int = 0


func _ready() -> void:
	current_hp = max_hp
	add_to_group("crypt_heart")
	health_changed.emit(current_hp, max_hp)


func take_damage(amount: float, attacker: Node3D = null) -> void:
	if current_hp <= 0:
		return

	var damage_int := int(amount)
	current_hp = max(0, current_hp - damage_int)
	health_changed.emit(current_hp, max_hp)

	# Log telemetry
	Telemetry.event("heart_damaged", "", "", "", current_hp, damage_int, 0, 0)

	if current_hp <= 0:
		_on_heart_destroyed()


func _on_heart_destroyed() -> void:
	heart_destroyed.emit()
	Telemetry.event("heart_destroyed", "", "", "", 0, 0, 0, 0)
	# TODO: Trigger game over state


func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	health_changed.emit(current_hp, max_hp)


func get_health_percent() -> float:
	if max_hp == 0:
		return 0.0
	return float(current_hp) / float(max_hp)
