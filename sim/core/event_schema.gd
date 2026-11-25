class_name EventSchema
extends RefCounted
## Konstanta field event wajib dan tipe event yang dikenal.

enum EventType {
	ACTION_STARTED,
	ACTION_COMPLETED,
	ACTION_FAILED,
	ACTION_INTERRUPTED,
	NEED_CRITICAL,
	AGENT_DIED,
	DECISION_MADE,
	FOOD_PRODUCED,
	FOOD_CONSUMED,
}

const REQUIRED_FIELDS: Array[StringName] = [
	&"tick",
	&"event_type",
	&"agent_id",
]

const EVENT_TYPE_NAMES: Dictionary = {
	EventType.ACTION_STARTED: "action_started",
	EventType.ACTION_COMPLETED: "action_completed",
	EventType.ACTION_FAILED: "action_failed",
	EventType.ACTION_INTERRUPTED: "action_interrupted",
	EventType.NEED_CRITICAL: "need_critical",
	EventType.AGENT_DIED: "agent_died",
	EventType.DECISION_MADE: "decision_made",
	EventType.FOOD_PRODUCED: "food_produced",
	EventType.FOOD_CONSUMED: "food_consumed",
}


static func validate(event: Dictionary) -> bool:
	for field: StringName in REQUIRED_FIELDS:
		if not event.has(field):
			return false
	return true
