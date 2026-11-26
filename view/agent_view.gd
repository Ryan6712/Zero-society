extends Node2D
## Tampilan visual satu agent di layer view/.
## Hanya membaca state, tidak pernah menulis ke state.

signal selected(agent: AgentState)

const TILE_SIZE: int = 16

var agent: AgentState = null
var _target_pixel_pos: Vector2 = Vector2.ZERO
var _current_tween: Tween = null

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

	if agent.current_action != null:
		var act_id: StringName = agent.current_action.def.id
		match act_id:
			ActionLibrary.ID_MOVE, ActionLibrary.ID_WANDER:
				_sprite.frame = (_sprite.frame + 1) % _sprite.hframes
			ActionLibrary.ID_WORK_FARM:
				_sprite.frame = (_sprite.frame + 1) % _sprite.hframes
			ActionLibrary.ID_EAT:
				_sprite.frame = 0
			ActionLibrary.ID_SLEEP, ActionLibrary.ID_RECOVER:
				_sprite.frame = 1
			_:
				_sprite.frame = 0
	else:
		_sprite.frame = 0


func _tile_to_pixel(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * TILE_SIZE + 8, tile_pos.y * TILE_SIZE + 8)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if position.distance_to(mouse_pos) <= float(TILE_SIZE):
			selected.emit(agent)
