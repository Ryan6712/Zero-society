class_name MovementSystem
extends RefCounted
## Pathfinding AStarGrid2D dan perpindahan agent per tile.


static func build_astar(grid_data: GridData) -> AStarGrid2D:
	var astar: AStarGrid2D = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, grid_data.width, grid_data.height)
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for y: int in range(grid_data.height):
		for x: int in range(grid_data.width):
			var pos: Vector2i = Vector2i(x, y)
			if not grid_data.is_walkable(pos):
				astar.set_point_solid(pos, true)

	return astar


static func find_path(from_pos: Vector2i, to_pos: Vector2i, grid_data: GridData) -> Array[Vector2i]:
	if from_pos == to_pos:
		return []

	if not grid_data.is_in_bounds(to_pos) or not grid_data.is_walkable(to_pos):
		return []

	if not grid_data.is_in_bounds(from_pos) or not grid_data.is_walkable(from_pos):
		return []

	var astar: AStarGrid2D = build_astar(grid_data)
	var raw_path: Array[Vector2i] = astar.get_id_path(from_pos, to_pos)

	if raw_path.is_empty():
		return []

	var result: Array[Vector2i] = []
	for i: int in range(1, raw_path.size()):
		result.append(raw_path[i])
	return result


static func update(agent: AgentState, world: WorldState) -> void:
	if not agent.alive:
		agent.path.clear()
		return

	if agent.path.is_empty():
		return

	var next_tile: Vector2i = agent.path.pop_front()
	if world.grid_data != null and world.grid_data.is_walkable(next_tile):
		agent.position = next_tile
	else:
		agent.path.clear()
