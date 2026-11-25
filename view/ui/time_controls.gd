extends Control
## Panel kontrol kecepatan waktu simulasi (Pause, 1x, 2x, 4x, 8x).

signal speed_changed(speed: float)

var _last_speed: float = 1.0

@onready var _btn_pause: Button = $HBox/BtnPause
@onready var _btn_1x: Button = $HBox/Btn1x
@onready var _btn_2x: Button = $HBox/Btn2x
@onready var _btn_4x: Button = $HBox/Btn4x
@onready var _btn_8x: Button = $HBox/Btn8x


func _ready() -> void:
	if _btn_pause:
		_btn_pause.pressed.connect(func(): _set_speed(0.0))
	if _btn_1x:
		_btn_1x.pressed.connect(func(): _set_speed(1.0))
	if _btn_2x:
		_btn_2x.pressed.connect(func(): _set_speed(2.0))
	if _btn_4x:
		_btn_4x.pressed.connect(func(): _set_speed(4.0))
	if _btn_8x:
		_btn_8x.pressed.connect(func(): _set_speed(8.0))


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if SimClock.speed > 0.0:
					_last_speed = SimClock.speed
					_set_speed(0.0)
				else:
					_set_speed(_last_speed if _last_speed > 0.0 else 1.0)
			KEY_1:
				_set_speed(1.0)
			KEY_2:
				_set_speed(2.0)
			KEY_3:
				_set_speed(4.0)
			KEY_4:
				_set_speed(8.0)


func _set_speed(speed: float) -> void:
	SimClock.speed = speed
	speed_changed.emit(speed)
