extends GutTest
## Golden replay test: membekukan hash state deterministik resmi untuk Seed 42 pada tick 1000.
## Komitmen refactor atau optimasi tidak boleh mengubah nilai hash ini.

const GOLDEN_HASH: String = "a6e07c22465d66ac18231b4362593280b9750e1bf38d41e93c1077f0d5b50e2b"


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
