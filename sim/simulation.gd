class_name Simulation
extends RefCounted
## Orkestrator simulasi. Menjalankan step() per tick.

var world: WorldState
var rng: RandomNumberGenerator
var events: Array[Dictionary] = []


func _init(config: Dictionary) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = config.get("seed", 42)

	world = WorldState.new()
	world.seed_value = rng.seed
	world.granary_food = config.get("granary_food", SimConst.INITIAL_GRANARY_FOOD)
	world.initial_granary_food = world.granary_food

	var grid_dict: Dictionary = config.get("grid", {})
	if grid_dict.size() > 0:
		world.grid_data = GridData.from_dict(grid_dict)

	var spawn_positions: Array = config.get("agent_spawn_positions", [])
	var agent_count: int = config.get("agent_count", SimConst.DEFAULT_AGENT_COUNT)
	for i: int in range(agent_count):
		var agent: AgentState = AgentState.new()
		agent.id = StringName("agent_%03d" % i)
		agent.display_name = "Agent %d" % i
		if i < spawn_positions.size():
			var sp: Array = spawn_positions[i]
			agent.position = Vector2i(sp[0], sp[1])
		agent.home_tile = agent.position
		world.agents.append(agent)


func step() -> void:
	world.tick += 1
	WorldSystem.update(world, rng)
	NeedsSystem.update(world, events)
	for aid: StringName in world.sorted_agent_ids():
		var agent: AgentState = world.get_agent(aid)
		if not agent.alive:
			continue
		ActionSystem.update(agent, world, rng, events)


func compute_hash() -> String:
	var data: Dictionary = world.to_dict()
	data["rng_state"] = str(rng.state)
	return JSON.stringify(data, "", true, true).sha256_text()


static func from_json_file(path: String) -> Simulation:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Cannot open config: %s" % path)
		return null
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("JSON parse error: %s" % json.get_error_message())
		return null
	return Simulation.new(json.data)
