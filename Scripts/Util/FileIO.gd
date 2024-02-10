
class_name FileIO

const BOARD_PATH : String = "user://boards/"
const DECK_PATH : String = "user://decks/"
const CARDS_PATH : String = "res://shared/CardsData.csv"

static func getAllFiles(path : String) -> Array:
	var files : Array = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if not dir.current_is_dir():
				files.append(fileName)
			fileName = dir.get_next()
	return files

static func readCSV(path : String) -> Array:
	if FileAccess.file_exists(path):
		var data : Array = []
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var text : String = file.get_as_text()
		
		for line in text.split("\n"):
			data.append(line.split(','))
		file.close()
		
		return data
	else:
		print("Error finding csv file at ", path)
	
	return []


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
	var absPath : String = ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absPath.get_base_dir())
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.file_exists(path):
		var text : String = JSON.stringify(data)
		file.store_string(text)
		file.close()
		return true
	return false

####################################################################################################

const reconnectPath : String = "user://reconnect/last_match.json"
static func makeReconnectFile(ip : String, port : int) -> bool:
	var reconnectData : Dictionary = {}
	reconnectData['time'] = Util.getTimeAbsolute()
	reconnectData['ip'] = ip
	reconnectData['port'] = port
	
	var success : bool = FileIO.writeJson(reconnectPath, reconnectData)
	if success:
		print("Successfully saved reconnect file.")
	else:
		print("ERROR: could not save reconnect file.")
	return success

static func deleteReconnectFile() -> bool:
	var error : int = DirAccess.remove_absolute(reconnectPath)
	return error == OK

static func readReconnectFile() -> Dictionary:
	return readJson(reconnectPath)
