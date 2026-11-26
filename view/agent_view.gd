extends Node2D
## Tampilan visual satu agent di layer view/.
## Hanya membaca state, tidak pernah menulis ke state.

signal selected(agent: AgentState)

const TILE_SIZE: int = 16

const TEX_IDLE: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/IDLE/base_idle_strip9.png"
)
const TEX_WALK: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/WALKING/base_walk_strip8.png"
)
const TEX_AXE: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/AXE/base_axe_strip10.png"
)
const TEX_MINING: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/MINING/base_mining_strip10.png"
)
const TEX_WATERING: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/WATERING/base_watering_strip5.png"
)
const TEX_DIG: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/DIG/base_dig_strip13.png"
)
const TEX_WAITING: Texture2D = preload(
	"res://assets/sunnyside_world/Characters/Human/WAITING/base_waiting_strip9.png"
)

var agent: AgentState = null
var _target_pixel_pos: Vector2 = Vector2.ZERO
var _current_tween: Tween = null
var _current_action_id: StringName = &""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Label


func setup(p_agent: AgentState, color_mod: Color = Color.WHITE) -> void:
	agent = p_agent
	position = _tile_to_pixel(agent.position)
	_target_pixel_pos = position

	if _sprite:
		_sprite.modulate = color_mod
	if _label:
		_label.text = String(agent.display_name)


func _ready() -> void:
	if agent != null:
		position = _tile_to_pixel(agent.position)
		_target_pixel_pos = position


func update_view(step_duration: float) -> void:
	if agent == null:
		return

	visible = agent.alive
	if not agent.alive:
		return

	var dest_pixel: Vector2 = _tile_to_pixel(agent.position)
	if dest_pixel != _target_pixel_pos:
		_target_pixel_pos = dest_pixel
		if _current_tween and _current_tween.is_valid():
			_current_tween.kill()
		_current_tween = create_tween()
		_current_tween.tween_property(self, "position", _target_pixel_pos, step_duration)

	_update_animation_frame()


func _update_animation_frame() -> void:
	if agent == null or _sprite == null:
		return

	var new_action_id: StringName = (
		agent.current_action.def.id if agent.current_action != null else &""
	)

	if new_action_id != _current_action_id:
		_current_action_id = new_action_id
		_sprite.frame = 0
		match _current_action_id:
			ActionLibrary.ID_MOVE, ActionLibrary.ID_WANDER:
				_sprite.texture = TEX_WALK
				_sprite.hframes = 8
			ActionLibrary.ID_WORK_FARM:
				_sprite.texture = TEX_DIG
				_sprite.hframes = 13
			ActionLibrary.ID_CHOP_WOOD:
				_sprite.texture = TEX_AXE
				_sprite.hframes = 10
			ActionLibrary.ID_MINE_ROCK:
				_sprite.texture = TEX_MINING
				_sprite.hframes = 10
			ActionLibrary.ID_WATER_CROP:
				_sprite.texture = TEX_WATERING
				_sprite.hframes = 5
			ActionLibrary.ID_SLEEP, ActionLibrary.ID_RECOVER:
				_sprite.texture = TEX_WAITING
				_sprite.hframes = 9
			_:
				_sprite.texture = TEX_IDLE
				_sprite.hframes = 9
	else:
		_sprite.frame = (_sprite.frame + 1) % _sprite.hframes


func _tile_to_pixel(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * TILE_SIZE + 8, tile_pos.y * TILE_SIZE + 8)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if position.distance_to(mouse_pos) <= float(TILE_SIZE):
			selected.emit(agent)
