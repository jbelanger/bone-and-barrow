extends Node
## Game Balance & Design Constants
##
## This file is the single source of truth for all game balance numbers.
## Design decisions and rationale are documented in comments.
## See vision.md for the overall game philosophy.

## ============================================================================
## PLAYER / NECROMANCER
## ============================================================================

## Base health - should feel fragile early game
const PLAYER_BASE_HP: int = 100
## Maximum HP after all meta upgrades (rank 3) = 190
const PLAYER_MAX_HP_UPGRADE: float = 0.90  # +90% total

## Soul bolt is the basic attack - fast but weak to encourage skeleton army
const SOUL_BOLT_DAMAGE: int = 10
const SOUL_BOLT_COOLDOWN: float = 0.5  # seconds

const PLAYER_MOVEMENT_SPEED: float = 8.0  # 3D units per second (tune in prototype)


## ============================================================================
## CRYPT HEART (The thing you're defending)
## ============================================================================

## Design: Should survive ~3-5 hits from enemies that slip through
const CRYPT_HEART_BASE_HP: int = 500


## ============================================================================
## SKELETON TYPES
## ============================================================================
## Design philosophy: Each type has a clear role, no "strictly better" options

enum SkeletonType {
	WARRIOR,  # Starter - balanced
	ARCHER,   # Glass cannon ranged
	BRUTE,    # Tank
	MAGE,     # Crowd control
	ROGUE,    # High risk/reward
}

## Skeleton stats [HP, Damage, Speed, Range, Special]
const SKELETON_STATS = {
	SkeletonType.WARRIOR: {
		"hp": 20,
		"damage": 5,
		"speed": 7.0,  # Medium (3D units/sec)
		"range": 2.0,   # Melee (3D units)
		"special": "none",
		"unlock_cost": 0,  # Starting unit
	},
	SkeletonType.ARCHER: {
		"hp": 12,
		"damage": 4,
		"speed": 5.5,  # Slow (3D units/sec)
		"range": 15.0,  # Ranged (3D units)
		"special": "ranged_attack",
		"unlock_cost": 800,
	},
	SkeletonType.BRUTE: {
		"hp": 40,
		"damage": 8,
		"speed": 5.0,  # Slow (3D units/sec)
		"range": 2.0,   # Melee (3D units)
		"special": "tank",
		"unlock_cost": 1200,
	},
	SkeletonType.MAGE: {
		"hp": 15,
		"damage": 3,
		"speed": 7.0,  # Medium (3D units/sec)
		"range": 12.0,  # Ranged (3D units)
		"special": "slows_enemies",
		"unlock_cost": 1500,
	},
	SkeletonType.ROGUE: {
		"hp": 10,
		"damage": 12,
		"speed": 10.0,  # Fast (3D units/sec)
		"range": 2.0,   # Melee (3D units)
		"special": "high_dps_fragile",
		"unlock_cost": 2000,
	},
}

## How close skeletons follow the player (meters)
const SKELETON_FOLLOW_DISTANCE: float = 5.0

## Soul cost to raise one corpse
const RAISE_CORPSE_SOUL_COST: int = 10

## Mass Raise: raise multiple at once (unlockable)
const MASS_RAISE_COUNT: int = 3
const MASS_RAISE_RADIUS: float = 5.0  # 3D units


## ============================================================================
## ENEMY TYPES (MVP = 3 types)
## ============================================================================
## Design: Simple threats that combo together
## - Squires: Numerous fodder that becomes YOUR army
## - Archers: Force you to move/dodge, threaten from range
## - Priests: Counter large armies (AOE that kills skeletons)

enum EnemyType {
	SQUIRE,
	ARCHER,
	PRIEST,
}

const ENEMY_STATS = {
	EnemyType.SQUIRE: {
		"hp": 30,
		"speed": 7.5,  # Fast (3D units/sec)
		"damage": 10,
		"behavior": "beeline_to_heart",
		"attack_range": 2.0,  # Melee (3D units)
	},
	EnemyType.ARCHER: {
		"hp": 25,
		"speed": 5.5,  # Slow (3D units/sec)
		"damage": 8,
		"behavior": "stop_at_range_shoot_player",
		"attack_range": 15.0,  # Ranged (3D units)
	},
	EnemyType.PRIEST: {
		"hp": 40,
		"speed": 7.0,  # Medium (3D units/sec)
		"damage": 15,
		"behavior": "aoe_kills_skeletons",
		"attack_range": 8.0,  # AOE radius (3D units)
		"special": "skeleton_killer",
	},
}


