# Scene Hierarchy Guide

This document defines the canonical scene tree structure for Bone & Barrow's main game scene.

## The Hierarchy (Scene Tree)

Create a new **3D Scene** and set up your tree exactly like this:

```text
Main (Node3D)
├── WorldEnvironment    (Lighting & Post-Processing)
├── DirectionalLight3D  (The Moon)
├── Managers (Node)     (Scripts that run logic but aren't objects)
│   ├── WaveManager
│   └── GameEvents
├── NavigationRegion3D  (CRITICAL: AI walks on this)
│   └── LevelGeometry (Node3D)
│       ├── Floor       (MeshInstance3D + StaticBody3D)
│       ├── Walls       (Node3D container)
│       └── Obstacles   (Tombstones, Fences)
├── Entities (Node3D)   (Dynamic objects go here)
│   ├── Player          (Instance your player.tscn here)
│   ├── Enemies         (Node3D - Spawn enemies as children of this)
│   ├── Projectiles     (Node3D - Spawn bullets here so they don't move with parents)
│   └── Traps           (Node3D - Spawn your towers here)
├── CameraRig (Node3D)  (The "Invisible Crane" holding the camera)
│   └── Camera3D
└── UI (CanvasLayer)    (Draws over everything)
    └── HUD             (Health bar, Gold count)
```

## Why This Structure Saves You Time Later

1.  **`Projectiles` Folder:** If you fire a bullet and make it a child of the Player, the bullet will move *with* the Player when he walks. Putting it in a separate `Projectiles` folder keeps bullets moving independently in the world.

2.  **`NavigationRegion3D` Root:** When you place a "Wall" trap, you can trigger a "Re-bake" on this node. The NavMesh updates, and enemies automatically walk *around* the new wall. This is the core of your "Mazing" gameplay.

## Implementation Notes

- **Managers node:** Contains scene-scoped managers (WaveManager, etc.). Note that GameEvents is actually an autoload singleton, not a scene instance.
- **NavigationRegion3D placement:** Must be the parent of all static geometry that affects pathfinding
- **Entity organization:** Grouping by type (Enemies, Projectiles, Traps) prevents transform inheritance issues and simplifies batch operations
- **CameraRig pattern:** Allows for camera shake, smooth follow, and future cinematics without directly manipulating the Camera3D
