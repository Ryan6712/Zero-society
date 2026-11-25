extends Node
## EventLog: mencatat event simulasi dan menyimpan ke JSONL.
## Autoload — tipis, hanya penghubung.

var events: Array[Dictionary] = []


func log_event(event: Dictionary) -> bool:
	if not EventSchema.validate(event):
		push_error("EventLog: event gagal validasi skema: %s" % str(event))
		return false
	events.append(event)
	return true


func log_all(new_events: Array[Dictionary]) -> void:
	for event: Dictionary in new_events:
		log_event(event)


func get_events_for_agent(agent_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Dictionary in events:
		if event.get("agent_id", "") == String(agent_id):
			result.append(event)
	return result


func save_to_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("EventLog: cannot open file: %s" % path)
		return
	for event: Dictionary in events:
		file.store_line(JSON.stringify(event))
	file.close()


func clear() -> void:
	events.clear()
