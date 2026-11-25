extends GutTest
## Invariant checker v2: aturan ketat yang tidak boleh dilanggar setelah setiap tick.


func test_needs_in_range_after_many_ticks() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(100):
		sim.step()
		_check_invariants(sim)


func test_health_in_range() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(100):
		sim.step()
		for agent: AgentState in sim.world.agents:
			assert_gte(agent.health, 0.0, "Health >= 0")
			assert_lte(agent.health, 100.0, "Health <= 100")


func test_granary_food_non_negative() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(100):
		sim.step()
		assert_gte(sim.world.granary_food, 0, "Granary food >= 0")


func test_food_conservation_holds_always() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(200):
		sim.step()
		assert_true(sim.world.is_food_conserved(), "Konservasi makanan harus selalu valid")


func test_living_agents_on_walkable_tile() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(100):
		sim.step()
		for agent: AgentState in sim.world.agents:
			if agent.alive:
				assert_true(
					sim.world.grid_data.is_in_bounds(agent.position), "Agent harus dalam batas peta"
				)
				assert_true(
					sim.world.grid_data.is_walkable(agent.position), "Agent harus di tile walkable"
				)


func test_dead_agent_no_action_and_empty_path() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(500):
		sim.step()
	for agent: AgentState in sim.world.agents:
		if not agent.alive:
			assert_null(agent.current_action, "Dead agent has no action")
			assert_true(agent.path.is_empty(), "Dead agent has empty path")


func test_death_event_has_cause() -> void:
	var sim: Simulation = _make_sim()
	for i: int in range(500):
		sim.step()
	for event: Dictionary in sim.events:
		if event.get("event_type", "") == "agent_died":
			assert_true(event.has("cause"), "agent_died must have cause")


func _check_invariants(sim: Simulation) -> void:
	assert_true(sim.world.is_food_conserved(), "Konservasi makanan terjaga")
	for agent: AgentState in sim.world.agents:
		if not agent.alive:
			continue
		assert_gte(agent.needs[&"hunger"], 0.0, "Hunger >= 0")
		assert_lte(agent.needs[&"hunger"], 100.0, "Hunger <= 100")
		assert_gte(agent.needs[&"energy"], 0.0, "Energy >= 0")
		assert_lte(agent.needs[&"energy"], 100.0, "Energy <= 100")
		assert_gte(agent.health, 0.0, "Health >= 0")
		assert_lte(agent.health, 100.0, "Health <= 100")


func _make_sim() -> Simulation:
	return (
		Simulation
		. new(
			{
				"seed": 42,
				"agent_count": 3,
				"granary_food": 20,
				"grid":
				{
					"width": 8,
					"height": 6,
					"tiles":
					[
						["grass", "grass", "grass", "grass", "grass", "grass", "grass", "grass"],
						["grass", "house", "grass", "grass", "grass", "grass", "grass", "grass"],
						["grass", "grass", "grass", "granary", "grass", "grass", "grass", "grass"],
						["grass", "grass", "grass", "grass", "grass", "farm", "farm", "grass"],
						["grass", "grass", "grass", "grass", "grass", "farm", "grass", "grass"],
						["grass", "grass", "grass", "grass", "grass", "grass", "grass", "grass"],
					],
				},
				"agent_spawn_positions": [[1, 1], [2, 1], [3, 1]],
			}
		)
	)
