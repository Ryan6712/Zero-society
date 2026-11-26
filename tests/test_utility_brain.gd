extends GutTest
## Tes unit untuk UtilityBrain dan Explainability.

var _world: WorldState
var _agent: AgentState
var _rng: RandomNumberGenerator
var _events: Array[Dictionary]


func before_each() -> void:
	_world = WorldState.new()
	_world.granary_food = 20
	_world.initial_granary_food = 20

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

	_agent = AgentState.new(&"agent_000", Vector2i(0, 0))
	_world.agents.append(_agent)

	_rng = RandomNumberGenerator.new()
	_rng.seed = 42
	_events = []


func test_choose_returns_trace_with_three_candidates() -> void:
	var decision: Dictionary = UtilityBrain.choose(_agent, _world, _rng)
	assert_true(decision.has("best_id"))
	assert_true(decision.has("target_tile"))
	assert_true(decision.has("trace"))
	var trace: Array = decision["trace"]
	assert_eq(trace.size(), 3)
	assert_true(trace[0].has("id"))
	assert_true(trace[0].has("score"))


func test_hunger_raises_eat_score() -> void:
	_agent.needs[&"hunger"] = 100.0
	var d_full: Dictionary = UtilityBrain.choose(_agent, _world, _rng)

	_agent.needs[&"hunger"] = 20.0
	var d_hungry: Dictionary = UtilityBrain.choose(_agent, _world, _rng)

	assert_eq(d_hungry["best_id"], ActionLibrary.ID_EAT)


func test_night_and_low_energy_prefers_sleep() -> void:
	_world.tick = 0  # Midnight / night
	_agent.needs[&"energy"] = 15.0
	_agent.needs[&"hunger"] = 90.0

	var decision: Dictionary = UtilityBrain.choose(_agent, _world, _rng)
	assert_eq(decision["best_id"], ActionLibrary.ID_SLEEP)


func test_conscientiousness_increases_work_drive() -> void:
	var lazy_agent: AgentState = AgentState.new(&"agent_lazy", Vector2i(2, 0))
	lazy_agent.personality[&"conscientiousness"] = 10
	lazy_agent.needs[&"energy"] = 90.0
	lazy_agent.needs[&"hunger"] = 90.0

	var hard_agent: AgentState = AgentState.new(&"agent_hard", Vector2i(2, 0))
	hard_agent.personality[&"conscientiousness"] = 90
	hard_agent.needs[&"energy"] = 90.0
	hard_agent.needs[&"hunger"] = 90.0

	var d_lazy: Dictionary = UtilityBrain.choose(lazy_agent, _world, _rng)
	var d_hard: Dictionary = UtilityBrain.choose(hard_agent, _world, _rng)

	var lazy_work_score: float = 0.0
	for item: Dictionary in d_lazy["trace"]:
		if item["id"] == "work_farm":
			lazy_work_score = item["score"]

	var hard_work_score: float = 0.0
	for item: Dictionary in d_hard["trace"]:
		if item["id"] == "work_farm":
			hard_work_score = item["score"]

	assert_gt(hard_work_score, lazy_work_score)


func test_commitment_bonus_prevents_switching() -> void:
	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	_agent.position = Vector2i(2, 0)
	_agent.needs[&"energy"] = 80.0
	_agent.needs[&"hunger"] = 80.0

	ActionSystem.start_action(_agent, work_def, _world, Vector2i(2, 0), _events)

	var decision: Dictionary = UtilityBrain.choose(_agent, _world, _rng)
	assert_eq(decision["best_id"], ActionLibrary.ID_WORK_FARM)


func test_survival_interrupt_triggers_on_low_hunger() -> void:
	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	_agent.position = Vector2i(2, 0)
	ActionSystem.start_action(_agent, work_def, _world, Vector2i(2, 0), _events)

	_agent.needs[&"hunger"] = 10.0  # Below 15.0 threshold
	var interrupted: bool = UtilityBrain.check_survival_interrupt(_agent, _world, _events)

	assert_true(interrupted)
	assert_null(_agent.current_action)


func test_survival_interrupt_spares_move_with_eat_intent() -> void:
	var move_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
	ActionSystem.start_action(
		_agent, move_def, _world, Vector2i(3, 1), _events, ActionLibrary.ID_EAT
	)

	_agent.needs[&"hunger"] = 10.0
	var interrupted: bool = UtilityBrain.check_survival_interrupt(_agent, _world, _events)

	assert_false(interrupted, "Move dengan intent eat tidak boleh di-interrupt saat hunger kritis")
	assert_not_null(_agent.current_action)
