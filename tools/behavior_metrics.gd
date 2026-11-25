class_name BehaviorMetrics
extends RefCounted
## Kolektor dan penganalisis metrik perilaku simulasi.


static func collect_metrics(sim: Simulation) -> Dictionary:
	var total_agents: int = sim.world.agents.size()
	var alive_count: int = 0
	for agent: AgentState in sim.world.agents:
		if agent.alive:
			alive_count += 1

	var survival_rate: float = (
		(float(alive_count) / float(total_agents)) * 100.0 if total_agents > 0 else 0.0
	)

	var days_simulated: float = maxf(1.0, float(sim.world.tick) / float(SimConst.TICKS_PER_DAY))

	var action_switch_count: int = 0
	var action_counts: Dictionary = {}

	for event: Dictionary in sim.events:
		var event_type: String = event.get("event_type", "")
		if event_type == "action_started":
			var action_id: String = event.get("action_id", "")
			action_counts[action_id] = action_counts.get(action_id, 0) + 1
			if action_id != "move":
				action_switch_count += 1

	var switches_per_agent_per_day: float = (
		float(action_switch_count) / float(total_agents) / days_simulated
		if total_agents > 0
		else 0.0
	)

	var total_action_starts: int = 0
	for count: int in action_counts.values():
		total_action_starts += count

	var action_percentages: Dictionary = {}
	for act_id: String in action_counts:
		var pct: float = (
			(float(action_counts[act_id]) / float(total_action_starts)) * 100.0
			if total_action_starts > 0
			else 0.0
		)
		action_percentages[act_id] = snappedf(pct, 0.1)

	return {
		"total_agents": total_agents,
		"alive_agents": alive_count,
		"survival_rate": snappedf(survival_rate, 0.1),
		"days_simulated": snappedf(days_simulated, 0.1),
		"switches_per_day": snappedf(switches_per_agent_per_day, 0.1),
		"action_percentages": action_percentages,
		"final_granary_food": sim.world.granary_food,
	}
