class_name ActionDef
extends Resource
## Definisi aksi sebagai data. Tidak mengandung logika eksekusi.

@export var id: StringName = &""
@export var display_name: String = ""
@export var duration_ticks: int = 1
@export var interruptible: bool = true
@export var required_location: StringName = &""
@export var energy_cost: float = 0.0
@export var hunger_cost: float = 0.0
