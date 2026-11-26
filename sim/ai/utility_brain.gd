class_name UtilityBrain
extends RefCounted
## Pemilihan aksi otonom berbasis Utility AI dan Explainability.

const COMMIT_BONUS: float = 0.15
const NOISE: float = 0.02
const CRITICAL_HUNGER_THRESHOLD: float = 15.0
const CRITICAL_ENERGY_THRESHOLD: float = 10.0
const FLOOR_SCORE_IDLE: float = 0.05


static func choose(agent: AgentState, world: WorldState, rng: RandomNumberGenerator) -> Dictionary:
	var candidates: Array[StringName] = [
		ActionLibrary.ID_EAT,
		ActionLibrary.ID_SLEEP,
		ActionLibrary.ID_RECOVER,
		ActionLibrary.ID_WORK_FARM,
		ActionLibrary.ID_WANDER,
		ActionLibrary.ID_IDLE,
	]

	var scored: Array[Dictionary] = []

	for action_id: StringName in candidates:
		var result: Dictionary = _score_action(agent, action_id, world, rng)
		var base_score: float = result["score"]
		var target_tile: Vector2i = result["target_tile"]

		var final_score: float = base_score + rng.randf() * NOISE

		if agent.current_action != null and agent.current_action.def.id == action_id:
			final_score += COMMIT_BONUS

		final_score = snappedf(final_score, 0.0001)

		(
			scored
			. append(
				{
					"id": String(action_id),
					"score": final_score,
					"target_tile": target_tile,
				}
			)
		)

	scored.sort_custom(_compare_scored)

	var best: Dictionary = scored[0]
	var trace: Array[Dictionary] = []
	for i: int in range(mini(3, scored.size())):
		(
			trace
			. append(
				{
					"id": scored[i]["id"],
					"score": snappedf(scored[i]["score"], 0.001),
				}
			)
		)

	return {
		"best_id": StringName(best["id"]),
		"target_tile": best["target_tile"],
		"trace": trace,
	}


static func check_survival_interrupt(
	agent: AgentState, world: WorldState, events: Array[Dictionary]
) -> bool:
	if agent.current_action == null:
		return false

	var current_id: StringName = agent.current_action.def.id
	if current_id in [ActionLibrary.ID_EAT, ActionLibrary.ID_SLEEP]:
		return false

	# Jangan batalkan gerak (move) yang tujuannya untuk makan atau tidur
	if (
		current_id == ActionLibrary.ID_MOVE
		and agent.current_action.intent in [ActionLibrary.ID_EAT, ActionLibrary.ID_SLEEP]
	):
		return false

	var hunger: float = agent.needs.get(&"hunger", 100.0)
	var energy: float = agent.needs.get(&"energy", 100.0)

	if hunger < CRITICAL_HUNGER_THRESHOLD or energy < CRITICAL_ENERGY_THRESHOLD:
		return ActionSystem.interrupt(agent, world, &"survival", events)

	return false


static func decide_and_act(
	agent: AgentState, world: WorldState, rng: RandomNumberGenerator, events: Array[Dictionary]
) -> void:
	check_survival_interrupt(agent, world, events)

	if agent.current_action != null:
		return

	var decision: Dictionary = choose(agent, world, rng)
	var best_id: StringName = decision["best_id"]
	var target_tile: Vector2i = decision["target_tile"]
	var trace: Array[Dictionary] = decision["trace"]

	agent.last_decision_trace = trace

	_emit_decision_event(events, world, agent, best_id, target_tile, trace)

	if best_id == ActionLibrary.ID_IDLE:
		var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
		ActionSystem.start_action(agent, idle_def, world, agent.position, events)
		return

	if best_id == ActionLibrary.ID_WANDER:
		var wander_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WANDER)
		var reason: ActionValidator.RejectReason = ActionSystem.start_action(
			agent, wander_def, world, target_tile, events, best_id
		)
		if reason != ActionValidator.RejectReason.OK:
			var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
			ActionSystem.start_action(agent, idle_def, world, agent.position, events)
		return

	var intended_def: ActionDef = ActionLibrary.get_action(best_id)
	if intended_def == null:
		return

	var req_location: StringName = intended_def.required_location
	var current_tile_type: StringName = &""
	if world.grid_data != null:
		current_tile_type = world.grid_data.tiles.get(agent.position, &"")

	if req_location != &"" and current_tile_type != req_location:
		var move_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
		var reason: ActionValidator.RejectReason = ActionSystem.start_action(
			agent, move_def, world, target_tile, events, best_id
		)
		if reason != ActionValidator.RejectReason.OK:
			var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
			ActionSystem.start_action(agent, idle_def, world, agent.position, events)
	else:
		var reason: ActionValidator.RejectReason = ActionSystem.start_action(
			agent, intended_def, world, target_tile, events, best_id
		)
		if reason != ActionValidator.RejectReason.OK:
			var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
			ActionSystem.start_action(agent, idle_def, world, agent.position, events)


