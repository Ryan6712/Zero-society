extends GutTest
## Phase 0 Scenario D — Personality Variation
## Memastikan perbedaan trait kepribadian menghasilkan perbedaan keputusan.


func test_scenario_d_personality_variation() -> void:
	var config: Dictionary = {
		"seed": 42,
		"agent_count": 2,
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
		"agent_spawn_positions": [[0, 0], [0, 0]],
		"agent_personalities":
		[
			{"industrious": 95, "adventurous": 10},
			{"industrious": 10, "adventurous": 95},
		],
	}

	var sim: Simulation = Simulation.new(config)
	var industrious_agent: AgentState = sim.world.agents[0]
	var adventurous_agent: AgentState = sim.world.agents[1]

	# Kedua agent pada kondisi kebutuhan kenyang dan berenergi
	industrious_agent.needs[&"hunger"] = 90.0
	industrious_agent.needs[&"energy"] = 90.0
	adventurous_agent.needs[&"hunger"] = 90.0
	adventurous_agent.needs[&"energy"] = 90.0

	var d1: Dictionary = UtilityBrain.choose(industrious_agent, sim.world, sim.rng)
	var d2: Dictionary = UtilityBrain.choose(adventurous_agent, sim.world, sim.rng)

	assert_eq(d1["best_id"], ActionLibrary.ID_WORK_FARM, "Industrious agent memilih work_farm")
	assert_eq(d2["best_id"], ActionLibrary.ID_WANDER, "Adventurous agent memilih wander")
