extends GutTest


func _make_agent(p_id: String = "agent_000") -> AgentState:
	return AgentState.new(StringName(p_id), Vector2i(5, 5))


func test_init_defaults() -> void:
	var agent: AgentState = _make_agent()
	assert_eq(agent.id, &"agent_000")
	assert_eq(agent.position, Vector2i(5, 5))
	assert_true(agent.alive)
	assert_eq(agent.health, 100.0)
	assert_eq(agent.needs[&"hunger"], 100.0)
	assert_eq(agent.needs[&"energy"], 100.0)


func test_to_dict_contains_required_fields() -> void:
	var agent: AgentState = _make_agent()
	var d: Dictionary = agent.to_dict()
	assert_true(d.has("id"))
	assert_true(d.has("position"))
	assert_true(d.has("alive"))
	assert_true(d.has("needs"))
	assert_true(d.has("health"))


func test_hash_consistent() -> void:
	var a1: AgentState = _make_agent()
	var a2: AgentState = _make_agent()
	assert_eq(a1.compute_hash(), a2.compute_hash())


func test_hash_changes_with_state() -> void:
	var a1: AgentState = _make_agent()
	var hash_before: String = a1.compute_hash()
	a1.needs[&"hunger"] = 50.0
	var hash_after: String = a1.compute_hash()
	assert_ne(hash_before, hash_after)
