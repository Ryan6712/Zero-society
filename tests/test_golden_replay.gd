extends GutTest
## Golden replay test: membekukan hash state deterministik resmi untuk Seed 42 pada tick 1000.
## Komitmen refactor atau optimasi tidak boleh mengubah nilai hash ini.

const GOLDEN_HASH: String = "528cbd1ad359594ed518e05433a1b11c8f965388ef7d02ea49d960fe8ac019a4"


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
