extends Node3D
class_name Corpse

## ============================================================================
## CORPSE - Fallen enemy waiting to be raised
## ============================================================================
## Spawned when enemies die, can be raised by player pressing 'E' nearby
## Automatically despawns after a timeout to prevent performance issues

## SCENE SETUP:
## - Node3D (Root) with this script attached
## - Add Visual child (MeshInstance3D or Sprite3D) for the corpse visual
## - Add InteractArea (Area3D) with CollisionShape3D (SphereShape3D, radius ~1.5)
##   Set InteractArea to Layer 1, Mask 0 (only for detection, not physics)

## ============================================================================
## CONFIGURATION
## ============================================================================

@export_group("Raise Settings")
## Scene to spawn when raised (should be a Skeleton)
@export var skeleton_scene: PackedScene
## Time before corpse despawns automatically (prevents clutter)
@export var despawn_time: float = 60.0

## ============================================================================
## INTERNAL STATE
## ============================================================================

var despawn_timer: float = 0.0

## ============================================================================
## NODE REFERENCES
## ============================================================================

@onready var visual: Node3D = $Visual
@onready var interact_area: Area3D = $InteractArea

## ============================================================================
## INITIALIZATION
## ============================================================================

func _ready() -> void:
    add_to_group("corpses")
    despawn_timer = despawn_time

    # Optional: Add subtle tint for corpses
    if visual is Sprite3D:
        visual.modulate = Color(0.7, 0.7, 0.7, 0.8)  # Slightly transparent for sprites
    elif visual is MeshInstance3D:
        # For 3D meshes, we'd need to modify the material (skip for now)
        pass

func _process(delta: float) -> void:
    # Countdown to despawn
    despawn_timer -= delta
    if despawn_timer <= 0:
        _despawn()

## ============================================================================
## INTERACTION
## ============================================================================

func raise() -> void:
    """Convert this corpse into a living skeleton"""
    if skeleton_scene == null:
        push_error("Corpse: No skeleton scene assigned! Cannot raise.")
        return

    # 1. Spawn Skeleton at corpse location
    var skeleton = skeleton_scene.instantiate()
    get_parent().add_child(skeleton)
    skeleton.global_position = global_position
    skeleton.global_rotation = global_rotation

    # 2. Visual feedback (you can add particles/sound here)
    print("[Corpse] Raised into Skeleton at position %s" % global_position)

    # TODO: Play "Raise Dead" particle effect
    # TODO: Play "Raise Dead" sound effect

    # 3. Delete corpse
    queue_free()

func _despawn() -> void:
    """Auto-despawn after timeout"""
    print("[Corpse] Despawned after %d seconds" % despawn_time)
    queue_free()

## ============================================================================
## UTILITY
## ============================================================================

func is_raiseable() -> bool:
    """Check if this corpse can be raised"""
    return skeleton_scene != null
