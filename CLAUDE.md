# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bone & Barrow** is a necromancer action roguelite built in Godot 4.5+ using GDScript. The player defends their graveyard by raising slain enemies as skeleton minions, growing from fragile to commanding a 20+ unit horde within each 10-15 minute run.

**Core Philosophy:**
- Death is your economy (kills become skeleton soldiers)
- Composition over inheritance (small components, not monoliths)
- Constrained randomness (variety without unfairness)
- Stakes with forgiveness (runs are tense but failure gives progress)
- 50+ units at 60 FPS required (performance is critical)

**Scope:** 6-month solo development timeline. See `_developer/docs/milestones.md` for development phases.

## Code Standards (STRICT)

### GDScript Requirements
- **Strict typing mandatory:** `var health: int = 10`, return types required (`-> void`)
- **4 SPACES indentation** (NOT tabs)
- **snake_case** for all files and directories
- **@export** for all tunable values (no magic numbers)
- **@onready var node: Node = $Path** for child references
- **%UniqueName** syntax for unique nodes

### Architecture Patterns
- **Signals UP, method calls DOWN:** Components signal to parents, parents call down to children
- **GameEvents autoload** for global event communication
- **Billboard pattern for all characters:** `CharacterBody3D → Sprite3D (Billboard: Enabled) + CollisionShape3D + Components`
- Delete unused files aggressively - no backwards-compatibility hacks

### Performance Requirements
- Simple follow logic for skeletons (NO NavigationAgent)
- Shared precalculated paths for enemies
- Object pooling for frequent spawns (corpses, particles, projectiles)
- Target: 50+ units at 60 FPS minimum

## Project Structure

```
res://
├── _developer/          # Non-game files (excluded from exports)
│   ├── docs/            # Vision, milestones, design docs
│   ├── prompts/         # AI agent instructions
│   └── raw_assets/      # Source files (Aseprite, PSD) before export
├── assets/              # Imported game assets
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── sprites/         # 2D character/item art
│   ├── environment/     # Tiles, props, textures
│   └── fonts/
├── autoload/            # Singletons (GameEvents, Telemetry, GameBalance)
├── components/          # Reusable component scripts
├── entities/            # Character scenes + scripts
│   ├── player/
│   ├── enemies/         # /squire, /knight subfolders
│   ├── skeletons/       # Raised minion types
│   └── structures/      # Crypt Heart, gravestones
├── levels/              # Game maps and rooms
│   ├── graveyard/       # Main biome scenes
│   └── test_gyms/       # Prototyping/testing scenes
├── resources/           # Data-driven Resource files (.tres)
│   ├── enemy_stats/
│   ├── upgrades/
│   └── waves/           # Wave composition data
├── systems/             # Scene-instanced managers (WaveManager, ShopManager)
├── vfx/                 # Visual effects
│   ├── particles/
│   └── shaders/
├── ui/                  # Interface screens
│   ├── hud/
│   ├── menus/
│   └── theme/
└── tools/               # Editor plugins, debug utilities
```

**Structure Notes:**
- `_developer/` excluded from game exports - contains docs and source art only
- `autoload/` = globally accessible singletons (registered in Project Settings)
- `systems/` = scene-scoped manager instances (NOT autoloads)
- `entities/` uses collocation - each subfolder contains .tscn + .gd + related scripts
- `test_gyms/` critical for rapid prototyping without polluting main scenes

## Single Source of Truth: game_balance.gd

**ALL game balance numbers live in `game_balance.gd`** - a global autoload class containing:
- Player/enemy/skeleton stats
- Wave compositions and timing
- Shop upgrade definitions
- Meta-progression costs
- Economy tuning multipliers

**Never hardcode balance numbers in individual scripts.** Reference `GameBalance.CONSTANT_NAME` instead.

