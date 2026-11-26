extends GutTest
## Phase 0 Scenario A — Basic Survival
## Memastikan NPC dapat mengelola Hunger dan Energy secara mandiri.


func test_scenario_a_basic_survival() -> void:
	var config: Dictionary = {
		"seed": 42,
		"agent_count": 1,
		"granary_food": 20,
		"grid":
		{
			"width": 6,
			"height": 6,
			"tiles":
			[
				["grass", "grass", "farm", "grass", "grass", "grass"],
				["grass", "house", "grass", "granary", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
			],
		},
		"agent_spawn_positions": [[0, 0]],
	}

	var sim: Simulation = Simulation.new(config)
	var agent: AgentState = sim.world.agents[0]

	# Simulasikan selama 2 hari (288 tick)
	for t: int in range(288):
		sim.step()
		assert_true(agent.alive, "Agent harus tetap hidup dengan mengelola kebutuhan")
		assert_gte(agent.needs[&"hunger"], 0.0)
		assert_gte(agent.needs[&"energy"], 0.0)
		assert_true(sim.world.is_food_conserved())

	# Verifikasi agent pernah makan dan pernah tidur
	var ate: bool = false
	var slept: bool = false
	for event: Dictionary in sim.events:
		if event.get("event_type") == "action_completed":
			if event.get("action_id") == "eat":
				ate = true
			elif event.get("action_id") == "sleep":
				slept = true

	assert_true(ate, "Agent harus pernah makan selama 2 hari simulasi")
	assert_true(slept, "Agent harus pernah tidur selama 2 hari simulasi")
