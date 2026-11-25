extends GutTest
## Fuzz test: agent memilih aksi acak ber-seed selama 2000 tick lintas berbagai seed.
## Membuktikan stabilitas engine dan invariansi tidak pernah jebol.


func test_fuzz_2000_ticks_seed_42() -> void:
	_run_fuzz(42, 2000)


func test_fuzz_2000_ticks_seed_99() -> void:
	_run_fuzz(99, 2000)


func test_fuzz_2000_ticks_seed_1337() -> void:
	_run_fuzz(1337, 2000)


func _run_fuzz(seed_val: int, ticks: int) -> void:
	var sim: Simulation = _make_fuzz_sim(seed_val)
	var all_actions: Array[ActionDef] = ActionLibrary.all()
	var walkable_tiles: Array[Vector2i] = []

	for y: int in range(sim.world.grid_data.height):
		for x: int in range(sim.world.grid_data.width):
			var pos: Vector2i = Vector2i(x, y)
			if sim.world.grid_data.is_walkable(pos):
				walkable_tiles.append(pos)

	for t: int in range(ticks):
		for agent: AgentState in sim.world.agents:
			if not agent.alive:
				continue

			if agent.current_action == null:
				var action_idx: int = sim.rng.randi_range(0, all_actions.size() - 1)
				var action_def: ActionDef = all_actions[action_idx]
				var target_tile: Vector2i = Vector2i.ZERO

				if action_def.id == ActionLibrary.ID_MOVE and not walkable_tiles.is_empty():
					var tile_idx: int = sim.rng.randi_range(0, walkable_tiles.size() - 1)
					target_tile = walkable_tiles[tile_idx]

				ActionSystem.start_action(agent, action_def, sim.world, target_tile, sim.events)

		sim.step()

		# Pemeriksaan invariant tiap tick
		assert_true(
			sim.world.is_food_conserved(), "Konservasi makanan tidak boleh gagal di tick %d" % t
		)
		assert_gte(sim.world.granary_food, 0, "Stok lumbung tidak boleh negatif di tick %d" % t)

		for agent: AgentState in sim.world.agents:
			if agent.alive:
				assert_gte(agent.needs[&"hunger"], 0.0)
				assert_lte(agent.needs[&"hunger"], 100.0)
				assert_gte(agent.needs[&"energy"], 0.0)
				assert_lte(agent.needs[&"energy"], 100.0)
				assert_gte(agent.health, 0.0)
				assert_lte(agent.health, 100.0)
				assert_true(sim.world.grid_data.is_walkable(agent.position))
			else:
				assert_null(agent.current_action)
				assert_true(agent.path.is_empty())


func _make_fuzz_sim(seed_val: int) -> Simulation:
	return (
		Simulation
		. new(
			{
				"seed": seed_val,
				"agent_count": 3,
				"granary_food": 20,
				"grid":
				{
					"width": 6,
					"height": 6,
					"tiles":
					[
						["grass", "grass", "farm", "farm", "grass", "grass"],
						["grass", "house", "grass", "granary", "grass", "grass"],
						["grass", "grass", "water", "water", "grass", "grass"],
						["grass", "grass", "water", "water", "grass", "grass"],
						["grass", "house", "grass", "grass", "farm", "grass"],
						["grass", "grass", "grass", "grass", "grass", "grass"],
					],
				},
				"agent_spawn_positions": [[0, 0], [1, 0], [0, 1]],
			}
		)
	)
