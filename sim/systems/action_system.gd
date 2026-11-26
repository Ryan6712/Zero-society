class_name ActionSystem
extends RefCounted
## Siklus hidup aksi agent: start, progress, complete, fail, interrupt.


static func start_action(
	agent: AgentState,
	action_def: ActionDef,
	world: WorldState,
	target_tile: Vector2i = Vector2i.ZERO,
	events: Array[Dictionary] = [],
	intent: StringName = &""
) -> ActionValidator.RejectReason:
	var reason: ActionValidator.RejectReason = ActionValidator.can_start(
		agent, action_def, world, target_tile
	)
	if reason != ActionValidator.RejectReason.OK:
		_emit_event(
			events,
			world,
			agent,
			EventSchema.EventType.ACTION_FAILED,
			{
				"action_id": String(action_def.id) if action_def else "",
				"reject_reason": ActionValidator.REJECT_REASON_NAMES[reason],
			}
		)
		return reason

	var duration: int = action_def.duration_ticks

	if action_def.id in [ActionLibrary.ID_MOVE, ActionLibrary.ID_WANDER]:
		var path: Array[Vector2i] = MovementSystem.find_path(
			agent.position, target_tile, world.grid_data
		)
		if path.is_empty():
			_emit_event(
				events,
				world,
				agent,
				EventSchema.EventType.ACTION_FAILED,
				{
					"action_id": String(action_def.id),
					"reject_reason":
					ActionValidator.REJECT_REASON_NAMES[ActionValidator.RejectReason.NO_PATH],
				}
			)
			return ActionValidator.RejectReason.NO_PATH
		agent.path = path
		duration = path.size()

	var instance: ActionInstance = ActionInstance.new(action_def, world.tick, intent)
	instance.ticks_left = duration
	instance.target_tile = target_tile
	agent.current_action = instance

	var obj: WorldObject = world.get_object_at(agent.position)
	if obj != null and action_def.required_location != &"":
		obj.occupy(agent.id)

	_emit_event(
		events,
		world,
		agent,
		EventSchema.EventType.ACTION_STARTED,
		{
			"action_id": String(action_def.id),
			"duration_ticks": duration,
			"target_tile": [target_tile.x, target_tile.y],
		}
	)

	return ActionValidator.RejectReason.OK


static func update(
	agent: AgentState, world: WorldState, _rng: RandomNumberGenerator, events: Array[Dictionary]
) -> void:
	if not agent.alive:
		if agent.current_action != null:
			var obj: WorldObject = world.get_object_at(agent.position)
			if obj != null:
				obj.release(agent.id)
			agent.current_action = null
			agent.path.clear()
		return

	if agent.current_action == null:
		return

	var continue_reason: ActionValidator.RejectReason = ActionValidator.can_continue(agent, world)
	if continue_reason != ActionValidator.RejectReason.OK:
		var obj: WorldObject = world.get_object_at(agent.position)
		if obj != null:
			obj.release(agent.id)
		_emit_event(
			events,
			world,
			agent,
			EventSchema.EventType.ACTION_FAILED,
			{
				"action_id": String(agent.current_action.def.id),
				"reject_reason": ActionValidator.REJECT_REASON_NAMES[continue_reason],
			}
		)
		agent.current_action = null
		agent.path.clear()
		return

	var instance: ActionInstance = agent.current_action
	var def: ActionDef = instance.def

	if def.id in [ActionLibrary.ID_MOVE, ActionLibrary.ID_WANDER]:
		MovementSystem.update(agent, world)
		instance.ticks_left -= 1
	else:
		instance.ticks_left -= 1

	if def.id == ActionLibrary.ID_SLEEP:
		agent.needs[&"energy"] = clampf(
			agent.needs[&"energy"] + SimConst.SLEEP_ENERGY_RESTORE, 0.0, 100.0
		)
		if agent.needs[&"energy"] >= 100.0:
			instance.ticks_left = 0

	elif def.id == ActionLibrary.ID_RECOVER:
		agent.health = clampf(agent.health + SimConst.RECOVER_HEALTH_RESTORE, 0.0, 100.0)
		if agent.health >= 100.0:
			instance.ticks_left = 0

	elif def.id == ActionLibrary.ID_WORK_FARM:
		agent.needs[&"energy"] = clampf(
			agent.needs[&"energy"] - def.energy_cost_per_tick, 0.0, 100.0
		)

	if instance.ticks_left <= 0:
		_complete_action(agent, instance, world, events)


static func interrupt(
	agent: AgentState, world: WorldState, reason: StringName, events: Array[Dictionary]
) -> bool:
	if agent.current_action == null:
		return false

	if not agent.current_action.def.interruptible:
		return false

	_emit_event(
		events,
		world,
		agent,
		EventSchema.EventType.ACTION_INTERRUPTED,
		{
			"action_id": String(agent.current_action.def.id),
			"reason": String(reason),
		}
	)

	var obj: WorldObject = world.get_object_at(agent.position)
	if obj != null:
		obj.release(agent.id)

	agent.current_action = null
	agent.path.clear()
	return true


static func _complete_action(
	agent: AgentState, instance: ActionInstance, world: WorldState, events: Array[Dictionary]
) -> void:
	var def: ActionDef = instance.def

	if def.id == ActionLibrary.ID_EAT:
		if world.modify_granary_food(-1, &"eat", agent.id, events):
			agent.needs[&"hunger"] = clampf(
				agent.needs[&"hunger"] + SimConst.EAT_HUNGER_RESTORE, 0.0, 100.0
			)
		else:
			var obj_fail: WorldObject = world.get_object_at(agent.position)
			if obj_fail != null:
				obj_fail.release(agent.id)
			_emit_event(
				events,
				world,
				agent,
				EventSchema.EventType.ACTION_FAILED,
				{
					"action_id": "eat",
					"reject_reason": "no_stock",
				}
			)
			agent.current_action = null
			return

	elif def.id == ActionLibrary.ID_WORK_FARM:
		world.modify_granary_food(SimConst.WORK_FARM_FOOD_PRODUCED, &"work_farm", agent.id, events)

	var obj: WorldObject = world.get_object_at(agent.position)
	if obj != null:
		obj.release(agent.id)

	_emit_event(
		events,
		world,
		agent,
		EventSchema.EventType.ACTION_COMPLETED,
		{
			"action_id": String(def.id),
		}
	)

	agent.current_action = null


static func _emit_event(
	events: Array[Dictionary],
	world: WorldState,
	agent: AgentState,
	event_type: EventSchema.EventType,
	extra: Dictionary
) -> void:
	world.next_event_id += 1
	var event: Dictionary = {
		"id": world.next_event_id,
		"tick": world.tick,
		"event_type": EventSchema.EVENT_TYPE_NAMES[event_type],
		"agent_id": String(agent.id),
	}
	event.merge(extra)
	events.append(event)
