extends GutTest
## Smoke test performa: memastikan waktu tick loop stabil dan tidak meledak (< 2ms / tick).

const PERF_CONFIG: Dictionary = {
	"seed": 42,
	"agent_count": 5,
	"granary_food": 50,
	"grid":
	{
		"width": 16,
		"height": 12,
		"tiles":
		[
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"house",
				"house",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"house",
				"house",
				"grass",
				"grass",
				"granary",
				"granary",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"farm",
				"farm",
				"farm",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"farm",
				"farm",
				"farm",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"water",
				"water",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"water",
				"water",
				"water",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
			[
				"grass",
				"grass",
				"grass",
				"water",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass",
				"grass"
			],
		],
	},
	"agent_spawn_positions": [[1, 1], [2, 1], [1, 2], [2, 2], [0, 0]],
}


func test_tick_performance_under_threshold() -> void:
	var sim: Simulation = Simulation.new(PERF_CONFIG)
	var ticks: int = 1000

	var start_time: int = Time.get_ticks_msec()
	for t: int in range(ticks):
		sim.step()
	var elapsed_ms: int = Time.get_ticks_msec() - start_time

	var avg_ms_per_tick: float = float(elapsed_ms) / float(ticks)
	print(
		(
			"Smoke Perf Test: %d ticks in %d ms (rata-rata %.3f ms/tick)"
			% [ticks, elapsed_ms, avg_ms_per_tick]
		)
	)

	# Ambang batas: rata-rata < 2.0 ms per tick (total < 2000 ms)
	assert_lt(elapsed_ms, 2000, "1000 tick harus selesai dalam kurang dari 2 detik")
