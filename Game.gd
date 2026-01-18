extends Node
# Game - Main autoload

var GAME_SPEED := 0.0
var debug_speed := 1
var currencies: Dictionary[String, Currency] = {}

var population: Population
var available_nodes: Array[ResourceNode] = []
var nodes_by_id: Dictionary[String, ResourceNode] = {}
var next_node_id := 0

signal game_speed_set
signal refresh_workers

func _ready() -> void:
	currencies = CurrencyConstants.create_all()
	population = Population.new()
	available_nodes.clear()
	nodes_by_id.clear()

	for i in range(3):
		var res_node_id := "node-%03d" % next_node_id
		var new_node = get_rand_resource_node()
		var node_yid = new_node.id
		var node_def = new_node.def
		var node_qty = randf_range(node_def.min, node_def.max)
		var res_node = ResourceNode.new(res_node_id, node_yid, node_qty)
		nodes_by_id[res_node_id] = res_node
		available_nodes.append(res_node)
		next_node_id += 1
	population.create_worker("Jimbo")
	population.create_worker("Kelso")
	population.create_worker("Kip")

func try_assign_worker(crew_id: int, rn: ResourceNode) -> bool:
	var w = population.crew_by_id(crew_id)
	if w == null:
		return false
	if w.state != Crew.State.AVAILABLE:
		return false
	if not rn.can_assign():
		return false
	if rn.assigned_worker_ids.has(crew_id):
		return false
	
	w.state = Crew.State.ASSIGNED
	w.assigned_node_id = rn.node_id
	rn.assigned_worker_ids.append(crew_id)
	rn.updated.emit()
	emit_signal("refresh_workers")
	return true

func try_unassign_worker(crew_id: int, rn: ResourceNode) -> bool:
	var w = population.crew_by_id(crew_id)
	if w == null:
		return false
	if not rn.assigned_worker_ids.has(crew_id):
		return false
	rn.assigned_worker_ids.erase(crew_id)
	w.state = Crew.State.AVAILABLE
	w.assigned_node_id = ""
	rn.updated.emit()
	emit_signal("refresh_workers")
	return true

func set_game_speed(speed: float) -> void:
	GAME_SPEED = speed
	emit_signal("game_speed_set")

func get_res_gain(res_id: String) -> float:
	var gain := 0.0

	for rn: ResourceNode in available_nodes:
		if rn.yield_id != res_id:
			continue
		if rn.yield_qty <= 0.0:
			continue

		for wid: int in rn.assigned_worker_ids:
			var cr: Crew = population.crew_by_id(wid)
			if cr == null:
				continue
			if cr.state != Crew.State.ASSIGNED:
				continue

			gain += cr.get_production_rate() # per second
	return gain


func get_res_change(res_id):
	return get_res_gain(res_id) - population.get_res_drain_per_sec(res_id)

func tick_pop(dt):
	currencies["oxygen"].spend(population.get_res_drain_per_sec("oxygen") * dt)
	currencies["food"].spend(population.get_res_drain_per_sec("food") * dt)
	currencies["water"].spend(population.get_res_drain_per_sec("water") * dt)

func tick_nodes(dt: float) -> void:
	for rn: ResourceNode in available_nodes:
		if rn.yield_qty <= 0.0:
			continue
		
		var total_rate := 0.0
		for wid in rn.assigned_worker_ids:
			var cr: Crew = population.crew_by_id(wid)
			if cr == null:
				continue
			if cr.state != Crew.State.ASSIGNED:
				continue
			if cr.assigned_node_id != rn.node_id:
				continue
			
			total_rate += cr.get_production_rate()
		var mined :float= min(total_rate * dt, rn.yield_qty)
		if mined <= 0.0:
			continue
		rn.yield_qty -= mined
		rn.yield_ref.add(mined)
		rn.updated.emit()

func inc_cryo():
	population.inc_cryo()

func dec_cryo():
	population.inc_available()

func _process(delta: float) -> void:
	delta *= GAME_SPEED
	if GAME_SPEED <= 0.0:
		return
	tick_pop(delta)
	tick_nodes(delta)


func get_rand_resource_node() -> Dictionary:
	var total := 0
	for d in CurrencyConstants.NODE_DEFS.values():
		total += int(d.weight)
	var roll := randi_range(1, total)
	var running := 0
	for id in CurrencyConstants.NODE_DEFS.keys():
		running += int(CurrencyConstants.NODE_DEFS[id].weight)
		if roll <= running:
			return { "id": id, "def": CurrencyConstants.NODE_DEFS[id] }
	#failback
	return { "id": "oxygen", "def": CurrencyConstants.NODE_DEFS["oxygen"] }
	
	
	
