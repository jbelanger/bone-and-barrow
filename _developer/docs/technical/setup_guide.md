# Quick Setup Guide - Skeleton AI Testing

## What Was Implemented

✅ **Skeleton AI** (`skeleton.gd`) - Full state machine with:
- Combat Lock system
- Leash with Hysteresis
- Vengeance trigger
- Spawn grace period
- All tuning parameters as exports

✅ **Enemy Aggro System** (`enemy.gd`) - Collision and damage aggro

✅ **Player Updates** (`player.gd`) - Vengeance tracking (last attacker)

✅ **Documentation** (`skeleton_ai_implementation.md`) - Complete technical reference

---

## What You Need to Do Next

### 1. Create Scene Files

You need to create `.tscn` files for the skeleton and enemy. Here's the minimal node structure:

#### `skeleton.tscn`
```
Skeleton (CharacterBody3D) [skeleton.gd attached]
├── Visual (AnimatedSprite3D)
│   └── Set "billboard" to Y-Axis
├── CollisionShape3D
│   └── Shape: CapsuleShape3D (radius: 0.3, height: 1.0)
├── HitArea (Area3D)
│   └── CollisionShape3D
│       └── Shape: SphereShape3D (radius: 0.5)
└── DetectionArea (Area3D)
    └── CollisionShape3D
        └── Shape: SphereShape3D (radius: 6.0)
```

#### `enemy.tscn`
```
Enemy (CharacterBody3D) [enemy.gd attached]
├── Visual (AnimatedSprite3D)
│   └── Set "billboard" to Y-Axis
└── CollisionShape3D
    └── Shape: CapsuleShape3D (radius: 0.3, height: 1.0)
```

**Note**: The scripts reference these node names, so match them exactly (or update the `@onready` vars in the scripts).

---

### 2. Set Up Test Scene

Create a test scene: `levels/test_gyms/skeleton_ai_test.tscn`

**Minimal setup**:
```
Node3D (Root)
├── Player (from player.tscn)
├── Skeleton1 (from skeleton.tscn)
├── Skeleton2 (from skeleton.tscn)
├── Enemy1 (from enemy.tscn)
└── Ground (MeshInstance3D with PlaneMesh)
```

**Important**:
- Player must be in "player" group (already done in script)
- Enemies auto-add to "enemies" group
- Skeletons auto-add to "skeletons" group

---

### 3. Placeholder Sprites

For quick testing, use simple placeholder sprites:

**Option A - Colored Rectangles** (fastest):
1. In Godot, create a new `AnimatedSpriteFrames` resource
2. Add animation named "idle"
3. Create a simple colored rectangle in any image editor:
   - Player: Blue rectangle (64x64)
   - Skeleton: White rectangle (32x64)
   - Enemy: Red rectangle (32x64)
4. Drag into Godot, assign to AnimatedSprite3D

**Option B - Use Existing Assets**:
You have player sprites in `assets/sprites/player/`
- Use those for the player
- Duplicate and recolor for skeletons (white tint)
- Duplicate and recolor for enemies (red tint)

---

### 4. Initial Test

**Run the test scene and verify**:

1. **Skeleton spawns** → sprints to player (green tint)
2. **Grace period ends** → white color, orbits player
3. **Move player** → skeletons follow
4. **Run 15m away** → skeletons rally (sprint back)
5. **Enemy approaches** → skeletons attack
6. **Enemy hits player** → skeletons dogpile attacker

---

## Testing Scenarios

### Test 1: Basic Following
```
1. Start scene with 1 skeleton, no enemies
2. Move player around
3. Expected: Skeleton follows at ~3m distance
```

### Test 2: Combat Lock
```
1. Start scene with 1 skeleton, 1 enemy
2. Let skeleton engage enemy
3. Run player 14m away
4. Expected: Skeleton STAYS FIGHTING (doesn't follow yet)
5. Run player 26m away
6. Expected: Skeleton ABANDONS fight, rallies to you
```

### Test 3: Multi-Skeleton Swarm
```
1. Start scene with 5 skeletons, 1 enemy
2. Move near enemy
3. Expected: All 5 skeletons dogpile the enemy
4. Run away while fight is happening
5. Expected: Skeletons finish fight, then rally
```

### Test 4: Vengeance
```
1. Start scene with 3 skeletons spread around player
2. Enemy shoots player from distance
3. Expected: Only nearby skeletons (within 12m) respond
```

---

## Tuning the Feel

If skeletons feel wrong, adjust these exports in the inspector:

**Skeletons feel too scattered?**
→ Reduce `leash_break_distance` (try 12m instead of 15m)

**Skeletons feel too clingy to fights?**
→ Reduce `max_combat_lock_distance` (try 20m instead of 25m)

**Skeletons feel too slow to catch up?**
→ Increase `rally_speed` (try 160 instead of 140)

**Skeletons attack too late?**
→ Increase `combat_radius` (try 8m instead of 6m)

---

## Common Issues

### "Skeleton doesn't move"
- Check that `player` is in "player" group
- Verify player node is found in `_ready()`
- Check console for error: "No player found"

### "Enemy doesn't aggro on skeleton"
- Verify collision layers/masks are set correctly
- Check that `body_entered` signal is connected
- Ensure skeleton is in "skeletons" group

### "Skeleton stutters between states"
- Check that hysteresis is working (10m restore, 15m break)
- Verify player speed isn't faster than skeleton rally speed
- Look for state name in debug (add `print(get_state_name())`)

---

## Debug Helpers

Add these to your test scene for easier debugging:

### Debug Label (shows skeleton state)
```gdscript
# Add to skeleton.gd, in _process():
$DebugLabel.text = "%s\nDist: %.1f" % [get_state_name(), global_position.distance_to(player.global_position)]
```

### Visual Distance Rings
```gdscript
# Add to test scene, draw circles around player:
func _draw():
    draw_arc(Vector2.ZERO, 600, 0, TAU, 32, Color.GREEN)  # Combat radius
    draw_arc(Vector2.ZERO, 1000, 0, TAU, 32, Color.YELLOW) # Restore
    draw_arc(Vector2.ZERO, 1500, 0, TAU, 32, Color.RED)   # Break
```

### Console Logging
The scripts already have debug prints:
- `[Skeleton] Crumbled!`
- `[Skeleton] Hit enemy for X damage`
- `[Enemy] Aggro'd onto skeleton!`
- `[Player] Took X damage!`

Watch the console to understand what's happening.

---

## Next Steps After Testing

Once basic AI works:

1. **Corpse System**: Enemies drop corpses when killed
2. **Raise Mechanic**: Press E near corpse to raise it
3. **Soul Economy**: Raising costs souls, killing gives souls
4. **Multiple Skeleton Types**: Implement Warrior/Archer/Brute variants
5. **Wave Spawner**: Spawn enemies in waves

But first: **Get 1 skeleton following 1 player attacking 1 enemy working perfectly.**

---

## Need Help?

The scripts are heavily commented. Look for:
- `## ===` section dividers
- `"""Docstrings"""` explaining functions
- `# TODO:` markers for future work

All critical logic is in these functions:
- `skeleton.gd::_physics_process()` - Main state machine
- `enemy.gd::_aggro_onto()` - Aggro trigger
- `player.gd::get_last_attacker()` - Vengeance system

Good luck! The hard part (the logic) is done. Now just hook it up visually.
