extends Control
## HUD: Menampilkan informasi global dunia (Hari, Jam, Stok, Populasi, Debug).

signal debug_add_food_requested(amount: int)

@onready var _lbl_time: Label = $VBox/LblTime
@onready var _lbl_status: Label = $VBox/LblStatus
@onready var _lbl_food: Label = $VBox/LblFood
@onready var _btn_add_food: Button = $VBox/BtnAddFood


func _ready() -> void:
	if _btn_add_food:
		_btn_add_food.pressed.connect(func(): debug_add_food_requested.emit(5))


func update_hud(world: WorldState) -> void:
	if world == null:
		return

	var day_num: int = (world.tick / SimConst.TICKS_PER_DAY) + 1
	var hour_float: float = world.hour_of_day()
	var hours: int = int(hour_float)
	var minutes: int = int((hour_float - float(hours)) * 60.0)

	if _lbl_time:
		_lbl_time.text = (
			"Hari %d — %02d:%02d [%s]"
			% [day_num, hours, minutes, String(world.day_phase).to_upper()]
		)

	var alive_count: int = 0
	for agent: AgentState in world.agents:
		if agent.alive:
			alive_count += 1

	if _lbl_status:
		_lbl_status.text = "Populasi: %d / %d" % [alive_count, world.agents.size()]

	if _lbl_food:
		_lbl_food.text = "Lumbung Makanan: %d" % world.granary_food
