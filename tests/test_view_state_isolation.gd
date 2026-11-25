extends GutTest
## Tes isolasi: membuktikan bahwa view layer tidak pernah mengubah state simulasi (ADR-002).

const CONFIG: Dictionary = {
	"seed": 42,
	"agent_count": 3,
	"granary_food": 20,
	"grid":
	{
		"width": 6,
		"height": 6,
		"tiles":
		[
			["grass", "grass", "farm", "farm", "grass", "grass"],
			["grass", "house", "grass", "granary", "grass", "grass"],
			["grass", "grass", "water", "water", "grass", "grass"],
			["grass", "grass", "water", "water", "grass", "grass"],
			["grass", "house", "grass", "grass", "farm", "grass"],
			["grass", "grass", "grass", "grass", "grass", "grass"],
		],
	},
	"agent_spawn_positions": [[0, 0], [1, 0], [0, 1]],
}


func test_view_does_not_alter_sim_hash() -> void:
	# 1. Jalankan headless murni tanpa Node view
	var sim_headless: Simulation = Simulation.new(CONFIG.duplicate(true))
	for t: int in range(300):
		sim_headless.step()
	var hash_headless: String = sim_headless.compute_hash()

	# 2. Jalankan dengan komponen view yang membaca state tiap tick
	var sim_view: Simulation = Simulation.new(CONFIG.duplicate(true))
	var world_view: Node2D = load("res://view/world_view.gd").new()
	add_child(world_view)
	world_view.setup(sim_view.world)

	for t: int in range(300):
		sim_view.step()
		world_view.update_views(0.1)

	var hash_view: String = sim_view.compute_hash()
	world_view.queue_free()

	assert_eq(hash_view, hash_headless, "State hash harus identik dengan atau tanpa view")


func test_command_queue_audits_food_change() -> void:
	var sim: Simulation = Simulation.new(CONFIG.duplicate(true))
	var initial_food: int = sim.world.granary_food

	sim.enqueue_command(AddFoodCommand.new(5, &"debug_bonus"))
	sim.step()

	assert_eq(sim.world.granary_food, initial_food + 5)
	assert_true(sim.world.is_food_conserved(), "Konservasi makanan tetap terpenuhi lewat command")
