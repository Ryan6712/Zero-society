class_name Simulation
extends RefCounted
## Orkestrator simulasi. Menjalankan step() per tick.

const MAX_MEMORY_EVENTS: int = 1000

var world: WorldState
var rng: RandomNumberGenerator
var events: Array[Dictionary] = []
var log_file: FileAccess = null
var _command_queue: Array[Command] = []


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
		_register_default_world_objects()

	var spawn_positions: Array = config.get("agent_spawn_positions", [])
	var personalities: Array = config.get("agent_personalities", [])
	var agent_count: int = config.get("agent_count", SimConst.DEFAULT_AGENT_COUNT)
	for i: int in range(agent_count):
		var agent: AgentState = AgentState.new()
		agent.id = StringName("agent_%03d" % i)
		agent.display_name = "Agent %d" % i
		if i < spawn_positions.size():
			var sp: Array = spawn_positions[i]
			agent.position = Vector2i(sp[0], sp[1])
		agent.home_tile = agent.position
		if i < personalities.size():
			var p: Dictionary = personalities[i]
			for key: String in p:
				agent.set_trait(StringName(key), int(p[key]))
		world.agents.append(agent)


func _register_default_world_objects() -> void:
	if world.grid_data == null:
		return
	for pos: Vector2i in world.grid_data.tiles:
		var tile_type: StringName = world.grid_data.tiles[pos]
		match tile_type:
			GridData.TILE_HOUSE:
				var obj: WorldObject = WorldObject.new(
					StringName("bed_%d_%d" % [pos.x, pos.y]), GridData.TILE_HOUSE, pos, 1
				)
				world.register_world_object(obj)
			GridData.TILE_FARM:
				var obj: WorldObject = WorldObject.new(
					StringName("farm_%d_%d" % [pos.x, pos.y]), GridData.TILE_FARM, pos, 2
				)
				world.register_world_object(obj)
			GridData.TILE_GRANARY:
				var obj: WorldObject = WorldObject.new(
					StringName("granary_%d_%d" % [pos.x, pos.y]), GridData.TILE_GRANARY, pos, 99
				)
				world.register_world_object(obj)


func step() -> void:
	_process_commands()
	world.tick += 1
	WorldSystem.update(world, rng)
	NeedsSystem.update(world, events)
	for aid: StringName in world.sorted_agent_ids():
		var agent: AgentState = world.get_agent(aid)
		if not agent.alive:
			continue
		UtilityBrain.decide_and_act(agent, world, rng, events)
		ActionSystem.update(agent, world, rng, events)

	_flush_and_trim_events()


func set_log_file(path: String) -> bool:
	log_file = FileAccess.open(path, FileAccess.WRITE)
	if not log_file:
		push_error("Gagal membuka file log: %s" % path)
		return false
	return true


func close_log_file() -> void:
	if log_file != null:
		log_file.close()
		log_file = null


func _flush_and_trim_events() -> void:
	if log_file != null:
		for event: Dictionary in events:
			log_file.store_line(JSON.stringify(event))
			log_file.flush()
		events.clear()
	elif events.size() > MAX_MEMORY_EVENTS:
		events = events.slice(events.size() - MAX_MEMORY_EVENTS)


func enqueue_command(cmd: Command) -> void:
	if cmd != null:
		_command_queue.append(cmd)


func _process_commands() -> void:
	while not _command_queue.is_empty():
		var cmd: Command = _command_queue.pop_front()
		cmd.execute(world, events)


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
