extends GutTest
## Phase 0 Scenario C — Activity Interruption
## Memastikan aktivitas berjalan stabil sampai interupsi terjadi saat kondisi kritis.


func test_scenario_c_activity_interruption() -> void:
	var config: Dictionary = {
		"seed": 42,
		"agent_count": 1,
		"granary_food": 20,
		"grid":
		{
			"width": 6,
			"height": 6,
			"tiles":
			[
				["grass", "grass", "farm", "grass", "grass", "grass"],
				["grass", "house", "grass", "granary", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
				["grass", "grass", "grass", "grass", "grass", "grass"],
			],
		},
		"agent_spawn_positions": [[2, 0]],
	}

	var sim: Simulation = Simulation.new(config)
	var agent: AgentState = sim.world.agents[0]
	agent.needs[&"energy"] = 80.0
	agent.needs[&"hunger"] = 80.0

	# Mulai kerja di ladang
	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	ActionSystem.start_action(agent, work_def, sim.world, Vector2i.ZERO, sim.events)
	assert_not_null(agent.current_action)

	# Simulasikan energi anjlok ke ambang kritis
	agent.needs[&"energy"] = 8.0  # di bawah threshold 10.0
	sim.step()

	# Interupsi survival harus langsung membatalkan kerja
	var interrupt_events: Array[Dictionary] = sim.events.filter(
		func(e: Dictionary) -> bool: return e.get("event_type") == "action_interrupted"
	)
	assert_gt(interrupt_events.size(), 0, "Aksi kerja harus diinterupsi saat energi kritis")
	assert_eq(interrupt_events[0]["reason"], "survival")