## ============================================================================
## WAVE COMPOSITION & DIFFICULTY SCALING
## ============================================================================
## Design: 5 waves, 2-3 minutes each, reaching "dawn" at 15 minutes
## Each wave = Burst-Lull-Burst pattern to avoid exhaustion

const WAVE_COUNT: int = 5

## How long each wave lasts (baseline)
const WAVE_DURATIONS: Array = [
	120,  # Wave 1: 2 min
	150,  # Wave 2: 2.5 min
	180,  # Wave 3: 3 min
	180,  # Wave 4: 3 min
	180,  # Wave 5: 3 min (Dawn)
]

## Enemy counts per wave [Squires, Archers, Priests]
## Design: Squires scale linearly, specialists scale faster to increase complexity
const WAVE_COMPOSITIONS: Array = [
	{"squires": 20, "archers": 3, "priests": 0},  # Wave 1: Learn basics
	{"squires": 25, "archers": 6, "priests": 1},  # Wave 2: Introduce priests
	{"squires": 30, "archers": 10, "priests": 2}, # Wave 3: First wall
	{"squires": 35, "archers": 12, "priests": 3}, # Wave 4: Intense
	{"squires": 40, "archers": 15, "priests": 5}, # Wave 5: Dawn or death
]

## Burst-Lull timing within each wave
const BURST_DURATION: float = 45.0  # seconds
const LULL_DURATION: float = 20.0   # seconds
## Pattern: Burst -> Lull -> Burst -> Lull -> Burst -> Shop


## ============================================================================
## WAVE MODIFIERS (Randomization)
## ============================================================================
## Design: Add variety without breaking balance
## Each wave gets ONE random modifier from appropriate pool

const WAVE_MODIFIERS_EASY: Array = [
	{"name": "Standard", "effect": "none"},
	{"name": "Scattered", "effect": "spawn_slower"},
]

const WAVE_MODIFIERS_HARD: Array = [
	{"name": "Reinforced", "effect": "spawn_count_125_percent"},
	{"name": "Vanguard", "effect": "20_percent_squires_to_paladins"},
	{"name": "Rapid", "effect": "all_spawn_at_once"},
	{"name": "Flanking", "effect": "spawn_unexpected_gate"},
]

## Wave 1 always uses EASY pool, Wave 5 always uses HARD pool


## ============================================================================
## PROGRESSION: SHOP UPGRADES (Within-Run, Temporary)
## ============================================================================
## Design: After each wave, pick 1 of 3 upgrades
## Shop MUST offer 1 Power / 1 Army / 1 Utility (no dead rolls)

const SHOP_UPGRADES = {
	"power": [
		{"name": "Heal 30%", "effect": "heal", "value": 0.30},
		{"name": "Heal 50%", "effect": "heal", "value": 0.50},
		{"name": "+10% Max HP", "effect": "max_hp", "value": 0.10},
		{"name": "+15% Damage", "effect": "player_damage", "value": 0.15},
		{"name": "+20% Soul Gain", "effect": "soul_multiplier", "value": 0.20},
	],
	"army": [
		{"name": "+20% Skeleton Damage", "effect": "skeleton_damage", "value": 0.20},
		{"name": "+15% Skeleton Speed", "effect": "skeleton_speed", "value": 0.15},
		{"name": "+25% Skeleton HP", "effect": "skeleton_hp", "value": 0.25},
		{"name": "Skeletons Explode on Death", "effect": "skeleton_explode", "value": 5},  # AOE damage
		{"name": "+5 Skeleton Capacity", "effect": "skeleton_cap", "value": 5},
	],
	"utility": [
		{"name": "Unlock Mass Raise", "effect": "unlock_mass_raise", "value": 1},
		{"name": "Start Next Wave with 3 Skeletons", "effect": "free_skeletons", "value": 3},
		{"name": "Crypt Heart Shield (100 HP)", "effect": "heart_shield", "value": 100},
		{"name": "Learn Random Spell", "effect": "learn_spell", "value": 1},
		{"name": "Corpses Drop 2x Souls", "effect": "soul_drop", "value": 2.0},
	],
}

