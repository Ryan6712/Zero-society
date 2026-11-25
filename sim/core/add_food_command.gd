class_name AddFoodCommand
extends Command
## Perintah dari UI atau debug untuk menambah stok makanan via jalur audit.

var amount: int = 0
var reason: StringName = &"debug_command"


func _init(p_amount: int = 1, p_reason: StringName = &"debug_command") -> void:
	amount = p_amount
	reason = p_reason


func execute(world: WorldState, events: Array[Dictionary]) -> void:
	world.modify_granary_food(amount, reason, &"user_command", events)
