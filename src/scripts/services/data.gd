extends Node
class_name ReadData

static func load_json_file(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: %s" % path)
		return

	var json_text := file.get_as_text()
	file.close()
	
	return parse_file(json_text, path);

static func parse_file(json_text, path):
	var parse_result = JSON.parse_string(json_text)
	
	return parse_result;
	#if parse_result.error == OK:
		#return parse_result.result
	#else:
		#push_error("Failed to parser %s" % path)
		#return null
