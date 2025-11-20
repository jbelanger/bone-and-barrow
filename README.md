# Bone & Barrow

A necromancer action roguelite built in Godot 4.5+ using GDScript.

## Core Concept

Defend your graveyard by raising slain enemies as skeleton minions. Grow from a fragile necromancer to commanding a 20+ unit horde within each 10-15 minute run.

**Core Loop:** Kill → Raise → Command → Survive

## Development Status

**Current Phase:** Pre-Milestone 1 (design documentation complete)

No Godot project exists yet - this is a pre-prototype phase with design docs only.

## Project Structure

```
res://
├── _developer/          # Non-game files (excluded from exports)
│   ├── docs/            # Vision, milestones, design docs
│   ├── prompts/         # AI agent instructions
│   └── raw_assets/      # Source files (Aseprite, PSD)
├── assets/              # Imported game assets
├── autoload/            # Global singletons (GameEvents, Telemetry, GameBalance)
├── components/          # Reusable component scripts
├── entities/            # Character scenes (player/, enemies/, skeletons/, structures/)
├── levels/              # Game maps (graveyard/, test_gyms/)
├── resources/           # Data-driven Resource files
├── systems/             # Scene-scoped managers
├── vfx/                 # Particles and shaders
├── ui/                  # Interface screens
└── tools/               # Editor plugins
```

## Key Documentation

- **CLAUDE.md** - Instructions for Claude Code AI agent
- **_developer/docs/research/vision.md** - Game philosophy and design pillars
- **_developer/docs/milestones.md** - 6-month development roadmap
- **autoload/game_balance.gd** - Single source of truth for ALL game numbers

## Development Philosophy

- **Composition over inheritance** - Small components, not monoliths
- **Death is your economy** - Kills become skeleton soldiers
- **Constrained randomness** - Variety without unfairness
- **Performance is critical** - 50+ units at 60 FPS required

## Tech Stack

- **Engine:** Godot 4.5+
- **Language:** GDScript (strict typing enforced)
- **Art:** 2D sprites in 3D world (billboard rendering)
- **AI:** Claude Code for development assistance

## Timeline

6-month solo development project targeting a focused, polished core experience.

## License

All rights reserved (currently pre-release).
