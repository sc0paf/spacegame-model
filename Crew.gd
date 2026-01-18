extends RefCounted
class_name Crew

var id: int
var display_name: String

enum State { CRYO, AVAILABLE, ASSIGNED }
var state: State = State.AVAILABLE

var happiness: float = 1.0 # normalize
var sanity: float = 1.0 # normalize
var base_production_rate: float = 1.0

var modifiers: Array[CrewModifier] = []

var assigned_node_id: String = ""

func get_production_rate() -> float:
	## can add arg & modifiers here later.. ?
	return base_production_rate * get_production_mult()

func get_production_mult() -> float:
	var mult := 1.0
	for m in modifiers:
		mult *= m.production_mult
	return mult

func get_drain_per_second(res_id: String) -> float:
	match res_id:
		"oxygen":
			return 0.02 if state == State.CRYO else 0.10
		"water":
			return 0.01 if state == State.CRYO else 0.06
		"food":
			return 0.00 if state == State.CRYO else 0.05
		_:
			return 0.0

func is_in_cryo() -> bool:
	return state == State.CRYO

func is_available() -> bool:
	return state == State.AVAILABLE

func is_assigned() -> bool:
	return state == State.ASSIGNED
