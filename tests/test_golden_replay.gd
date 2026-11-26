extends GutTest
## Golden replay test: membekukan hash state deterministik resmi untuk Seed 42 pada tick 1000.
## Komitmen refactor atau optimasi tidak boleh mengubah nilai hash ini.

const GOLDEN_HASH: String = "a7fa27a6dc9e94febba6d31d825628164c8252d5454a71cdb52d6ebc1121e6ad"


func test_golden_replay_seed_42() -> void:
	var sim: Simulation = Simulation.from_json_file("res://data/default_world.json")
	assert_not_null(sim, "Config default_world.json harus valid")

	for t: int in range(1000):
		sim.step()

	var actual_hash: String = sim.compute_hash()
	assert_eq(
		actual_hash,
		GOLDEN_HASH,
		"Hash akhir simulasi harus identik persis dengan golden hash terdaftar"
	)
