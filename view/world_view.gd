extends Node2D
## Visualisasi peta grid dan kumpulan AgentView.
## Membaca GridData dan WorldState tanpa menulis state.

signal agent_selected(agent: AgentState)

const TILE_SIZE: int = 16

const COLOR_GRASS: Color = Color(0.40, 0.70, 0.30)
const COLOR_FARM: Color = Color(0.55, 0.38, 0.22)
const COLOR_HOUSE: Color = Color(0.72, 0.45, 0.30)
const COLOR_GRANARY: Color = Color(0.85, 0.70, 0.35)
const COLOR_WATER: Color = Color(0.25, 0.55, 0.85)
const COLOR_DEFAULT: Color = Color(0.30, 0.30, 0.30)

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

	for y: int in range(grid_data.height):
		for x: int in range(grid_data.width):
			var pos: Vector2i = Vector2i(x, y)
			var tile_type: StringName = grid_data.tiles.get(pos, &"")
			var tile_color: Color = _color_for_tile(tile_type)

			var rect: Rect2 = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, tile_color, true)
			draw_rect(rect, Color(0, 0, 0, 0.15), false, 1.0)


func _color_for_tile(tile_type: StringName) -> Color:
	match tile_type:
		GridData.TILE_GRASS:
			return COLOR_GRASS
		GridData.TILE_FARM:
			return COLOR_FARM
		GridData.TILE_HOUSE:
			return COLOR_HOUSE
		GridData.TILE_GRANARY:
			return COLOR_GRANARY
		GridData.TILE_WATER:
			return COLOR_WATER
		_:
			return COLOR_DEFAULT
