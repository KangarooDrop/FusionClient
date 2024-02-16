extends CardDataBase

class_name CardDataGame

var hidden : bool = true

func canReveal() -> bool:
	return not hidden

func canFuseTo(other : CardDataBase) -> bool:
	return true
