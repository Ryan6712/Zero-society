extends Node2D

const ZOOM_STEP: float = 0.1
const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 3.0

var _drag_start: Vector2 = Vector2.ZERO
var _dragging: bool = false

@onready var _camera: Camera2D = $Camera2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_MIDDLE:
				if mb.pressed:
					_dragging = true
					_drag_start = mb.position
				else:
					_dragging = false
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_zoom(ZOOM_STEP)
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom(-ZOOM_STEP)

	elif event is InputEventMouseMotion and _dragging:
		var mm: InputEventMouseMotion = event
		_camera.position -= mm.relative / _camera.zoom


func _zoom(step: float) -> void:
	var new_zoom: float = clampf(_camera.zoom.x + step, ZOOM_MIN, ZOOM_MAX)
	_camera.zoom = Vector2(new_zoom, new_zoom)
