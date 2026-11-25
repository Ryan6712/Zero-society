class_name ActionInstance
extends RefCounted
## Data aksi yang sedang berjalan pada satu agent.

var def: ActionDef
var ticks_left: int
var target_tile: Vector2i
var started_tick: int


func _init(p_def: ActionDef = null, p_started_tick: int = 0) -> void:
	def = p_def
	if p_def:
		ticks_left = p_def.duration_ticks
	started_tick = p_started_tick


func to_dict() -> Dictionary:
	return {
		"action_id": String(def.id) if def else "",
		"ticks_left": ticks_left,
		"target_tile": [target_tile.x, target_tile.y],
		"started_tick": started_tick,
	}
