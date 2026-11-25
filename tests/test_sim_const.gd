extends GutTest


func test_ticks_per_day_positive() -> void:
	assert_gt(SimConst.TICKS_PER_DAY, 0)


func test_decay_rates_positive() -> void:
	assert_gt(SimConst.HUNGER_DECAY, 0.0)
	assert_gt(SimConst.ENERGY_DECAY, 0.0)


func test_seconds_per_tick_positive() -> void:
	assert_gt(SimConst.SECONDS_PER_TICK, 0.0)


func test_night_after_day() -> void:
	assert_gt(SimConst.NIGHT_START_HOUR, SimConst.DAY_START_HOUR)
