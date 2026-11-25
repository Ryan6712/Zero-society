extends GutTest


func _make_world(agent_count: int = 2) -> WorldState:
	var world: WorldState = WorldState.new()
	world.seed_value = 42
	world.granary_food = 20.0
	for i: int in range(agent_count):
		var agent: AgentState = AgentState.new(StringName("agent_%03d" % i), Vector2i(i, 0))
		world.agents.append(agent)
	return world


func test_sorted_agent_ids() -> void:
	var world: WorldState = _make_world(3)
	var ids: Array[StringName] = world.sorted_agent_ids()
	assert_eq(ids.size(), 3)
	assert_eq(ids[0], &"agent_000")
	assert_eq(ids[1], &"agent_001")
	assert_eq(ids[2], &"agent_002")


func test_get_agent() -> void:
	var world: WorldState = _make_world(2)
	var agent: AgentState = world.get_agent(&"agent_001")
	assert_not_null(agent)
	assert_eq(agent.id, &"agent_001")


func test_get_agent_not_found() -> void:
	var world: WorldState = _make_world(1)
	var agent: AgentState = world.get_agent(&"nope")
	assert_null(agent)


func test_hour_of_day() -> void:
	var world: WorldState = _make_world(0)
	world.tick = 0
	assert_eq(world.hour_of_day(), 0.0)
	world.tick = SimConst.TICKS_PER_DAY / 2
	assert_almost_eq(world.hour_of_day(), 12.0, 0.01)


func test_is_night() -> void:
	var world: WorldState = _make_world(0)
	world.tick = 0
	assert_true(world.is_night())
	world.tick = SimConst.TICKS_PER_DAY / 2
	assert_false(world.is_night())


func test_hash_consistent() -> void:
	var w1: WorldState = _make_world(2)
	var w2: WorldState = _make_world(2)
	assert_eq(w1.compute_hash(), w2.compute_hash())


func test_hash_changes() -> void:
	var world: WorldState = _make_world(2)
	var h1: String = world.compute_hash()
	world.tick = 10
	var h2: String = world.compute_hash()
	assert_ne(h1, h2)
