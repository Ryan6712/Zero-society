extends GutTest
## Skenario scripted lengkap: gerak ke ladang -> kerja -> gerak ke lumbung -> makan -> tidur.

var _sim: Simulation
var _world: WorldState
var _agent: AgentState


func before_each() -> void:
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
		"agent_spawn_positions": [[0, 0]],
	}

	_sim = Simulation.new(config)
	_world = _sim.world
	_agent = _world.agents[0]


func test_full_village_scripted_lifecycle() -> void:
	var initial_food: int = _world.granary_food
	assert_eq(_agent.position, Vector2i(0, 0))

	# 1. Gerak ke Ladang (2, 0)
	var move_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_MOVE)
	var farm_pos: Vector2i = Vector2i(2, 0)
	var reason: ActionValidator.RejectReason = ActionSystem.start_action(
		_agent, move_def, _world, farm_pos, _sim.events
	)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	while _agent.current_action != null:
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_eq(_agent.position, farm_pos, "Agent harus sudah sampai di Farm")

	# 2. Bekerja di Ladang (work_farm)
	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	reason = ActionSystem.start_action(_agent, work_def, _world, Vector2i.ZERO, _sim.events)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	while _agent.current_action != null:
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_eq(_world.granary_food, initial_food + 1, "Makanan di lumbung harus bertambah 1")

	# 3. Gerak ke Lumbung (3, 1)
	var granary_pos: Vector2i = Vector2i(3, 1)
	reason = ActionSystem.start_action(_agent, move_def, _world, granary_pos, _sim.events)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	while _agent.current_action != null:
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_eq(_agent.position, granary_pos, "Agent harus sampai di Granary")

	# 4. Makan di Lumbung (eat)
	var hunger_before: float = _agent.needs[&"hunger"]
	var eat_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	reason = ActionSystem.start_action(_agent, eat_def, _world, Vector2i.ZERO, _sim.events)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	while _agent.current_action != null:
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_gt(_agent.needs[&"hunger"], hunger_before, "Lapar harus berkurang (angka hunger naik)")
	assert_eq(
		_world.granary_food,
		initial_food,
		"Stok lumbung kembali ke awal setelah kerja (+1) lalu makan (-1)"
	)

	# 5. Gerak ke Rumah (1, 1) dan Tidur
	var house_pos: Vector2i = Vector2i(1, 1)
	reason = ActionSystem.start_action(_agent, move_def, _world, house_pos, _sim.events)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	while _agent.current_action != null:
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_eq(_agent.position, house_pos, "Agent harus sampai di House")

	var sleep_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_SLEEP)
	_agent.needs[&"energy"] = 40.0
	reason = ActionSystem.start_action(_agent, sleep_def, _world, Vector2i.ZERO, _sim.events)
	assert_eq(reason, ActionValidator.RejectReason.OK)

	for i: int in range(5):
		_sim.step()
		assert_true(_world.is_food_conserved())

	assert_gt(_agent.needs[&"energy"], 40.0, "Energi harus bertambah saat tidur")
	assert_true(_world.is_food_conserved(), "Konservasi makanan harus selalu terpenuhi")
