
class_name FileIO

static func readJson(path : String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var text : String = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if data != null:
			return data
		else:
			print("Error parsing json file at ", path)
	else:
		print("Error finding json file at ", path)
	
	return {}
	

static func writeJson(path : String, data : Dictionary) -> bool:
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.file_exists(path):
		var text : String = JSON.stringify(data)
		file.store_string(text)
		file.close()
		return true
	return false
