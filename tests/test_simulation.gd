extends GutTest


func test_simulation_step_increments_tick() -> void:
	var config: Dictionary = _make_config()
	var sim: Simulation = Simulation.new(config)
	assert_eq(sim.world.tick, 0)
	sim.step()
	assert_eq(sim.world.tick, 1)


func test_simulation_creates_agents() -> void:
	var config: Dictionary = _make_config()
	var sim: Simulation = Simulation.new(config)
	assert_eq(sim.world.agents.size(), 3)


func test_simulation_agents_sorted() -> void:
	var config: Dictionary = _make_config()
	var sim: Simulation = Simulation.new(config)
	var ids: Array[StringName] = sim.world.sorted_agent_ids()
	for i: int in range(ids.size() - 1):
		assert_true(String(ids[i]) < String(ids[i + 1]))


func test_simulation_seed_stored() -> void:
	var config: Dictionary = _make_config()
	config["seed"] = 99
	var sim: Simulation = Simulation.new(config)
	assert_eq(sim.world.seed_value, 99)


func test_needs_decay_after_steps() -> void:
	var config: Dictionary = _make_config()
	var sim: Simulation = Simulation.new(config)
	sim.step()
	sim.step()
	sim.step()
	for agent: AgentState in sim.world.agents:
		assert_lt(agent.needs[&"hunger"], 100.0)
		assert_lt(agent.needs[&"energy"], 100.0)


func _make_config() -> Dictionary:
	return {
		"seed": 42,
		"agent_count": 3,
		"granary_food": 20,
		"grid":
		{
			"width": 4,
			"height": 4,
			"tiles":
			[
				["grass", "grass", "grass", "grass"],
				["grass", "house", "grass", "granary"],
				["grass", "grass", "farm", "grass"],
				["grass", "grass", "grass", "grass"],
			],
		},
		"agent_spawn_positions": [[0, 0], [1, 0], [2, 0]],
	}
