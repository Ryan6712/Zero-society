class_name ActionDef
extends Resource
## Definisi aksi sebagai data. Tidak mengandung logika eksekusi.

@export var id: StringName = &""
@export var display_name: String = ""
@export var duration_ticks: int = 1
@export var interruptible: bool = true
@export var required_location: StringName = &""
@export var min_energy: float = 0.0
@export var energy_cost_per_tick: float = 0.0


func _init(
	p_id: StringName = &"",
	p_display_name: String = "",
	p_duration_ticks: int = 1,
	p_interruptible: bool = true,
	p_required_location: StringName = &"",
	p_min_energy: float = 0.0,
	p_energy_cost_per_tick: float = 0.0
) -> void:
	id = p_id
	display_name = p_display_name
	duration_ticks = p_duration_ticks
	interruptible = p_interruptible
	required_location = p_required_location
	min_energy = p_min_energy
	energy_cost_per_tick = p_energy_cost_per_tick
