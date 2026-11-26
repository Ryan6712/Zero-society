extends GutTest
## Phase 0 Scenario B — Resource Scarcity
## Memastikan NPC merespons keterbatasan resource (stok habis -> kerja / alternatif).


func test_scenario_b_resource_scarcity() -> void:
	var config: Dictionary = {
		"seed": 42,
		"agent_count": 2,
		"granary_food": 0,
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
		"agent_spawn_positions": [[0, 0], [1, 0]],
	}

	var sim: Simulation = Simulation.new(config)

	# Beri rasa lapar awal
	sim.world.agents[0].needs[&"hunger"] = 40.0
	sim.world.agents[1].needs[&"hunger"] = 40.0

	# Ketika stok 0, agent tidak boleh bisa makan; mereka harus mencari alternatif (bekerja di ladang)
	for t: int in range(60):
		sim.step()
		assert_gte(sim.world.granary_food, 0)
		assert_true(sim.world.is_food_conserved())

	# Makanan berhasil diproduksi karena agent teralihkan bekerja di ladang
	assert_gt(sim.world.total_food_produced, 0, "Agent harus menghasilkan makanan saat krisis")
