class_name GridData
extends RefCounted
## Data grid peta: tipe tile, walkability, lokasi fungsional.

const TILE_GRASS: StringName = &"grass"
const TILE_FARM: StringName = &"farm"
const TILE_HOUSE: StringName = &"house"
const TILE_GRANARY: StringName = &"granary"
const TILE_WATER: StringName = &"water"

const WALKABLE_TYPES: Array[StringName] = [TILE_GRASS, TILE_FARM, TILE_HOUSE, TILE_GRANARY]

var width: int = 0
var height: int = 0
var tiles: Dictionary = {}


func is_walkable(pos: Vector2i) -> bool:
	if not tiles.has(pos):
		return false
	return tiles[pos] in WALKABLE_TYPES


func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


func get_locations_of_type(tile_type: StringName) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos: Vector2i in tiles:
		if tiles[pos] == tile_type:
			result.append(pos)
	result.sort()
	return result


static func from_dict(data: Dictionary) -> GridData:
	var gd: GridData = GridData.new()
	gd.width = data.get("width", 0)
	gd.height = data.get("height", 0)

	var tile_rows: Array = data.get("tiles", [])
	for y: int in range(tile_rows.size()):
		var row: Array = tile_rows[y]
		for x: int in range(row.size()):
			gd.tiles[Vector2i(x, y)] = StringName(row[x])

	return gd
