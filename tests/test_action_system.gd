extends GutTest
## Tes unit untuk ActionSystem siklus hidup, efek, dan interupsi.

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


func test_start_action_success() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	var reason: ActionValidator.RejectReason = ActionSystem.start_action(
		_agent, def, _world, Vector2i.ZERO, _events
	)
	assert_eq(reason, ActionValidator.RejectReason.OK)
	assert_not_null(_agent.current_action)
	assert_eq(_agent.current_action.ticks_left, 1)
	assert_eq(_events.size(), 1)
	assert_eq(_events[0]["event_type"], "action_started")


func test_action_completes_after_duration() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	ActionSystem.start_action(_agent, def, _world, Vector2i.ZERO, _events)

	ActionSystem.update(_agent, _world, _rng, _events)
	assert_null(_agent.current_action)

	var completed_events: Array[Dictionary] = _events.filter(
		func(e: Dictionary) -> bool: return e["event_type"] == "action_completed"
	)
	assert_eq(completed_events.size(), 1)


func test_eat_action_effects_and_granary_audit() -> void:
	_agent.position = Vector2i(3, 1)  # On granary
	_agent.needs[&"hunger"] = 30.0
	var initial_food: int = _world.granary_food

	var eat_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	ActionSystem.start_action(_agent, eat_def, _world, Vector2i.ZERO, _events)

	# Eat takes 2 ticks
	ActionSystem.update(_agent, _world, _rng, _events)
	assert_not_null(_agent.current_action)

	ActionSystem.update(_agent, _world, _rng, _events)
	assert_null(_agent.current_action)
	assert_eq(_agent.needs[&"hunger"], 70.0)
	assert_eq(_world.granary_food, initial_food - 1)
	assert_true(_world.is_food_conserved())


func test_eat_fails_if_stock_emptied_during_eating() -> void:
	_agent.position = Vector2i(3, 1)  # On granary
	_agent.needs[&"hunger"] = 30.0
	_world.granary_food = 1

	var eat_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	ActionSystem.start_action(_agent, eat_def, _world, Vector2i.ZERO, _events)

	# Simulasikan stok dicuri / diambil agent lain di tick 1
	_world.granary_food = 0
	_world.total_food_consumed += 1

	# Selesaikan aksi eat di tick 2
	ActionSystem.update(_agent, _world, _rng, _events)
	ActionSystem.update(_agent, _world, _rng, _events)

	assert_null(_agent.current_action)
	assert_eq(
		_agent.needs[&"hunger"], 30.0, "Hunger tidak boleh bertambah jika stok habis saat selesai"
	)


func test_work_farm_action_produces_food() -> void:
	_agent.position = Vector2i(2, 0)  # On farm
	_agent.needs[&"energy"] = 80.0
	var initial_food: int = _world.granary_food

	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	ActionSystem.start_action(_agent, work_def, _world, Vector2i.ZERO, _events)

	# Work farm takes 6 ticks
	for i: int in range(6):
		ActionSystem.update(_agent, _world, _rng, _events)

	assert_null(_agent.current_action)
	assert_eq(_world.granary_food, initial_food + 1)
	assert_true(_world.is_food_conserved())


func test_sleep_restores_energy() -> void:
	_agent.position = Vector2i(1, 1)  # On house
	_agent.needs[&"energy"] = 50.0

	var sleep_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_SLEEP)
	ActionSystem.start_action(_agent, sleep_def, _world, Vector2i.ZERO, _events)

	ActionSystem.update(_agent, _world, _rng, _events)
	assert_gt(_agent.needs[&"energy"], 50.0)


func test_interrupt_action() -> void:
	_agent.position = Vector2i(2, 0)  # On farm
	_agent.needs[&"energy"] = 80.0

	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	ActionSystem.start_action(_agent, work_def, _world, Vector2i.ZERO, _events)

	var interrupted: bool = ActionSystem.interrupt(_agent, _world, &"survival", _events)
	assert_true(interrupted)
	assert_null(_agent.current_action)

	var interrupt_events: Array[Dictionary] = _events.filter(
		func(e: Dictionary) -> bool: return e["event_type"] == "action_interrupted"
	)
	assert_eq(interrupt_events.size(), 1)


func test_cannot_interrupt_uninterruptible_action() -> void:
	_agent.position = Vector2i(3, 1)  # On granary
	var eat_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	ActionSystem.start_action(_agent, eat_def, _world, Vector2i.ZERO, _events)

	var interrupted: bool = ActionSystem.interrupt(_agent, _world, &"survival", _events)
	assert_false(interrupted)
	assert_not_null(_agent.current_action)