**Tuning knobs for rapid iteration:**
- `GameBalance.gold_multiplier` - Scale all gold payouts
- `GameBalance.enemy_hp_scale` - Scale all enemy HP
- `GameBalance.wave_spawn_rate` - Enemies per second multiplier
- And more (see autoload/game_balance.gd:296-305)

## Telemetry System (Balance Metrics)

Log critical game events to the `Telemetry` autoload for AI-assisted balancing:

**Required events:**
- Run lifecycle (start/end with outcome, gold, wave reached)
- Wave events (start/end with kills, time, losses)
- Economy (shop picks, meta purchases)
- Combat (kills, damage, raises, skeleton deaths)
- Heart damage (defense effectiveness)
- Performance samples (FPS, entity counts every 10s)

**Format:** `Telemetry.event(name, entity, detail1, detail2, num1, num2, num3, num4)`

**Example:** `Telemetry.event("skeleton_raised", "warrior", "", "", total_count, corpses_available, 0, 0)`

## Development Workflow

### Before Writing Code
1. **Explore:** Use Read/Glob to check for existing components (avoid duplication)
2. **Plan:** State what you'll create/modify and why
3. **Confirm:** Ask for approval on deletions >50 lines or core system refactors

### Code Comments (Required)
Always include setup instructions for scene nodes:

```gdscript
# SCENE SETUP:
# - Add Timer child named "Cooldown"
# - Connect timeout signal to _on_cooldown_timeout
# - Set wait_time to 1.0, one_shot to false

# INSPECTOR:
# @export var speed: float = 300.0  # Movement speed
# @export var damage: int = 10      # Attack damage
```

### Review Checklist
Before marking work complete, verify:
- [ ] Type annotations on all variables and return types
- [ ] 4-space indentation (no tabs)
- [ ] No undefined node references
- [ ] No magic numbers (use GameBalance constants)
- [ ] Scene setup comments for any required nodes

## Common Development Commands

**Currently no Godot project exists** - this is a pre-prototype phase with design docs only.

When the Godot project is created, common commands will be:
- Run game: `godot --path . res://main.tscn`
- Run test scene: `godot --path . res://levels/test_gyms/test_combat.tscn`
- Export: `godot --export "Linux/X11" build/game.x86_64`

## Design Constraints

### Scope Control (Cut These First)
If behind schedule, cut in this order:
1. Skeleton types 4 & 5 (ship with 3 types)
2. Story journal beats (minimal flavor text only)
3. Wave modifiers (fixed compositions only)
4. Spell variety (2-3 spells instead of 5)

### Art Pipeline
- 2D sprites in 3D world (billboarding like Don't Starve/Cult of the Lamb)
- AI generation + Aseprite cleanup (2-3 hours per character max)
- Simple 2-frame walk cycles
- Dark-but-charming tone (NOT grimdark)

### Wave Pacing (Critical)
Each wave uses **Burst-Lull-Burst** pattern:
- Burst (45s): High spawn rate, intense combat
- Lull (20s): No spawns, raise corpses, reposition
- Burst/Lull/Burst: Repeat pattern
- Shop (15s): Pick upgrade between waves

**Never use continuous spawning** - exhausts players and removes strategic breathing room.

## Key Documentation

- **_developer/docs/research/vision.md** - Game philosophy, core loop, tone, why this will work
- **_developer/docs/milestones.md** - 6-month development roadmap with success metrics
- **_developer/prompts/master.md** - Detailed Godot agent instructions (strict architecture rules)
- **autoload/game_balance.gd** - Single source of truth for ALL game numbers

## Milestone Status

**Current Phase:** Pre-Milestone 1 (design documentation complete)

**Next Steps:**
- Create Godot 4.5 project structure
- Implement player movement + soul bolt attack
- Build 1 enemy type (squire) with pathfinding to Crypt Heart
- Implement "E to raise corpse" mechanic
- Validate core loop feels satisfying

**Critical Decision Point:** If Milestone 1 prototype doesn't feel fun after iteration, the core mechanic may not work. Be prepared to pivot or kill the project.
