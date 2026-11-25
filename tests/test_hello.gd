extends GutTest


func test_sanity() -> void:
	assert_true(true, "GUT is working")


func test_addition() -> void:
	assert_eq(2 + 2, 4)
