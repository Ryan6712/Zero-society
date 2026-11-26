class_name ActionValidator
extends RefCounted
## Validasi prasyarat aksi sebelum dieksekusi oleh Simulation.

enum RejectReason {
	OK = 0,
	NOT_ALIVE,
	ALREADY_ACTING,
	NOT_AT_LOCATION,
	LOCATION_OCCUPIED,
	NO_STOCK,
	LOW_ENERGY,
	NO_PATH,
	INVALID_TARGET,
	UNKNOWN_ACTION,
}

const REJECT_REASON_NAMES: Dictionary = {
	RejectReason.OK: "ok",
	RejectReason.NOT_ALIVE: "not_alive",
	RejectReason.ALREADY_ACTING: "already_acting",
	RejectReason.NOT_AT_LOCATION: "not_at_location",
	RejectReason.LOCATION_OCCUPIED: "location_occupied",
	RejectReason.NO_STOCK: "no_stock",
	RejectReason.LOW_ENERGY: "low_energy",
	RejectReason.NO_PATH: "no_path",
	RejectReason.INVALID_TARGET: "invalid_target",
	RejectReason.UNKNOWN_ACTION: "unknown_action",
}


static func can_start(
	agent: AgentState,
	action_def: ActionDef,
	world: WorldState,
	target_tile: Vector2i = Vector2i.ZERO
) -> RejectReason:
	if agent == null or not agent.alive:
		return RejectReason.NOT_ALIVE

	if action_def == null:
		return RejectReason.UNKNOWN_ACTION

	if agent.current_action != null:
		return RejectReason.ALREADY_ACTING

	if action_def.min_energy > 0.0:
		var current_energy: float = agent.needs.get(&"energy", 0.0)
		if current_energy < action_def.min_energy:
			return RejectReason.LOW_ENERGY

	if action_def.required_location != &"":
		if world.grid_data == null:
			return RejectReason.NOT_AT_LOCATION
		var current_tile_type: StringName = world.grid_data.tiles.get(agent.position, &"")
		if current_tile_type != action_def.required_location:
			return RejectReason.NOT_AT_LOCATION
		var obj: WorldObject = world.get_object_at(agent.position)
		if obj != null and not obj.is_available() and not obj.current_occupants.has(agent.id):
			return RejectReason.LOCATION_OCCUPIED

	if action_def.id == ActionLibrary.ID_EAT:
		if world.granary_food <= 0:
			return RejectReason.NO_STOCK

	if action_def.id in [ActionLibrary.ID_MOVE, ActionLibrary.ID_WANDER]:
		if target_tile == agent.position:
			return RejectReason.INVALID_TARGET
		if world.grid_data != null:
			if not world.grid_data.is_in_bounds(target_tile):
				return RejectReason.INVALID_TARGET
			if not world.grid_data.is_walkable(target_tile):
				return RejectReason.INVALID_TARGET

	return RejectReason.OK


static func can_continue(agent: AgentState, world: WorldState) -> RejectReason:
	if agent == null or not agent.alive:
		return RejectReason.NOT_ALIVE

	if agent.current_action == null or agent.current_action.def == null:
		return RejectReason.UNKNOWN_ACTION

	var def: ActionDef = agent.current_action.def

	if def.required_location != &"":
		if world.grid_data != null:
			var current_tile_type: StringName = world.grid_data.tiles.get(agent.position, &"")
			if current_tile_type != def.required_location:
				return RejectReason.NOT_AT_LOCATION

	if def.id == ActionLibrary.ID_WORK_FARM:
		var current_energy: float = agent.needs.get(&"energy", 0.0)
		if current_energy <= 0.0:
			return RejectReason.LOW_ENERGY

	return RejectReason.OK
