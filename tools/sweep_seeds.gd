extends SceneTree
## Skrip CLI headless untuk sweep seed simulasi Society Zero.
## Menjalankan simulasi lintas banyak seed dan melaporkan metrik agregat.
## Pemakaian: godot --headless -s tools/sweep_seeds.gd -- --seeds 20 --ticks 720


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var seed_count: int = 20
	var ticks: int = 720  # 5 hari simulasi (144 * 5)
	var config_path: String = "res://data/default_world.json"

	var i: int = 0
	while i < args.size():
		match args[i]:
			"--seeds":
				i += 1
				if i < args.size():
					seed_count = int(args[i])
			"--ticks":
				i += 1
				if i < args.size():
					ticks = int(args[i])
			"--config":
				i += 1
				if i < args.size():
					config_path = args[i]
		i += 1

	print("==================================================")
	print(
		(
			"Menjalankan Sweep: %d Seed, %d Ticks (%.1f hari)"
			% [seed_count, ticks, float(ticks) / float(SimConst.TICKS_PER_DAY)]
		)
	)
	print("==================================================")

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if not file:
		push_error("Gagal membuka config: %s" % config_path)
		quit(1)
		return

	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("Error JSON: %s" % json.get_error_message())
		quit(1)
		return

	var base_config: Dictionary = json.data

	var total_survival_pct: float = 0.0
	var total_switches_per_day: float = 0.0
	var total_final_food: int = 0

	for s: int in range(1, seed_count + 1):
		var run_config: Dictionary = base_config.duplicate(true)
		run_config["seed"] = s

		var sim: Simulation = Simulation.new(run_config)
		for t: int in range(ticks):
			sim.step()

		var metrics: Dictionary = BehaviorMetrics.collect_metrics(sim)
		total_survival_pct += metrics["survival_rate"]
		total_switches_per_day += metrics["switches_per_day"]
		total_final_food += metrics["final_granary_food"]

		print(
			(
				"Seed %02d | Survival: %3.0f%% (%d/%d) | Switch/Hari: %4.1f | Food: %3d | Hash: %s"
				% [
					s,
					metrics["survival_rate"],
					metrics["alive_agents"],
					metrics["total_agents"],
					metrics["switches_per_day"],
					metrics["final_granary_food"],
					sim.compute_hash().substr(0, 12),
				]
			)
		)

	var avg_survival: float = total_survival_pct / float(seed_count)
	var avg_switches: float = total_switches_per_day / float(seed_count)
	var avg_food: float = float(total_final_food) / float(seed_count)

	print("--------------------------------------------------")
	print("Hasil Agregat (%d Seed):" % seed_count)
	print("  - Rata-rata Survival     : %.1f%%" % avg_survival)
	print("  - Rata-rata Switch/Hari  : %.1f" % avg_switches)
	print("  - Rata-rata Sisa Lumbung : %.1f" % avg_food)
	print("==================================================")

	quit(0)
