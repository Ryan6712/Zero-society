extends GutTest


func _make_world_with_agents(count: int = 3) -> WorldState:
	var world: WorldState = WorldState.new()
	world.granary_food = 20
	for i: int in range(count):
		var agent: AgentState = AgentState.new(StringName("agent_%03d" % i), Vector2i(i, 0))
		world.agents.append(agent)
	return world


func test_hunger_decays() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	var before: float = world.agents[0].needs[&"hunger"]
	NeedsSystem.update(world, events)
	var after: float = world.agents[0].needs[&"hunger"]
	assert_almost_eq(after, before - SimConst.HUNGER_DECAY, 0.001)


func test_energy_decays() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	var before: float = world.agents[0].needs[&"energy"]
	NeedsSystem.update(world, events)
	var after: float = world.agents[0].needs[&"energy"]
	assert_almost_eq(after, before - SimConst.ENERGY_DECAY, 0.001)


func test_hunger_clamps_at_zero() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	world.agents[0].needs[&"hunger"] = 0.1
	NeedsSystem.update(world, events)
	assert_gte(world.agents[0].needs[&"hunger"], 0.0)


func test_starvation_damages_health() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	world.agents[0].needs[&"hunger"] = 0.0
	var health_before: float = world.agents[0].health
	NeedsSystem.update(world, events)
	assert_lt(world.agents[0].health, health_before)


func test_starvation_emits_need_critical() -> void:
	var world: WorldState = _make_world_with_agents(1)
	world.tick = 10
	var events: Array[Dictionary] = []
	world.agents[0].needs[&"hunger"] = 0.0
	NeedsSystem.update(world, events)
	assert_gt(events.size(), 0)
	assert_eq(events[0]["event_type"], "need_critical")


func test_agent_dies_from_starvation() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	world.agents[0].needs[&"hunger"] = 0.0
	world.agents[0].health = 1.0
	NeedsSystem.update(world, events)
	assert_false(world.agents[0].alive)
	var death_events: Array[Dictionary] = events.filter(
		func(e: Dictionary) -> bool: return e["event_type"] == "agent_died"
	)
	assert_gt(death_events.size(), 0)
	assert_eq(death_events[0]["cause"], "starvation")


func test_dead_agent_not_processed() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	world.agents[0].alive = false
	world.agents[0].needs[&"hunger"] = 50.0
	NeedsSystem.update(world, events)
	assert_eq(world.agents[0].needs[&"hunger"], 50.0)


func test_health_regen_when_fed() -> void:
	var world: WorldState = _make_world_with_agents(1)
	var events: Array[Dictionary] = []
	world.agents[0].needs[&"hunger"] = 80.0
	world.agents[0].health = 90.0
	NeedsSystem.update(world, events)
	assert_gt(world.agents[0].health, 90.0)
