extends GutTest


func _make_grid_dict() -> Dictionary:
	return {
		"width": 4,
		"height": 3,
		"tiles":
		[
			["grass", "grass", "farm", "grass"],
			["grass", "house", "grass", "granary"],
			["water", "grass", "grass", "grass"],
		],
	}


func test_from_dict() -> void:
	var gd: GridData = GridData.from_dict(_make_grid_dict())
	assert_eq(gd.width, 4)
	assert_eq(gd.height, 3)
	assert_eq(gd.tiles.size(), 12)


func test_walkable() -> void:
	var gd: GridData = GridData.from_dict(_make_grid_dict())
	assert_true(gd.is_walkable(Vector2i(0, 0)))
	assert_true(gd.is_walkable(Vector2i(2, 0)))
	assert_true(gd.is_walkable(Vector2i(1, 1)))
	assert_true(gd.is_walkable(Vector2i(3, 1)))
	assert_false(gd.is_walkable(Vector2i(0, 2)))


func test_not_walkable_out_of_bounds() -> void:
	var gd: GridData = GridData.from_dict(_make_grid_dict())
	assert_false(gd.is_walkable(Vector2i(-1, 0)))
	assert_false(gd.is_walkable(Vector2i(10, 10)))


func test_get_locations_of_type() -> void:
	var gd: GridData = GridData.from_dict(_make_grid_dict())
	var farms: Array[Vector2i] = gd.get_locations_of_type(GridData.TILE_FARM)
	assert_eq(farms.size(), 1)
	assert_eq(farms[0], Vector2i(2, 0))

	var houses: Array[Vector2i] = gd.get_locations_of_type(GridData.TILE_HOUSE)
	assert_eq(houses.size(), 1)
	assert_eq(houses[0], Vector2i(1, 1))
