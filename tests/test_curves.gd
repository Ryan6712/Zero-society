extends GutTest
## Tes unit untuk Curves.


func test_urgency_monotonic() -> void:
	assert_eq(Curves.urgency(100.0), 0.0)
	assert_eq(Curves.urgency(0.0), 1.0)
	assert_almost_eq(Curves.urgency(50.0), 0.25, 0.001)
	assert_gt(Curves.urgency(20.0), Curves.urgency(40.0))


func test_distance_factor_monotonic() -> void:
	assert_eq(Curves.distance_factor(0), 1.0)
	assert_lt(Curves.distance_factor(10), Curves.distance_factor(0))
	assert_gt(Curves.distance_factor(10), 0.0)


func test_manhattan_distance() -> void:
	assert_eq(Curves.manhattan_distance(Vector2i(0, 0), Vector2i(3, 4)), 7)
	assert_eq(Curves.manhattan_distance(Vector2i(5, 5), Vector2i(5, 5)), 0)


func test_nearest_tile() -> void:
	var locs: Array[Vector2i] = [Vector2i(5, 5), Vector2i(2, 2), Vector2i(10, 10)]
	var nearest: Vector2i = Curves.nearest_tile(Vector2i(1, 1), locs)
	assert_eq(nearest, Vector2i(2, 2))
