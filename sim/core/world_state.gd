class_name WorldState
extends RefCounted
## State data murni untuk seluruh dunia simulasi.
## Tidak boleh mengimpor Node atau referensi view/.

var tick: int = 0
var seed_value: int = 0
var agents: Array[AgentState] = []
var granary_food: float = 0.0
var grid: Dictionary = {}
var day_phase: StringName = &"day"


func get_agent(agent_id: StringName) -> AgentState:
	for agent: AgentState in agents:
		if agent.id == agent_id:
			return agent
	return null


func to_dict() -> Dictionary:
	var agent_dicts: Array[Dictionary] = []
	for agent: AgentState in agents:
		agent_dicts.append(agent.to_dict())

	var sorted_keys: Array = grid.keys()
	sorted_keys.sort()
	var sorted_grid: Dictionary = {}
	for key: Variant in sorted_keys:
		sorted_grid[key] = grid[key]

	return {
		"tick": tick,
		"seed_value": seed_value,
		"agents": agent_dicts,
		"granary_food": granary_food,
		"grid": sorted_grid,
		"day_phase": String(day_phase),
	}
