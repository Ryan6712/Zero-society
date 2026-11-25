extends GutTest


func _make_world() -> WorldState:
	var world: WorldState = WorldState.new()
	return world


func test_midnight_is_night() -> void:
	var world: WorldState = _make_world()
	world.tick = 0
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	WorldSystem.update(world, rng)
	assert_eq(world.day_phase, &"night")


func test_noon_is_day() -> void:
	var world: WorldState = _make_world()
	world.tick = SimConst.TICKS_PER_DAY / 2
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	WorldSystem.update(world, rng)
	assert_eq(world.day_phase, &"day")


func test_dawn_phase() -> void:
	var world: WorldState = _make_world()
	var dawn_tick: int = int(SimConst.DAWN_START_HOUR / 24.0 * SimConst.TICKS_PER_DAY) + 1
	world.tick = dawn_tick
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	WorldSystem.update(world, rng)
	assert_eq(world.day_phase, &"dawn")


func test_dusk_phase() -> void:
	var world: WorldState = _make_world()
	var dusk_tick: int = int(SimConst.DUSK_START_HOUR / 24.0 * SimConst.TICKS_PER_DAY) + 1
	world.tick = dusk_tick
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	WorldSystem.update(world, rng)
	assert_eq(world.day_phase, &"dusk")
