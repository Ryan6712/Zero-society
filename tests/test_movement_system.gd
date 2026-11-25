extends GutTest
## Tes unit untuk MovementSystem dan AStarGrid2D.

var _grid: GridData
var _world: WorldState
var _agent: AgentState


func before_each() -> void:
	_grid = (
		GridData
		. from_dict(
			{
				"width": 5,
				"height": 5,
				"tiles":
				[
					["grass", "grass", "grass", "grass", "grass"],
					["grass", "water", "water", "water", "grass"],
					["grass", "grass", "grass", "water", "grass"],
					["grass", "water", "grass", "grass", "grass"],
					["grass", "grass", "grass", "grass", "farm"],
				],
			}
		)
	)

	_world = WorldState.new()
	_world.grid_data = _grid

	_agent = AgentState.new(&"agent_000", Vector2i(0, 0))
	_world.agents.append(_agent)


func test_build_astar() -> void:
	var astar: AStarGrid2D = MovementSystem.build_astar(_grid)
	assert_false(astar.is_point_solid(Vector2i(0, 0)))
	assert_true(astar.is_point_solid(Vector2i(1, 1)))


func test_find_path_straight() -> void:
	var path: Array[Vector2i] = MovementSystem.find_path(Vector2i(0, 0), Vector2i(3, 0), _grid)
	assert_eq(path.size(), 3)
	assert_eq(path[0], Vector2i(1, 0))
	assert_eq(path[1], Vector2i(2, 0))
	assert_eq(path[2], Vector2i(3, 0))


func test_find_path_around_obstacle() -> void:
	var path: Array[Vector2i] = MovementSystem.find_path(Vector2i(0, 1), Vector2i(4, 1), _grid)
	assert_false(path.is_empty())
	for p: Vector2i in path:
		assert_true(_grid.is_walkable(p), "Semua titik di path harus walkable")


func test_find_path_same_position() -> void:
	var path: Array[Vector2i] = MovementSystem.find_path(Vector2i(2, 2), Vector2i(2, 2), _grid)
	assert_true(path.is_empty())


func test_find_path_unwalkable_target() -> void:
	var path: Array[Vector2i] = MovementSystem.find_path(Vector2i(0, 0), Vector2i(1, 1), _grid)
	assert_true(path.is_empty())


func test_update_moves_agent_step_by_step() -> void:
	_agent.position = Vector2i(0, 0)
	_agent.path = [Vector2i(1, 0), Vector2i(2, 0)]

	MovementSystem.update(_agent, _world)
	assert_eq(_agent.position, Vector2i(1, 0))
	assert_eq(_agent.path.size(), 1)

	MovementSystem.update(_agent, _world)
	assert_eq(_agent.position, Vector2i(2, 0))
	assert_true(_agent.path.is_empty())
