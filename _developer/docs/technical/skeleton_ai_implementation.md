# Skeleton AI Implementation
## Smart Leash System with Combat Lock

---

## Overview

This document explains the skeleton minion AI system for **Bone & Barrow**. The AI solves the core problem of commanding 20+ skeletons that feel intelligent without being micromanaged.

---

## The Core Problem We Solved

**Challenge**: Skeletons need to:
1. Follow the player naturally
2. Engage enemies when nearby
3. Not get left behind during retreats
4. Not abandon active fights prematurely
5. Protect the player when threatened

**Solution**: A priority-based state machine with "Combat Lock" and "Leash with Hysteresis"

---

## State Machine

### States

```gdscript
enum State {
    SPAWN_GRACE,     # Invulnerable sprint to player after being raised
    COMBAT_LOCKED,   # Locked in fight with an enemy
    RALLY,           # Sprinting back to player (too far)
    FOLLOW,          # Orbiting player, ready to engage
}
```

### State Priority (Highest to Lowest)

1. **Combat Lock**: If fighting an enemy, finish the fight (unless player is 25m+ away)
2. **Vengeance**: If player takes damage, attack the attacker
3. **Leash Break**: If player is 15m+ away, rally to them
4. **Leash Restore**: If rallying and within 10m, resume normal behavior
5. **Combat**: Attack enemies within 6m
6. **Follow**: Orbit player at 3m distance

---

## Key Systems

### 1. Combat Lock System

**Problem**: Without this, skeletons would abandon fights when player moves slightly, leaving enemies alive.

**Solution**: Once a skeleton damages an enemy, it becomes "locked" to that enemy:

```gdscript
var locked_to_enemy: Node3D = null  # Enemy we're committed to fighting

# Skeleton won't rally until:
# - Enemy dies, OR
# - Player gets 25m+ away (huge threshold)
```

**Result**: Skeletons finish their fights, preventing "abandoned paladin" scenarios.

---

### 2. Leash with Hysteresis

**Problem**: Single-threshold leashes cause jitter (skeleton constantly switching between "too far" and "close enough")

**Solution**: Two thresholds with hysteresis:

```gdscript
@export var leash_break_distance: float = 15.0    # Trigger rally
@export var leash_restore_distance: float = 10.0  # Exit rally
```

**Behavior**:
- At 15m: Skeleton starts rallying (breaks combat, sprints to player)
- At 10m: Skeleton stops rallying (can fight again)
- Between 10-15m: Skeleton maintains current state (no switching)

**Result**: Smooth, predictable behavior without jitter.

---

### 3. Vengeance Trigger

**Problem**: When retreating at low HP, enemies hitting you from range cause your army to turn around and chase, locking you in place.

**Solution**: Bodyguard radius with limited response

```gdscript
# In player script:
var last_attacker: Node3D = null
func get_last_attacker() -> Node3D:
    # Returns attacker only if hit was within last 2 seconds
    
# In skeleton script:
if attacker and distance_to(attacker) < 12.0:  # Bodyguard radius
    locked_to_enemy = attacker  # Only nearby skeletons respond
```

**Result**: 
- Close threats trigger immediate response
- Distant threats don't cause army to scatter
- You can still retreat effectively

---

### 4. Spawn Grace Period

**Problem**: Newly raised skeletons spawned mid-combat get instantly killed

**Solution**: 1.5 second invulnerability sprint

```gdscript
@export var spawn_grace_duration: float = 1.5

# During grace period:
# - Sprint directly to player at rally speed
# - Ignore all enemies
# - Visual indicator (green tint)
```

**Result**: Skeletons reliably join your army, even in chaos

---

## Enemy Aggro System

Enemies don't automatically attack skeletons. They only switch targets when:

### Aggro Triggers

1. **Collision Aggro**: Enemy physically bumps into skeleton
2. **Damage Aggro**: Skeleton damages the enemy

```gdscript
# In enemy script:
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("skeletons"):
        _aggro_onto(body)

func take_damage(amount: float, attacker: Node3D = null):
    if attacker and attacker.is_in_group("skeletons"):
        _aggro_onto(attacker)
```

### Aggro Behavior

- **Default**: Enemy marches toward Crypt Heart/Player
- **After Aggro**: Enemy fights skeleton until it dies
- **After Kill**: Enemy returns to marching toward Heart

**Result**: 
- Skeletons act as "ablative armor" - each hit they take is one you didn't
- Natural "roadblock" behavior without complex AI
- Player can't just place skeletons as invincible walls

---

## Tuning Parameters

All critical values are exported for easy iteration:

```gdscript
@export_group("Leash Settings")
@export var combat_radius: float = 6.0              # "Can see enemies this far"
@export var leash_break_distance: float = 15.0     # "Player too far - RALLY!"
@export var leash_restore_distance: float = 10.0   # "Close enough - resume"
@export var follow_radius: float = 3.0             # "Stay this close to player"

@export_group("Movement Speeds")
@export var walk_speed: float = 100.0              # Normal speed
@export var rally_speed: float = 140.0             # Sprint (40% faster)

@export_group("Combat Lock Settings")
@export var max_combat_lock_distance: float = 25.0  # "Player too far - abandon fight"
```

