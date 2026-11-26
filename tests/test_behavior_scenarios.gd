extends GutTest
## Skenario perilaku otonom deterministik (lapar, malam, stok habis, pengaruh kepribadian).

var _sim: Simulation
var _world: WorldState
var _agent: AgentState


func before_each() -> void:
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

	_sim = Simulation.new(config)
	_world = _sim.world
	_agent = _world.agents[0]


func test_hungry_agent_autonomously_seeks_food_and_eats() -> void:
	_agent.needs[&"hunger"] = 25.0
	_agent.needs[&"energy"] = 90.0

	var ate_food: bool = false
	for t: int in range(25):
		_sim.step()
		if _agent.needs[&"hunger"] > 50.0:
			ate_food = true
			break

	assert_true(ate_food, "Agent lapar harus otomatis bergerak ke lumbung dan makan")
	assert_true(_world.is_food_conserved())


func test_tired_agent_at_night_sleeps() -> void:
	_world.tick = 0  # Malam hari
	_agent.needs[&"energy"] = 20.0
	_agent.needs[&"hunger"] = 90.0

	var slept: bool = false
	for t: int in range(25):
		_sim.step()
		if _agent.needs[&"energy"] > 35.0:
			slept = true
			break

	assert_true(slept, "Agent lelah di malam hari harus otomatis pulang dan tidur")


func test_depleted_stock_diverts_agent_to_work_farm() -> void:
	_world.granary_food = 0
	_world.initial_granary_food = 0
	_agent.needs[&"hunger"] = 40.0
	_agent.needs[&"energy"] = 90.0

	for t: int in range(25):
		_sim.step()
		if _world.granary_food > 0:
			break

	assert_gt(_world.granary_food, 0, "Agent harus bekerja di ladang saat stok lumbung 0")
	assert_true(_world.is_food_conserved())


func test_personality_impacts_work_decision() -> void:
	var lazy_config: Dictionary = {
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
		"agent_spawn_positions": [[2, 0]],
	}
	var sim_lazy: Simulation = Simulation.new(lazy_config)
	sim_lazy.world.agents[0].set_trait(&"conscientiousness", 10)
	sim_lazy.world.agents[0].needs[&"energy"] = 70.0
	sim_lazy.world.agents[0].needs[&"hunger"] = 70.0

	var hard_config: Dictionary = lazy_config.duplicate(true)
	var sim_hard: Simulation = Simulation.new(hard_config)
	sim_hard.world.agents[0].set_trait(&"conscientiousness", 95)
	sim_hard.world.agents[0].needs[&"energy"] = 70.0
	sim_hard.world.agents[0].needs[&"hunger"] = 70.0

	var d_lazy: Dictionary = UtilityBrain.choose(
		sim_lazy.world.agents[0], sim_lazy.world, sim_lazy.rng
	)
	var d_hard: Dictionary = UtilityBrain.choose(
		sim_hard.world.agents[0], sim_hard.world, sim_hard.rng
	)

	var lazy_score: float = 0.0
	for item: Dictionary in d_lazy["trace"]:
		if item["id"] == "work_farm":
			lazy_score = item["score"]

	var hard_score: float = 0.0
	for item: Dictionary in d_hard["trace"]:
		if item["id"] == "work_farm":
			hard_score = item["score"]

	assert_gt(
		hard_score,
		lazy_score,
		"Conscientiousness tinggi harus menghasilkan skor kerja lebih tinggi"
	)
