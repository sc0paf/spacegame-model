extends RefCounted
class_name Population

var next_id: int = 0
var workers: Array[Crew] = []
var by_id: Dictionary[int, Crew] = {}

func create_worker(display_name: String) -> void:
	var w := Crew.new()
	w.id = next_id
	w.display_name = display_name
	workers.append(w)
	by_id[w.id] = w
	next_id += 1

func crew_by_id(id: int) -> Crew:
	return by_id[id]

func get_total() -> int:
	return workers.size()

func count_by_state(state: Crew.State) -> int:
	var n := 0
	for w: Crew in workers:
		if w.state == state:
			n+=1
	return n
	
func get_available_count() -> int:
	return count_by_state(Crew.State.AVAILABLE)

func get_cryo_count() -> int:
	return count_by_state(Crew.State.CRYO)

func get_assigned_count() -> int:
	return count_by_state(Crew.State.ASSIGNED)

func get_res_drain_per_sec(res_id: String) -> float:
	var total := 0.0
	for w: Crew in workers:
		total += w.get_drain_per_second(res_id)
	return total
