class_name ActionLibrary
extends RefCounted
## Katalog aksi standar simulasi Society Zero.

const ID_IDLE: StringName = &"idle"
const ID_MOVE: StringName = &"move"
const ID_EAT: StringName = &"eat"
const ID_SLEEP: StringName = &"sleep"
const ID_WORK_FARM: StringName = &"work_farm"

static var _actions: Dictionary = {}


static func _ensure_initialized() -> void:
	if not _actions.is_empty():
		return

	_actions[ID_IDLE] = ActionDef.new(ID_IDLE, "Idle", 1, true, &"", 0.0, 0.0)

	_actions[ID_MOVE] = ActionDef.new(ID_MOVE, "Move", 1, true, &"", 0.0, 0.0)

	_actions[ID_EAT] = ActionDef.new(
		ID_EAT, "Eat", SimConst.EAT_DURATION, false, GridData.TILE_GRANARY, 0.0, 0.0
	)

	_actions[ID_SLEEP] = ActionDef.new(
		ID_SLEEP, "Sleep", SimConst.SLEEP_DURATION, true, GridData.TILE_HOUSE, 0.0, 0.0
	)

	_actions[ID_WORK_FARM] = ActionDef.new(
		ID_WORK_FARM,
		"Work Farm",
		SimConst.WORK_FARM_DURATION,
		true,
		GridData.TILE_FARM,
		20.0,
		SimConst.ENERGY_DECAY_WORKING - SimConst.ENERGY_DECAY
	)


static func get_action(action_id: StringName) -> ActionDef:
	_ensure_initialized()
	return _actions.get(action_id, null)


static func all() -> Array[ActionDef]:
	_ensure_initialized()
	var result: Array[ActionDef] = []
	var keys: Array = _actions.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	for k: Variant in keys:
		result.append(_actions[k])
	return result
