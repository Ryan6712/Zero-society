extends SceneTree
## Runner CLI headless: jalankan simulasi tanpa tampilan.
## Pemakaian: godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var seed_val: int = 42
	var ticks: int = 1000
	var config_path: String = "res://data/default_world.json"
	var check_twice: bool = false
	var log_path: String = ""

	var i: int = 0
	while i < args.size():
		match args[i]:
			"--seed":
				i += 1
				if i < args.size():
					seed_val = int(args[i])
			"--ticks":
				i += 1
				if i < args.size():
					ticks = int(args[i])
			"--config":
				i += 1
				if i < args.size():
					config_path = args[i]
			"--log":
				i += 1
				if i < args.size():
					log_path = args[i]
			"--check-twice":
				check_twice = true
		i += 1

	var sim: Simulation = _run_sim(config_path, seed_val, ticks, log_path)
	if sim == null:
		quit(1)
		return

	var hash1: String = sim.compute_hash()
	print("Seed: %d" % seed_val)
	print("Ticks: %d" % ticks)
	print("Hash: %s" % hash1)
	_print_summary(sim)

	if check_twice:
		var sim2: Simulation = _run_sim(config_path, seed_val, ticks)
		var hash2: String = sim2.compute_hash()
		if hash1 == hash2:
			print("Determinism check: PASS (hash identical)")
		else:
			print("Determinism check: FAIL")
			print("  Hash 1: %s" % hash1)
			print("  Hash 2: %s" % hash2)
			quit(1)
			return

	quit(0)


func _run_sim(config_path: String, seed_val: int, ticks: int, log_path: String = "") -> Simulation:
	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if not file:
		push_error("Cannot open: %s" % config_path)
		return null
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("JSON error: %s" % json.get_error_message())
		return null

	var config: Dictionary = json.data
	config["seed"] = seed_val

	var sim: Simulation = Simulation.new(config)
	if not log_path.is_empty():
		sim.set_log_file(log_path)

	for t: int in range(ticks):
		sim.step()

	if not log_path.is_empty():
		sim.close_log_file()
		print("Log tersimpan di: %s" % log_path)

	return sim


func _print_summary(sim: Simulation) -> void:
	var alive_count: int = 0
	for agent: AgentState in sim.world.agents:
		if agent.alive:
			alive_count += 1
	print("Agents alive: %d / %d" % [alive_count, sim.world.agents.size()])
	print("Granary food: %d" % sim.world.granary_food)
	print("Events: %d" % sim.events.size())
	print("Day phase: %s" % String(sim.world.day_phase))
