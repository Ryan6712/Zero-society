class_name WorldObject
extends RefCounted
## Objek dunia interaktif dengan kapasitas dan pelacakan okupansi agent.

var id: StringName = &""
var object_type: StringName = &""
var position: Vector2i = Vector2i.ZERO
var capacity: int = 1
var current_occupants: Array[StringName] = []


func _init(
	p_id: StringName = &"",
	p_type: StringName = &"",
	p_pos: Vector2i = Vector2i.ZERO,
	p_capacity: int = 1
) -> void:
	id = p_id
	object_type = p_type
	position = p_pos
	capacity = p_capacity


func is_available() -> bool:
	return current_occupants.size() < capacity


func occupy(agent_id: StringName) -> bool:
	if not is_available():
		return false
	if not current_occupants.has(agent_id):
		current_occupants.append(agent_id)
		current_occupants.sort_custom(
			func(a: StringName, b: StringName) -> bool: return String(a) < String(b)
		)
	return true


func release(agent_id: StringName) -> void:
	current_occupants.erase(agent_id)


func to_dict() -> Dictionary:
	var occupants_str: Array[String] = []
	for occ: StringName in current_occupants:
		occupants_str.append(String(occ))
	return {
		"id": String(id),
		"object_type": String(object_type),
		"position": [position.x, position.y],
		"capacity": capacity,
		"current_occupants": occupants_str,
	}
