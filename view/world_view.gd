extends Node2D
## Visualisasi peta grid dan kumpulan AgentView menggunakan aset Sunnyside World.
## Hanya membaca GridData dan WorldState tanpa menulis state (ADR-002).

signal agent_selected(agent: AgentState)

const TILE_SIZE: int = 16

const TEX_TILESET: Texture2D = preload(
	"res://assets/sunnyside_world/Tileset/spr_tileset_sunnysideworld_16px.png"
)
const TEX_TREE: Texture2D = preload(
	"res://assets/sunnyside_world/Elements/Plants/spr_deco_tree_01_strip4.png"
)
const TEX_ROCK: Texture2D = preload(
	"res://assets/sunnyside_world/Elements/Crops/rock.png"
)
const TEX_CRATE: Texture2D = preload(
	"res://assets/sunnyside_world/Elements/Crops/crate_base.png"
)
const TEX_WHEAT: Texture2D = preload(
	"res://assets/sunnyside_world/Elements/Crops/wheat_03.png"
)

const REGION_GRASS: Rect2 = Rect2(32, 32, 16, 16)
const REGION_WATER: Rect2 = Rect2(64, 16, 16, 16)
const REGION_FARM: Rect2 = Rect2(96, 64, 16, 16)
const REGION_HOUSE: Rect2 = Rect2(32, 144, 16, 16)
const REGION_GRANARY: Rect2 = Rect2(160, 144, 16, 16)
const REGION_ROOF: Rect2 = Rect2(176, 144, 16, 16)
const REGION_TREE_FRAME: Rect2 = Rect2(0, 0, 32, 34)

const AGENT_COLORS: Array[Color] = [
	Color(0.3, 0.7, 1.0),
	Color(1.0, 0.5, 0.5),
	Color(0.5, 1.0, 0.5),
	Color(1.0, 0.9, 0.4),
	Color(0.8, 0.5, 1.0),
]

@export var agent_view_scene: PackedScene = preload("res://view/agent_view.tscn")

var grid_data: GridData = null
var world_state: WorldState = null
var agent_views: Dictionary = {}


func setup(world: WorldState) -> void:
	world_state = world
	grid_data = world.grid_data
	queue_redraw()
	_spawn_agents()


func _spawn_agents() -> void:
	for child in get_children():
		if child.name.begins_with("Agent_"):
			child.queue_free()
	agent_views.clear()

	if world_state == null:
		return

	for i: int in range(world_state.agents.size()):
		var agent: AgentState = world_state.agents[i]
		var av = agent_view_scene.instantiate()
		av.name = "Agent_%s" % String(agent.id)
		add_child(av)
		var color: Color = AGENT_COLORS[i % AGENT_COLORS.size()]
		av.setup(agent, color)
		av.selected.connect(_on_agent_selected)
		agent_views[agent.id] = av


func update_views(step_duration: float) -> void:
	for aid: StringName in agent_views:
		var av = agent_views[aid]
		if is_instance_valid(av):
			av.update_view(step_duration)


func _on_agent_selected(agent: AgentState) -> void:
	agent_selected.emit(agent)


func _draw() -> void:
	if grid_data == null:
		return

	# Layer 1: Ubin dasar permukaan (tanah, air, ladang, lantai rumah, lumbung)
	for y: int in range(grid_data.height):
		for x: int in range(grid_data.width):
			var pos: Vector2i = Vector2i(x, y)
			var tile_type: StringName = grid_data.tiles.get(pos, &"")
			var rect: Rect2 = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var src_region: Rect2 = _region_for_ground(tile_type)
			draw_texture_rect_region(TEX_TILESET, rect, src_region)

	# Layer 2: Props & Dekorasi visual (Pohon, Batu, Tanaman Gandum, Kotak Lumbung, Atap Rumah)
	for y: int in range(grid_data.height):
		for x: int in range(grid_data.width):
			var pos: Vector2i = Vector2i(x, y)
			var tile_type: StringName = grid_data.tiles.get(pos, &"")
			_draw_tile_props(pos, tile_type)


func _draw_tile_props(pos: Vector2i, tile_type: StringName) -> void:
	var px: float = float(pos.x * TILE_SIZE)
	var py: float = float(pos.y * TILE_SIZE)

	match tile_type:
		GridData.TILE_FOREST:
			# Gambar pohon oak 32x34px Sunnyside World berdiri di atas tile
			var tree_rect: Rect2 = Rect2(px - 8.0, py - 18.0, 32.0, 34.0)
			draw_texture_rect_region(TEX_TREE, tree_rect, REGION_TREE_FRAME)
		GridData.TILE_MINE:
			# Gambar batu tambang 10x10px di tengah tile
			var rock_rect: Rect2 = Rect2(px + 3.0, py + 3.0, 10.0, 10.0)
			draw_texture_rect(TEX_ROCK, rock_rect, false)
		GridData.TILE_FARM:
			# Gambar tanaman gandum yang tumbuh di ladang
			var wheat_rect: Rect2 = Rect2(px + 1.5, py + 1.0, 13.0, 14.0)
			draw_texture_rect(TEX_WHEAT, wheat_rect, false)
		GridData.TILE_GRANARY:
			# Gambar peti lumbung kayu
			var crate_rect: Rect2 = Rect2(px, py, float(TILE_SIZE), float(TILE_SIZE))
			draw_texture_rect(TEX_CRATE, crate_rect, false)
		GridData.TILE_HOUSE:
			# Gambar aksen atap/struktur rumah
			var house_rect: Rect2 = Rect2(px, py, float(TILE_SIZE), float(TILE_SIZE))
			draw_texture_rect_region(TEX_TILESET, house_rect, REGION_ROOF)


func _region_for_ground(tile_type: StringName) -> Rect2:
	match tile_type:
		GridData.TILE_WATER:
			return REGION_WATER
		GridData.TILE_FARM:
			return REGION_FARM
		GridData.TILE_HOUSE:
			return REGION_HOUSE
		GridData.TILE_GRANARY:
			return REGION_GRANARY
		_:
			return REGION_GRASS
