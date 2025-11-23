extends Node
## Telemetry System - Logs game events for AI-assisted balancing
##
## Captures critical gameplay metrics to help tune game balance.
## Events are logged to console and can be exported for analysis.


## ============================================================================
## EVENT LOGGING
## ============================================================================

## Log a game event with up to 4 numeric values and 2 string details
## Format: event(name, entity, detail1, detail2, num1, num2, num3, num4)
##
## Examples:
## - Telemetry.event("skeleton_raised", "warrior", "", "", total_count, corpses_available, 0, 0)
## - Telemetry.event("heart_damaged", "", "", "", current_hp, damage_taken, 0, 0)
## - Telemetry.event("wave_complete", "", "", "", wave_num, kills, time_sec, 0)
func event(
	event_name: String,
	entity: String = "",
	detail1: String = "",
	detail2: String = "",
	num1: float = 0.0,
	num2: float = 0.0,
	num3: float = 0.0,
	num4: float = 0.0
) -> void:
	var timestamp := Time.get_ticks_msec()
	var log_entry := "[TELEMETRY] %d | %s | %s | %s | %s | %.2f | %.2f | %.2f | %.2f" % [
		timestamp,
		event_name,
		entity,
		detail1,
		detail2,
		num1,
		num2,
		num3,
		num4
	]
	print(log_entry)

	# TODO: Write to file for analysis
	# TODO: Send to analytics backend (if online features added)


## ============================================================================
## CONVENIENCE METHODS
## ============================================================================

func run_started() -> void:
	event("run_started", "", "", "", 0, 0, 0, 0)


func run_ended(outcome: String, gold_earned: int, wave_reached: int) -> void:
	event("run_ended", outcome, "", "", gold_earned, wave_reached, 0, 0)


func wave_started(wave_num: int) -> void:
	event("wave_started", "", "", "", wave_num, 0, 0, 0)


func wave_completed(wave_num: int, kills: int, time_sec: float) -> void:
	event("wave_completed", "", "", "", wave_num, kills, time_sec, 0)


func enemy_killed(enemy_type: String) -> void:
	event("enemy_killed", enemy_type, "", "", 0, 0, 0, 0)


func skeleton_raised(skeleton_type: String, total_count: int) -> void:
	event("skeleton_raised", skeleton_type, "", "", total_count, 0, 0, 0)


func player_damaged(current_hp: int, damage_taken: int) -> void:
	event("player_damaged", "", "", "", current_hp, damage_taken, 0, 0)


func heart_damaged(current_hp: int, damage_taken: int) -> void:
	event("heart_damaged", "", "", "", current_hp, damage_taken, 0, 0)


func heart_destroyed() -> void:
	event("heart_destroyed", "", "", "", 0, 0, 0, 0)
