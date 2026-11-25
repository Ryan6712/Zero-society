class_name WorldSystem
extends RefCounted
## Siklus siang/malam berdasarkan tick.


static func update(world: WorldState, _rng: RandomNumberGenerator) -> void:
	var hour: float = world.hour_of_day()

	if hour >= SimConst.NIGHT_START_HOUR or hour < SimConst.DAWN_START_HOUR:
		world.day_phase = &"night"
	elif hour >= SimConst.DAWN_START_HOUR and hour < SimConst.DAY_START_HOUR:
		world.day_phase = &"dawn"
	elif hour >= SimConst.DUSK_START_HOUR and hour < SimConst.NIGHT_START_HOUR:
		world.day_phase = &"dusk"
	else:
		world.day_phase = &"day"
