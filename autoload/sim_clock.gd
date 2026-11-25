extends Node
## SimClock: mengubah waktu nyata menjadi tick simulasi.
## Autoload — satu-satunya jembatan antara frame dan tick.

signal ticked(tick: int)

var speed: float = 1.0
var simulation: RefCounted = null

var _accum: float = 0.0


func _process(delta: float) -> void:
	if speed <= 0.0 or simulation == null:
		return
	_accum += delta * speed
	var n: int = 0
	while _accum >= SimConst.SECONDS_PER_TICK and n < SimConst.MAX_TICKS_PER_FRAME:
		_accum -= SimConst.SECONDS_PER_TICK
		n += 1
		simulation.step()
		ticked.emit(simulation.world.tick)
