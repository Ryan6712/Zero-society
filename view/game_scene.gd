extends Node2D
## Scene utama game yang mengorkestrasikan tampilan visual dan input pemain.
## Menghubungkan SimClock dengan Simulation dan view layer.

const CONFIG_PATH: String = "res://data/default_world.json"

var simulation: Simulation = null

@onready var _world_view: Node2D = $WorldView
@onready var _hud: Control = $CanvasLayer/HUD
@onready var _time_controls: Control = $CanvasLayer/TimeControls
@onready var _inspector: Control = $CanvasLayer/AgentInspector
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	_init_simulation()
	if _world_view:
		_world_view.setup(simulation.world)
		_world_view.agent_selected.connect(_on_agent_selected)

	if _hud:
		_hud.update_hud(simulation.world)
		_hud.debug_add_food_requested.connect(_on_debug_add_food)

	if SimClock:
		SimClock.simulation = simulation
		SimClock.ticked.connect(_on_sim_ticked)

	_center_camera()


func _init_simulation() -> void:
	var file: FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not file:
		push_error("Gagal membaca config: %s" % CONFIG_PATH)
		return
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("Error JSON: %s" % json.get_error_message())
		return

	simulation = Simulation.new(json.data)


func _center_camera() -> void:
	if _camera != null and simulation != null and simulation.world.grid_data != null:
		var gd: GridData = simulation.world.grid_data
		_camera.position = Vector2(gd.width * 16 / 2, gd.height * 16 / 2)


func _on_sim_ticked(_tick: int) -> void:
	var step_duration: float = SimConst.SECONDS_PER_TICK / maxf(0.1, SimClock.speed)

	if _world_view:
		_world_view.update_views(step_duration)
	if _hud:
		_hud.update_hud(simulation.world)
	if _inspector and _inspector.visible:
		_inspector.update_inspector()


func _on_agent_selected(agent: AgentState) -> void:
	if _inspector:
		_inspector.inspect(agent)


func _on_debug_add_food(amount: int) -> void:
	if simulation != null:
		simulation.enqueue_command(AddFoodCommand.new(amount, &"debug_button"))
