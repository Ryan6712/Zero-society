extends GutTest
## Tes unit untuk ActionValidator.

var _world: WorldState
var _agent: AgentState


func before_each() -> void:
	_world = WorldState.new()
	_world.granary_food = 20

	var grid_dict: Dictionary = {
		"width": 4,
		"height": 4,
		"tiles":
		[
			["grass", "grass", "farm", "grass"],
			["grass", "house", "grass", "granary"],
			["water", "grass", "grass", "grass"],
			["grass", "grass", "grass", "grass"],
		],
	}
	_world.grid_data = GridData.from_dict(grid_dict)

	_agent = AgentState.new(&"agent_000", Vector2i(0, 0))
	_world.agents.append(_agent)


func test_can_start_idle_ok() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.OK)


func test_can_start_dead_agent_rejected() -> void:
	_agent.alive = false
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.NOT_ALIVE)


func test_can_start_already_acting_rejected() -> void:
	var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	_agent.current_action = ActionInstance.new(idle_def, 0)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, idle_def, _world)
	assert_eq(reason, ActionValidator.RejectReason.ALREADY_ACTING)


func test_can_start_work_farm_low_energy() -> void:
	_agent.position = Vector2i(2, 0)  # On farm tile
	_agent.needs[&"energy"] = 10.0  # Min required is 20.0
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.LOW_ENERGY)


func test_can_start_work_farm_not_at_farm() -> void:
	_agent.position = Vector2i(0, 0)  # On grass, not farm
	_agent.needs[&"energy"] = 50.0
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.NOT_AT_LOCATION)


func test_can_start_work_farm_ok() -> void:
	_agent.position = Vector2i(2, 0)  # On farm tile
	_agent.needs[&"energy"] = 50.0
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.OK)


func test_can_start_eat_no_stock() -> void:
	_agent.position = Vector2i(3, 1)  # On granary tile
	_world.granary_food = 0
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.NO_STOCK)


func test_can_start_eat_ok() -> void:
	_agent.position = Vector2i(3, 1)  # On granary tile
	_world.granary_food = 5
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(_agent, def, _world)
	assert_eq(reason, ActionValidator.RejectReason.OK)


func test_can_start_move_invalid_target_same_pos() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(
		_agent, def, _world, Vector2i(0, 0)
	)
	assert_eq(reason, ActionValidator.RejectReason.INVALID_TARGET)


func test_can_start_move_invalid_target_water() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(
		_agent, def, _world, Vector2i(0, 2)
	)
	assert_eq(reason, ActionValidator.RejectReason.INVALID_TARGET)


func test_can_start_move_ok() -> void:
	var def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(
		_agent, def, _world, Vector2i(1, 0)
	)
	assert_eq(reason, ActionValidator.RejectReason.OK)
