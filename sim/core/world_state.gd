class_name WorldState
extends RefCounted
## State data murni untuk seluruh dunia simulasi.
## Tidak boleh mengimpor Node atau referensi view/.

var tick: int = 0
var seed_value: int = 0
var agents: Array[AgentState] = []
var granary_food: float = 0.0
var grid_data: GridData = null
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


func to_dict() -> Dictionary:
	var agent_dicts: Array[Dictionary] = []
	for aid: StringName in sorted_agent_ids():
		var agent: AgentState = get_agent(aid)
		agent_dicts.append(agent.to_dict())

	return {
		"tick": tick,
		"seed_value": seed_value,
		"agents": agent_dicts,
		"granary_food": granary_food,
		"day_phase": String(day_phase),
		"next_event_id": next_event_id,
	}


func compute_hash() -> String:
	return JSON.stringify(to_dict()).sha256_text()
