class_name NeedsSystem
extends RefCounted
## Decay needs tiap tick, starvation, kematian.


static func update(world: WorldState, events: Array[Dictionary]) -> void:
	for aid: StringName in world.sorted_agent_ids():
		var agent: AgentState = world.get_agent(aid)
		if not agent.alive:
			continue
		_decay(agent, world, events)


static func _decay(agent: AgentState, world: WorldState, events: Array[Dictionary]) -> void:
	agent.needs[&"hunger"] = clampf(agent.needs[&"hunger"] - SimConst.HUNGER_DECAY, 0.0, 100.0)
	agent.needs[&"energy"] = clampf(agent.needs[&"energy"] - SimConst.ENERGY_DECAY, 0.0, 100.0)

	if agent.needs[&"hunger"] <= 0.0:
		agent.starving_ticks += 1
		agent.health = clampf(agent.health - SimConst.STARVING_HEALTH_LOSS, 0.0, 100.0)
		if agent.starving_ticks == 1:
			_emit_event(
				events,
				world,
				agent,
				EventSchema.EventType.NEED_CRITICAL,
				{
					"need": "hunger",
					"value": agent.needs[&"hunger"],
				}
			)
	else:
		agent.starving_ticks = 0

	if agent.needs[&"hunger"] > SimConst.HEALTH_REGEN_THRESHOLD:
		agent.health = clampf(agent.health + SimConst.HEALTH_REGEN_RATE, 0.0, 100.0)

	if agent.health <= 0.0:
		agent.alive = false
		agent.current_action = null
		agent.path.clear()
		_emit_event(
			events,
			world,
			agent,
			EventSchema.EventType.AGENT_DIED,
			{
				"cause": "starvation",
				"starving_ticks": agent.starving_ticks,
			}
		)


static func _emit_event(
	events: Array[Dictionary],
	world: WorldState,
	agent: AgentState,
	event_type: EventSchema.EventType,
	extra: Dictionary,
) -> void:
	var event: Dictionary = {
		"tick": world.tick,
		"event_type": EventSchema.EVENT_TYPE_NAMES[event_type],
		"agent_id": String(agent.id),
	}
	event.merge(extra)
	world.next_event_id += 1
	event["id"] = world.next_event_id
	events.append(event)
