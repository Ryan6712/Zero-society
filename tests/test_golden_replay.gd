extends GutTest
## Golden replay test: membekukan hash state deterministik resmi untuk Seed 42 pada tick 1000.
## Komitmen refactor atau optimasi tidak boleh mengubah nilai hash ini.

const GOLDEN_HASH: String = "c874cbf4d7170a66ff406e19f7d63513330af028ba49d7d4b37048205bc80e01"


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