### Recommended Starting Values

Based on our design discussions:

- **Combat Radius**: 6m (close enough to feel responsive)
- **Leash Break**: 15m (tight control, frequent regrouping)
- **Leash Restore**: 10m (5m hysteresis gap)
- **Max Combat Lock**: 25m (large - skeletons commit to fights)
- **Rally Speed**: 140 units (40% faster than walk)

**Playtesting Note**: If skeletons feel "too sticky" to fights, reduce `max_combat_lock_distance`. If they feel "too scattered," reduce `leash_break_distance`.

---

## File Structure

```
entities/
├── skeletons/
│   ├── skeleton.gd          # AI state machine (class_name Skeleton)
│   └── skeleton.tscn        # Scene with Visual/Collision/Detection areas
├── enemies/
│   ├── enemy.gd            # Aggro system (class_name Enemy)
│   └── enemy.tscn          # Scene setup
└── player/
    ├── player.gd           # Vengeance tracking (added)
    └── player.tscn         # Existing scene
```

---

## Usage

### Creating a Skeleton

1. Instance `skeleton.tscn`
2. Set `skeleton_type` in inspector
3. Ensure player node is in "player" group
4. Stats auto-load from `GameBalance`

### Creating an Enemy

1. Instance `enemy.tscn`
2. Set `enemy_type` in inspector
3. Set `primary_target` (Crypt Heart) or leave null to auto-find
4. Add to "enemies" group (done automatically)

### Required Groups

- **Player**: `add_to_group("player")`
- **Enemies**: `add_to_group("enemies")` (auto)
- **Skeletons**: `add_to_group("skeletons")` (auto)
- **Crypt Heart**: `add_to_group("crypt_heart")`

---

## What's Left to Implement

### Critical for Testing
1. **Scene Setup**: Create `skeleton.tscn` and `enemy.tscn` with proper node structure
2. **Visual Nodes**: AnimatedSprite3D with placeholder animations
3. **Detection Areas**: Area3D nodes for enemy detection

### Nice to Have
1. **Corpse System**: Enemies drop corpses that can be re-raised
2. **Formation Offsets**: Spread skeletons in circle around player (avoid blob)
3. **Debug Visualization**: Draw detection radii in editor
4. **Particle Effects**: Raise animation, death crumble, rally sprint trail

### Later
1. **Pathfinding**: Use NavigationAgent3D if obstacles are added
2. **Unit Abilities**: Skeleton Archer ranged attacks, Mage slow effects
3. **Performance**: Object pooling for 50+ units

---

## Testing Checklist

### Scenario 1: Basic Following
- [ ] Skeleton spawns and sprints to player (grace period)
- [ ] Skeleton orbits player at ~3m distance
- [ ] Skeleton moves with player naturally

### Scenario 2: Combat
- [ ] Skeleton attacks enemy within 6m
- [ ] Enemy aggros onto skeleton (not player)
- [ ] Skeleton finishes fight before rejoining player

### Scenario 3: Leash
- [ ] Player runs 15m away → skeleton rallies
- [ ] Skeleton sprints (faster than walk)
- [ ] At 10m → skeleton resumes normal behavior

### Scenario 4: Vengeance
- [ ] Enemy hits player
- [ ] Nearby skeletons (within 12m) attack enemy
- [ ] Distant skeletons ignore threat

### Scenario 5: Combat Lock
- [ ] Skeleton fighting enemy
- [ ] Player moves 14m away
- [ ] Skeleton **stays fighting** (doesn't rally)
- [ ] Player moves 26m away
- [ ] Skeleton **abandons fight** and rallies

---

## Known Issues & Edge Cases

### Issue: Skeletons can't reach enemies on other side of obstacle
**Status**: Acceptable for MVP (no obstacles in graveyard)
**Solution**: Add NavigationAgent3D later if needed

### Issue: 20 skeletons might overlap into blob
**Status**: Known, accepted for MVP
**Solution**: Add formation offsets (circular spread) in future update

### Issue: Teleporting enemies could break combat lock
**Status**: Edge case, unlikely in our game
**Solution**: Add `is_instance_valid()` checks (already in place)

---

## Design Philosophy Recap

From our discussions:

> "Skeletons are Ablative Armor. Every hit they take is one you didn't."

> "The Crumble → Re-Raise loop naturally fixes AI problems. Skeleton stuck? He'll die soon anyway."

> "Embrace 'good enough' AI. Players won't notice jitter in a 20-skeleton horde."

The system achieves:
- ✅ No manual rally button needed
- ✅ Army stays cohesive
- ✅ Skeletons feel responsive, not robotic
- ✅ Combat feels chaotic but controlled
- ✅ Simple to tune (all exports)

---

## Credits

This design was developed through extensive discussion about minion AI challenges, aggro systems, state machine architecture, and playtest-driven iteration. The key insight was: **add complexity to the AI, but remove complexity from the player input.**

**Result**: One stick controls 20+ minions. It feels like magic.
