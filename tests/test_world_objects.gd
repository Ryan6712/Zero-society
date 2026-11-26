extends GutTest
## Tes unit untuk WorldObject, kapasitas okupansi, dan batas storage lumbung.

var _world: WorldState
var _agent1: AgentState
var _agent2: AgentState


func before_each() -> void:
	_world = WorldState.new()
	_world.granary_food = 20
	_world.initial_granary_food = 20
	_world.granary_capacity = 30

	var grid_dict: Dictionary = {
		"width": 4,
		"height": 4,
		"tiles":
		[
			["grass", "house", "farm", "granary"],
			["grass", "grass", "grass", "grass"],
			["grass", "grass", "grass", "grass"],
			["grass", "grass", "grass", "grass"],
		],
	}
	_world.grid_data = GridData.from_dict(grid_dict)

	var bed: WorldObject = WorldObject.new(&"bed_1_0", GridData.TILE_HOUSE, Vector2i(1, 0), 1)
	_world.register_world_object(bed)

	var farm: WorldObject = WorldObject.new(&"farm_2_0", GridData.TILE_FARM, Vector2i(2, 0), 1)
	_world.register_world_object(farm)

	_agent1 = AgentState.new(&"agent_000", Vector2i(1, 0))
	_agent2 = AgentState.new(&"agent_001", Vector2i(1, 0))
	_world.agents.append(_agent1)
	_world.agents.append(_agent2)


func test_occupancy_blocks_second_agent() -> void:
	var bed: WorldObject = _world.get_object_at(Vector2i(1, 0))
	assert_not_null(bed)
	assert_true(bed.is_available())

	var sleep_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_SLEEP)
	var events: Array[Dictionary] = []

	# Agent 1 starts sleeping in bed
	var reason1: ActionValidator.RejectReason = ActionSystem.start_action(
		_agent1, sleep_def, _world, Vector2i.ZERO, events
	)
	assert_eq(reason1, ActionValidator.RejectReason.OK)
	assert_false(bed.is_available(), "Bed kapasitas 1 harus penuh")

	# Agent 2 tries to sleep in the same full bed
	var reason2: ActionValidator.RejectReason = ActionSystem.start_action(
		_agent2, sleep_def, _world, Vector2i.ZERO, events
	)
	assert_eq(
		reason2, ActionValidator.RejectReason.LOCATION_OCCUPIED, "Harus ditolak karena bed penuh"
	)


func test_occupant_released_on_completion() -> void:
	var farm: WorldObject = _world.get_object_at(Vector2i(2, 0))
	_agent1.position = Vector2i(2, 0)
	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	var events: Array[Dictionary] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()

	ActionSystem.start_action(_agent1, work_def, _world, Vector2i.ZERO, events)
	assert_false(farm.is_available())

	for i: int in range(SimConst.WORK_FARM_DURATION):
		ActionSystem.update(_agent1, _world, rng, events)

	assert_null(_agent1.current_action)
	assert_true(farm.is_available(), "Farm harus kembali tersedia setelah aksi selesai")


func test_granary_capacity_limit() -> void:
	_world.granary_food = 29
	_world.granary_capacity = 30
	var events: Array[Dictionary] = []

	var ok: bool = _world.modify_granary_food(1, &"produce", &"agent_000", events)
	assert_true(ok)
	assert_eq(_world.granary_food, 30)

	var overflow: bool = _world.modify_granary_food(1, &"produce", &"agent_000", events)
	assert_false(overflow, "Tidak boleh menyimpan makanan melebihi kapasitas lumbung")
	assert_eq(_world.granary_food, 30)
