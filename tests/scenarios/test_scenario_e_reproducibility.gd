extends GutTest
## Phase 0 Scenario E — Reproducibility
## Memastikan seed sama menghasilkan keputusan dan event identik 100%.


func test_scenario_e_reproducibility() -> void:
	var config: Dictionary = {
		"seed": 1337,
		"agent_count": 3,
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
		"agent_spawn_positions": [[0, 0], [1, 0], [0, 1]],
		"agent_personalities":
		[
			{"industrious": 80, "cautious": 40},
			{"industrious": 40, "cautious": 70},
			{"adventurous": 90, "lazy": 60},
		],
	}

	var sim1: Simulation = Simulation.new(config.duplicate(true))
	for t: int in range(200):
		sim1.step()
	var hash1: String = sim1.compute_hash()

	var sim2: Simulation = Simulation.new(config.duplicate(true))
	for t: int in range(200):
		sim2.step()
	var hash2: String = sim2.compute_hash()

	assert_eq(hash1, hash2, "Seed identik harus menghasilkan state hash identik")
	assert_eq(sim1.world.granary_food, sim2.world.granary_food)
	assert_eq(sim1.events.size(), sim2.events.size())
