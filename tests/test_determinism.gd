extends GutTest
## Tes determinism: seed sama → hash identik, seed beda → hash beda.


func test_same_seed_same_hash() -> void:
	var h1: String = _run_sim(42, 1000)
	var h2: String = _run_sim(42, 1000)
	assert_eq(h1, h2, "Seed sama harus menghasilkan hash identik")


func test_different_seed_different_hash() -> void:
	var h1: String = _run_sim(42, 1000)
	var h2: String = _run_sim(99, 1000)
	assert_ne(h1, h2, "Seed beda harus menghasilkan hash berbeda")


func test_third_seed_different_hash() -> void:
	var h1: String = _run_sim(42, 1000)
	var h3: String = _run_sim(1337, 1000)
	assert_ne(h1, h3, "Seed 1337 harus menghasilkan hash berbeda")


func _run_sim(seed_val: int, ticks: int) -> String:
	var config: Dictionary = {
		"seed": seed_val,
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
	var sim: Simulation = Simulation.new(config)
	for i: int in range(ticks):
		sim.step()
	return sim.compute_hash()
