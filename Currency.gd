extends RefCounted
class_name Currency
## Main Currency def

var id: String
var display_name: String
var value: float
var cap: float
var is_unlocked: bool = false

signal updated

func _init(id: String, display_name: String, value: float, cap: float, is_unlocked: bool):
	self.id = id
	self.display_name = display_name
	self.value = value
	self.cap = cap
	self.is_unlocked = is_unlocked

func is_capped() -> bool:
	return value >= cap

func increase_cap(amount: float):
	cap += cap
	updated.emit()

func add(qty: float):
	value = clampf(value + qty, 0.0, cap)
	updated.emit()

func spend(qty: float):
	value = clampf(value - qty, 0.0, cap)
	updated.emit()

func to_dict() -> Dictionary:
	var data = {}
	data.id = id
	data.display_name = display_name
	data.value = value
	data.cap = cap
	return data

func from_dict(data: Dictionary):
	id = data.id
	display_name = data.display_name
	value = data.value
	cap = data.cap