const SHOP_CHOICE_TIME: float = 15.0  # seconds to pick


## ============================================================================
## PROGRESSION: META UPGRADES (Between-Run, Permanent)
## ============================================================================
## Design: Capped progression (max rank 3) to avoid trivializing content
## Later progression = more OPTIONS, not more POWER

const META_UPGRADES = {
	"skeleton_damage": {
		"name": "Skeleton Damage",
		"costs": [200, 400, 800],      # Rank 1, 2, 3
		"effects": [0.15, 0.30, 0.45], # Cumulative: +45% at max
	},
	"player_max_hp": {
		"name": "Your Max HP",
		"costs": [150, 300, 600],
		"effects": [0.30, 0.60, 0.90], # 100 -> 190 HP
	},
	"soul_gain": {
		"name": "Soul Gain",
		"costs": [250, 500, 1000],
		"effects": [0.20, 0.40, 0.60], # +60% souls from kills
	},
	"raise_speed": {
		"name": "Raise Speed",
		"costs": [200, 400, 800],
		"effects": [0.30, 0.60, 0.90], # Raise corpses 90% faster
	},
	"start_skeletons": {
		"name": "Starting Skeletons",
		"costs": [500, 1000, 2000],
		"effects": [3, 6, 9], # Start with free skeletons
	},
}

## Spell unlocks (permanent)
const SPELL_UNLOCKS = {
	"bone_barrier": {"cost": 600, "description": "Shield absorbs damage"},
	"soul_drain": {"cost": 800, "description": "Lifesteal AOE"},
	"mass_raise": {"cost": 1000, "description": "Raise 5 corpses permanently"},
	"death_mark": {"cost": 1200, "description": "Next kill = powerful corpse"},
	"skeletal_swarm": {"cost": 1500, "description": "Summon 3 temp skeletons"},
}


## ============================================================================
## ECONOMY: GOLD PAYOUTS
## ============================================================================
## Design: Even bad runs give progress. Better runs = faster progression.
## Target: ~10-12 runs to unlock core power upgrades

const GOLD_PAYOUTS: Array = [
	50,    # Die Wave 1 (4% of max)
	150,   # Die Wave 2 (12% of max)
	350,   # Die Wave 3 (29% of max)
	600,   # Die Wave 4 (50% of max)
	900,   # Die Wave 5 (75% of max)
	1200,  # Survive to Dawn (100%)
]

## Progression milestones (playtesting targets):
## - Runs 1-5: Buy core power (200-800g each)
## - Runs 6-15: Unlock skeleton types (800-2000g)
## - Runs 16-25: Unlock spells (600-1500g)
## - Runs 26+: Cosmetics, mastery


## ============================================================================
## TUNING KNOBS (For Rapid Iteration)
## ============================================================================
## Expose these as global multipliers to tune without touching individual values

var gold_multiplier: float = 1.0       ## Scale all gold payouts
var upgrade_price_scale: float = 1.0   ## Scale all upgrade costs
var enemy_hp_scale: float = 1.0        ## Scale all enemy HP
var enemy_damage_scale: float = 1.0    ## Scale all enemy damage
var wave_spawn_rate: float = 1.0       ## Enemies per second multiplier
var skeleton_damage_base: float = 1.0  ## Global skeleton damage multiplier


## ============================================================================
## PLAYTEST SUCCESS CRITERIA
## ============================================================================
## Use these to validate balance during development:
##
## RUN 1 EXPECTATIONS:
## - Skilled player reaching Dawn = Very hard but possible (< 5% success)
## - Average player reaching Wave 3 = 50%+ success rate
## - No player should feel stuck at Wave 1 after 3 attempts
##
## ECONOMY VALIDATION:
## - 10-12 runs to unlock all rank 1 power upgrades
## - 20-25 runs to unlock all skeleton types
## - 30-40 runs to "complete" core progression
##
## DIFFICULTY CURVE:
## - Each wave should feel noticeably harder than previous
## - Wave 5 should feel overwhelming even with good builds
## - Meta progression should enable new strategies, not trivialize waves
