extends Node

func getTimeAbsolute() -> int:
	return Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
