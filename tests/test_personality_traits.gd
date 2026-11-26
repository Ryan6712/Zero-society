extends GutTest
## Tes unit untuk 4 trait kepribadian (industrious, lazy, cautious, adventurous).

var _world: WorldState
var _rng: RandomNumberGenerator


func before_each() -> void:
	_world = WorldState.new()
	_world.granary_food = 20
	_world.granary_capacity = 100

	var grid_dict: Dictionary = {
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
	}
	_world.grid_data = GridData.from_dict(grid_dict)

	_rng = RandomNumberGenerator.new()
	_rng.seed = 42


func test_industrious_vs_lazy_work_preference() -> void:
	var hard: AgentState = AgentState.new(&"hard", Vector2i(2, 0))
	hard.set_trait(&"industrious", 90)
	hard.needs[&"energy"] = 80.0
	hard.needs[&"hunger"] = 80.0

	var lazy: AgentState = AgentState.new(&"lazy", Vector2i(2, 0))
	lazy.set_trait(&"lazy", 90)
	lazy.needs[&"energy"] = 80.0
	lazy.needs[&"hunger"] = 80.0

	var d_hard: Dictionary = UtilityBrain.choose(hard, _world, _rng)
	var d_lazy: Dictionary = UtilityBrain.choose(lazy, _world, _rng)

	var hard_work: float = _get_score(d_hard, "work_farm")
	var lazy_work: float = _get_score(d_lazy, "work_farm")

	assert_gt(
		hard_work, lazy_work, "Industrious agent harus memiliki skor kerja lebih tinggi dari lazy"
	)


func test_adventurous_trait_favors_wander() -> void:
	var adv: AgentState = AgentState.new(&"adv", Vector2i(0, 0))
	adv.set_trait(&"adventurous", 95)
	adv.needs[&"energy"] = 90.0
	adv.needs[&"hunger"] = 90.0

	var timid: AgentState = AgentState.new(&"timid", Vector2i(0, 0))
	timid.set_trait(&"adventurous", 10)
	timid.needs[&"energy"] = 90.0
	timid.needs[&"hunger"] = 90.0

	var d_adv: Dictionary = UtilityBrain.choose(adv, _world, _rng)
	var d_timid: Dictionary = UtilityBrain.choose(timid, _world, _rng)

	var adv_wander: float = _get_score(d_adv, "wander")
	var timid_wander: float = _get_score(d_timid, "wander")

	assert_gt(adv_wander, timid_wander, "Adventurous agent harus lebih tertarik wander")


func test_cautious_agent_eats_sooner() -> void:
	var cautious: AgentState = AgentState.new(&"cautious", Vector2i(3, 1))
	cautious.set_trait(&"cautious", 90)
	cautious.needs[&"hunger"] = 60.0

	var reckless: AgentState = AgentState.new(&"reckless", Vector2i(3, 1))
	reckless.set_trait(&"cautious", 10)
	reckless.needs[&"hunger"] = 60.0

	var d_cautious: Dictionary = UtilityBrain.choose(cautious, _world, _rng)
	var d_reckless: Dictionary = UtilityBrain.choose(reckless, _world, _rng)

	var cautious_eat: float = _get_score(d_cautious, "eat")
	var reckless_eat: float = _get_score(d_reckless, "eat")

	assert_gt(cautious_eat, reckless_eat, "Cautious agent memprioritaskan makan lebih awal")


func _get_score(decision: Dictionary, action_id: String) -> float:
	for item: Dictionary in decision["trace"]:
		if item["id"] == action_id:
			return item["score"]
	return 0.0
