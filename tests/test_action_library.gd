extends GutTest
## Tes unit untuk ActionLibrary.


func test_all_actions_registered() -> void:
	var actions: Array[ActionDef] = ActionLibrary.all()
	assert_eq(actions.size(), 5)


func test_get_individual_actions() -> void:
	var idle_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_IDLE)
	assert_not_null(idle_def)
	assert_eq(idle_def.id, ActionLibrary.ID_IDLE)

	var eat_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_EAT)
	assert_not_null(eat_def)
	assert_eq(eat_def.required_location, GridData.TILE_GRANARY)
	assert_false(eat_def.interruptible)

	var work_def: ActionDef = ActionLibrary.get_action(ActionLibrary.ID_WORK_FARM)
	assert_not_null(work_def)
	assert_eq(work_def.required_location, GridData.TILE_FARM)
	assert_eq(work_def.min_energy, 20.0)


func test_get_nonexistent_action() -> void:
	var def: ActionDef = ActionLibrary.get_action(&"nonexistent")
	assert_null(def)
