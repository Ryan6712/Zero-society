class_name AgentState
extends RefCounted
## State data murni untuk satu agent.
## Tidak boleh mengimpor Node atau referensi view/.

var id: StringName
var display_name: String = ""
var position: Vector2i
var home_tile: Vector2i
var alive: bool = true

var needs: Dictionary = {
	&"hunger": 100.0,
	&"energy": 100.0,
}

var health: float = 100.0
var starving_ticks: int = 0

var personality: Dictionary = {
	&"conscientiousness": 50,
	&"risk_tolerance": 50,
}

var current_action: ActionInstance = null
var path: Array[Vector2i] = []
var inventory: Dictionary = {&"food": 0}
var last_decision_trace: Array[Dictionary] = []


func _init(p_id: StringName = &"", p_position: Vector2i = Vector2i.ZERO) -> void:
	id = p_id
	position = p_position
	home_tile = p_position


func to_dict() -> Dictionary:
	var need_keys: Array = needs.keys()
	need_keys.sort()
	var sorted_needs: Dictionary = {}
	for key: Variant in need_keys:
		sorted_needs[key] = needs[key]

	var inv_keys: Array = inventory.keys()
	inv_keys.sort()
	var sorted_inv: Dictionary = {}
	for key: Variant in inv_keys:
		sorted_inv[key] = inventory[key]

	return {
		"id": String(id),
		"display_name": display_name,
		"position": [position.x, position.y],
		"home_tile": [home_tile.x, home_tile.y],
		"alive": alive,
		"needs": sorted_needs,
		"health": health,
		"starving_ticks": starving_ticks,
		"current_action": current_action.to_dict() if current_action else {},
		"path": path,
		"inventory": sorted_inv,
		"last_decision_trace": last_decision_trace.duplicate(),
	}


func compute_hash() -> String:
	return JSON.stringify(to_dict()).sha256_text()
