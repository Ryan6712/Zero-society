class_name WorldState
extends RefCounted
## State data murni untuk seluruh dunia simulasi.
## Tidak boleh mengimpor Node atau referensi view/.

var tick: int = 0
var seed_value: int = 0
var agents: Array[AgentState] = []
var granary_food: int = 0
var granary_capacity: int = SimConst.DEFAULT_GRANARY_CAPACITY
var initial_granary_food: int = 0
var total_food_produced: int = 0
var total_food_consumed: int = 0
var grid_data: GridData = null
var world_objects: Dictionary = {}
var day_phase: StringName = &"day"
var next_event_id: int = 0


func get_agent(agent_id: StringName) -> AgentState:
	for agent: AgentState in agents:
		if agent.id == agent_id:
			return agent
	return null


func sorted_agent_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for agent: AgentState in agents:
		ids.append(agent.id)
	ids.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return ids


func hour_of_day() -> float:
	return float(tick % SimConst.TICKS_PER_DAY) / SimConst.TICKS_PER_DAY * 24.0


func is_night() -> bool:
	var h: float = hour_of_day()
	return h >= SimConst.NIGHT_START_HOUR or h < SimConst.DAWN_START_HOUR


func register_world_object(obj: WorldObject) -> void:
	world_objects[obj.position] = obj


func get_object_at(pos: Vector2i) -> WorldObject:
	return world_objects.get(pos, null)


func get_available_objects_of_type(type: StringName) -> Array[WorldObject]:
	var result: Array[WorldObject] = []
	var sorted_positions: Array = world_objects.keys()
	sorted_positions.sort()
	for pos: Variant in sorted_positions:
		var obj: WorldObject = world_objects[pos]
		if obj.object_type == type and obj.is_available():
			result.append(obj)
	return result


func modify_granary_food(
	delta: int, reason: StringName, agent_id: StringName = &"system", events: Array[Dictionary] = []
) -> bool:
	if delta < 0 and granary_food + delta < 0:
		return false
	if delta > 0 and granary_food + delta > granary_capacity:
		return false

	granary_food += delta

	if delta > 0:
		total_food_produced += delta
		_emit_food_event(events, EventSchema.EventType.FOOD_PRODUCED, delta, reason, agent_id)
	elif delta < 0:
		var consumed: int = abs(delta)
		total_food_consumed += consumed
		_emit_food_event(events, EventSchema.EventType.FOOD_CONSUMED, consumed, reason, agent_id)

	return true


func is_food_conserved() -> bool:
	return (initial_granary_food + total_food_produced - total_food_consumed) == granary_food


func _emit_food_event(
	events: Array[Dictionary],
	event_type: EventSchema.EventType,
	amount: int,
	reason: StringName,
	agent_id: StringName
) -> void:
	next_event_id += 1
	var event: Dictionary = {
		"id": next_event_id,
		"tick": tick,
		"event_type": EventSchema.EVENT_TYPE_NAMES[event_type],
		"agent_id": String(agent_id),
		"amount": amount,
		"reason": String(reason),
		"granary_food": granary_food,
	}
	events.append(event)


func to_dict() -> Dictionary:
	var agent_dicts: Array[Dictionary] = []
	for aid: StringName in sorted_agent_ids():
		var agent: AgentState = get_agent(aid)
		agent_dicts.append(agent.to_dict())

	var obj_dicts: Array[Dictionary] = []
	var sorted_positions: Array = world_objects.keys()
	sorted_positions.sort()
	for pos: Variant in sorted_positions:
		var obj: WorldObject = world_objects[pos]
		obj_dicts.append(obj.to_dict())

	return {
		"tick": tick,
		"agents": agent_dicts,
		"world_objects": obj_dicts,
		"granary_food": granary_food,
		"granary_capacity": granary_capacity,
		"initial_granary_food": initial_granary_food,
		"total_food_produced": total_food_produced,
		"total_food_consumed": total_food_consumed,
		"day_phase": String(day_phase),
		"next_event_id": next_event_id,
	}


func compute_hash() -> String:
	return JSON.stringify(to_dict(), "", true, true).sha256_text()
