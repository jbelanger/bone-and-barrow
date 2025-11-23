extends Area3D
class_name SoulBolt

## ============================================================================
## SOUL BOLT - Player's basic attack projectile
## ============================================================================
## Travels in a straight line, damages first enemy hit, then despawns

## SCENE SETUP:
## - Area3D (Root) with this script
## - Add Visual child (MeshInstance3D or Sprite3D) for the bolt visual
## - Add CollisionShape3D (SphereShape3D, radius ~0.3)
##   Set to Layer 2, Mask 1 (hits enemies but not player)

## ============================================================================
## CONFIGURATION
## ============================================================================

@export_group("Projectile Settings")
## Speed of projectile movement
@export var speed: float = 15.0
## Damage dealt on hit
@export var damage: float = 10.0
## Maximum lifetime before auto-despawn
@export var lifetime: float = 3.0

## ============================================================================
## INTERNAL STATE
## ============================================================================

var direction: Vector3 = Vector3.FORWARD
var lifetime_timer: float = 0.0
var owner_node: Node3D = null  # Who shot this (to avoid self-damage)

## ============================================================================
## INITIALIZATION
## ============================================================================

func _ready() -> void:
    add_to_group("projectiles")
    lifetime_timer = lifetime

    # Connect collision signals
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    # Move forward
    global_position += direction * speed * delta

    # Lifetime countdown
    lifetime_timer -= delta
    if lifetime_timer <= 0:
        queue_free()

## ============================================================================
## COLLISION HANDLING
## ============================================================================

func _on_body_entered(body: Node3D) -> void:
    """Hit a physics body (enemy, wall, etc.)"""
    # Check if it's an enemy
    if body.is_in_group("enemies") and body != owner_node:
        _hit_enemy(body)

func _on_area_entered(area: Area3D) -> void:
    """Hit an area (could be enemy hitbox)"""
    var parent = area.get_parent()
    if parent and parent.is_in_group("enemies") and parent != owner_node:
        _hit_enemy(parent)

func _hit_enemy(enemy: Node3D) -> void:
    """Deal damage to enemy and despawn"""
    if enemy.has_method("take_damage"):
        enemy.take_damage(damage, owner_node)
        print("[SoulBolt] Hit enemy for %d damage" % damage)

    # TODO: Play hit particle effect
    # TODO: Play hit sound effect

    queue_free()

## ============================================================================
## SETUP
## ============================================================================

func setup(start_pos: Vector3, shoot_direction: Vector3, shooter: Node3D) -> void:
    """Initialize projectile with position, direction, and owner"""
    global_position = start_pos
    direction = shoot_direction.normalized()
    owner_node = shooter

    # Rotate visual to face direction
    if direction.length() > 0.01:
        look_at(global_position + direction, Vector3.UP)
