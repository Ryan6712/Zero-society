class_name Curves
extends RefCounted
## Fungsi kurva pertimbangan matematis dan utilitas jarak.


static func urgency(need: float) -> float:
	var d: float = 1.0 - clampf(need / 100.0, 0.0, 1.0)
	return d * d


static func distance_factor(tiles: int) -> float:
	return 1.0 / (1.0 + 0.05 * float(tiles))


static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


static func distance_to_nearest(from_pos: Vector2i, locations: Array[Vector2i]) -> int:
	if locations.is_empty():
		return 9999
	var min_dist: int = 999999
	for loc: Vector2i in locations:
		var d: int = manhattan_distance(from_pos, loc)
		if d < min_dist:
			min_dist = d
	return min_dist


static func nearest_tile(from_pos: Vector2i, locations: Array[Vector2i]) -> Vector2i:
	if locations.is_empty():
		return from_pos
	var best_tile: Vector2i = locations[0]
	var min_dist: int = manhattan_distance(from_pos, best_tile)
	for i: int in range(1, locations.size()):
		var loc: Vector2i = locations[i]
		var d: int = manhattan_distance(from_pos, loc)
		if d < min_dist:
			min_dist = d
			best_tile = loc
	return best_tile
