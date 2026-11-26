extends PanelContainer
## Panel inspeksi rincian satu agent termasuk jejak keputusan (explainability).

signal closed

var inspected_agent: AgentState = null

@onready var _lbl_name: Label = $VBox/LblName
@onready var _lbl_action: Label = $VBox/LblAction
@onready var _bar_hunger: ProgressBar = $VBox/GridNeeds/BarHunger
@onready var _bar_energy: ProgressBar = $VBox/GridNeeds/BarEnergy
@onready var _bar_health: ProgressBar = $VBox/GridNeeds/BarHealth
@onready var _lbl_personality: Label = $VBox/LblPersonality
@onready var _vbox_trace: VBoxContainer = $VBox/VBoxTrace
@onready var _btn_close: Button = $VBox/BtnClose


func _ready() -> void:
	if _btn_close:
		_btn_close.pressed.connect(
			func():
				inspected_agent = null
				hide()
				closed.emit()
		)
	hide()


func inspect(agent: AgentState) -> void:
	inspected_agent = agent
	show()
	update_inspector()


func update_inspector() -> void:
	if inspected_agent == null or not is_visible_in_tree():
		return

	if _lbl_name:
		var status_str: String = "HIDUP" if inspected_agent.alive else "MATI"
		_lbl_name.text = (
			"%s (%s) — [%s]"
			% [inspected_agent.display_name, String(inspected_agent.id), status_str]
		)

	if _lbl_action:
		if inspected_agent.current_action != null:
			var def: ActionDef = inspected_agent.current_action.def
			_lbl_action.text = (
				"Aksi: %s (%d tick tersisa)"
				% [def.display_name, inspected_agent.current_action.ticks_left]
			)
		else:
			_lbl_action.text = "Aksi: Memilih keputusan..."

	if _bar_hunger:
		_bar_hunger.value = inspected_agent.needs.get(&"hunger", 0.0)
	if _bar_energy:
		_bar_energy.value = inspected_agent.needs.get(&"energy", 0.0)
	if _bar_health:
		_bar_health.value = inspected_agent.health

	if _lbl_personality:
		var ind: int = inspected_agent.personality.get(&"industrious", 50)
		var cau: int = inspected_agent.personality.get(&"cautious", 50)
		var adv: int = inspected_agent.personality.get(&"adventurous", 50)
		var lzy: int = inspected_agent.personality.get(&"lazy", 50)
		_lbl_personality.text = (
			"Sifat: Rajin=%d, Hati-hati=%d, Petualang=%d, Santai=%d" % [ind, cau, adv, lzy]
		)

	_update_trace_list()


func _update_trace_list() -> void:
	if _vbox_trace == null:
		return

	for child in _vbox_trace.get_children():
		child.queue_free()

	if inspected_agent == null:
		return

	var title_lbl: Label = Label.new()
	title_lbl.text = "Decision Trace (Alasan Keputusan):"
	title_lbl.add_theme_font_size_override("font_size", 11)
	_vbox_trace.add_child(title_lbl)

	if inspected_agent.last_decision_trace.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "  (Belum ada data evaluasi)"
		empty_lbl.add_theme_font_size_override("font_size", 10)
		_vbox_trace.add_child(empty_lbl)
		return

	for item: Dictionary in inspected_agent.last_decision_trace:
		var item_lbl: Label = Label.new()
		item_lbl.text = "  • %-10s : skor %.3f" % [item.get("id", ""), item.get("score", 0.0)]
		item_lbl.add_theme_font_size_override("font_size", 10)
		_vbox_trace.add_child(item_lbl)
