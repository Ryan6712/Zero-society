extends GutTest
## Tes unit untuk EventLog.

var _event_log: Node


func before_each() -> void:
	var script: GDScript = load("res://autoload/event_log.gd")
	_event_log = script.new()


func after_each() -> void:
	if _event_log:
		_event_log.free()
		_event_log = null


func test_log_valid_event() -> void:
	var event: Dictionary = {
		&"tick": 1,
		&"event_type": "action_started",
		&"agent_id": "agent_000",
	}
	var success: bool = _event_log.log_event(event)
	assert_true(success)
	assert_eq(_event_log.events.size(), 1)


func test_reject_invalid_event() -> void:
	var event: Dictionary = {
		&"tick": 1,
	}
	var success: bool = _event_log.log_event(event)
	assert_false(success)
	assert_eq(_event_log.events.size(), 0)
	assert_push_error_count(1)


func test_get_events_for_agent() -> void:
	_event_log.log_event({&"tick": 1, &"event_type": "action_started", &"agent_id": "agent_000"})
	_event_log.log_event({&"tick": 2, &"event_type": "action_started", &"agent_id": "agent_001"})
	_event_log.log_event({&"tick": 3, &"event_type": "action_completed", &"agent_id": "agent_000"})

	var agent_0_events: Array[Dictionary] = _event_log.get_events_for_agent(&"agent_000")
	assert_eq(agent_0_events.size(), 2)

	var agent_1_events: Array[Dictionary] = _event_log.get_events_for_agent(&"agent_001")
	assert_eq(agent_1_events.size(), 1)


func test_clear_events() -> void:
	_event_log.log_event({&"tick": 1, &"event_type": "action_started", &"agent_id": "agent_000"})
	assert_eq(_event_log.events.size(), 1)
	_event_log.clear()
	assert_eq(_event_log.events.size(), 0)


func test_save_to_file() -> void:
	_event_log.log_event({&"tick": 1, &"event_type": "action_started", &"agent_id": "agent_000"})
	var temp_path: String = "user://test_events.jsonl"
	_event_log.save_to_file(temp_path)
	assert_true(FileAccess.file_exists(temp_path))

	var file: FileAccess = FileAccess.open(temp_path, FileAccess.READ)
	var line: String = file.get_line()
	file.close()

	var json: JSON = JSON.new()
	var err: Error = json.parse(line)
	assert_eq(err, OK)
	assert_eq(json.data.get("agent_id"), "agent_000")