static func _score_action(
	agent: AgentState, action_id: StringName, world: WorldState, rng: RandomNumberGenerator
) -> Dictionary:
	var target_tile: Vector2i = agent.position
	var score: float = 0.0

	match action_id:
		ActionLibrary.ID_EAT:
			if world.granary_food <= 0:
				score = 0.0
			else:
				var hunger_urgency: float = Curves.urgency(agent.needs.get(&"hunger", 100.0))
				var risk_tol: int = agent.personality.get(&"risk_tolerance", 50)
				var adjusted_urgency: float = (
					hunger_urgency * (1.0 - 0.3 * (float(risk_tol) / 100.0))
				)
				var granaries: Array[Vector2i] = []
				if world.grid_data != null:
					granaries = world.grid_data.get_locations_of_type(GridData.TILE_GRANARY)
				if not granaries.is_empty():
					target_tile = Curves.nearest_tile(agent.position, granaries)
					var dist: int = Curves.distance_to_nearest(agent.position, granaries)
					score = adjusted_urgency * Curves.distance_factor(dist)
				else:
					score = adjusted_urgency

		ActionLibrary.ID_SLEEP:
			var energy_urgency: float = Curves.urgency(agent.needs.get(&"energy", 100.0))
			var night_mult: float = 1.5 if world.is_night() else 1.0
			var houses: Array[Vector2i] = []
			if world.grid_data != null:
				houses = world.grid_data.get_locations_of_type(GridData.TILE_HOUSE)
			if not houses.is_empty():
				target_tile = (
					agent.home_tile
					if agent.home_tile in houses
					else Curves.nearest_tile(agent.position, houses)
				)
				var dist: int = Curves.manhattan_distance(agent.position, target_tile)
				score = energy_urgency * night_mult * Curves.distance_factor(dist)
			else:
				score = energy_urgency * night_mult

		ActionLibrary.ID_RECOVER:
			if agent.health >= 100.0:
				score = 0.0
			else:
				var health_urgency: float = Curves.urgency(agent.health)
				var houses: Array[Vector2i] = []
				if world.grid_data != null:
					houses = world.grid_data.get_locations_of_type(GridData.TILE_HOUSE)
				if not houses.is_empty():
					target_tile = (
						agent.home_tile
						if agent.home_tile in houses
						else Curves.nearest_tile(agent.position, houses)
					)
					var dist: int = Curves.manhattan_distance(agent.position, target_tile)
					score = health_urgency * 1.8 * Curves.distance_factor(dist)
				else:
					score = health_urgency * 1.8

		ActionLibrary.ID_WORK_FARM:
			var conscientiousness: int = agent.personality.get(&"conscientiousness", 50)
			var kerja_drive: float = 0.3 + 0.5 * (float(conscientiousness) / 100.0)
			var max_need: float = maxf(
				Curves.urgency(agent.needs.get(&"hunger", 100.0)),
				Curves.urgency(agent.needs.get(&"energy", 100.0))
			)
			var current_energy: float = agent.needs.get(&"energy", 100.0)
			if current_energy < 20.0:
				score = 0.0
			else:
				var farms: Array[Vector2i] = []
				if world.grid_data != null:
					farms = world.grid_data.get_locations_of_type(GridData.TILE_FARM)
				if not farms.is_empty():
					target_tile = Curves.nearest_tile(agent.position, farms)
					var dist: int = Curves.distance_to_nearest(agent.position, farms)
					score = maxf(0.0, kerja_drive * (1.0 - max_need)) * Curves.distance_factor(dist)
				else:
					score = maxf(0.0, kerja_drive * (1.0 - max_need))

		ActionLibrary.ID_WANDER:
			var max_need: float = maxf(
				Curves.urgency(agent.needs.get(&"hunger", 100.0)),
				Curves.urgency(agent.needs.get(&"energy", 100.0))
			)
			var valid_neighbors: Array[Vector2i] = []
			if world.grid_data != null:
				var offsets: Array[Vector2i] = [
					Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
				]
				for offset: Vector2i in offsets:
					var neighbor: Vector2i = agent.position + offset
					if (
						world.grid_data.is_in_bounds(neighbor)
						and world.grid_data.is_walkable(neighbor)
					):
						valid_neighbors.append(neighbor)
			if valid_neighbors.is_empty():
				score = 0.0
			else:
				var idx: int = rng.randi_range(0, valid_neighbors.size() - 1)
				target_tile = valid_neighbors[idx]
				score = 0.08 * (1.0 - max_need)

		ActionLibrary.ID_IDLE:
			score = FLOOR_SCORE_IDLE

	return {
		"score": score,
		"target_tile": target_tile,
	}


static func _compare_scored(a: Dictionary, b: Dictionary) -> bool:
	if a["score"] != b["score"]:
		return a["score"] > b["score"]
	return String(a["id"]) < String(b["id"])


static func _emit_decision_event(
	events: Array[Dictionary],
	world: WorldState,
	agent: AgentState,
	best_id: StringName,
	target_tile: Vector2i,
	trace: Array[Dictionary]
) -> void:
	world.next_event_id += 1
	var event: Dictionary = {
		"id": world.next_event_id,
		"tick": world.tick,
		"event_type": EventSchema.EVENT_TYPE_NAMES[EventSchema.EventType.DECISION_MADE],
		"agent_id": String(agent.id),
		"action_id": String(best_id),
		"target_tile": [target_tile.x, target_tile.y],
		"decision_trace": trace,
	}
	events.append(event)
