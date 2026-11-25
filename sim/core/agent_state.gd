class_name AgentState
extends RefCounted
## State data murni untuk satu agent.
## Tidak boleh mengimpor Node atau referensi view/.

var id: StringName
var position: Vector2i
var alive: bool = true

var needs: Dictionary = {
	&"hunger": 100.0,
	&"energy": 100.0,
	&"health": 100.0,
}

var current_action: StringName = &""
var inventory: Dictionary = {}


func _init(p_id: StringName = &"", p_position: Vector2i = Vector2i.ZERO) -> void:
	id = p_id
	position = p_position


func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"position": [position.x, position.y],
		"alive": alive,
		"needs": needs.duplicate(),
		"current_action": String(current_action),
		"inventory": inventory.duplicate(),
	}
