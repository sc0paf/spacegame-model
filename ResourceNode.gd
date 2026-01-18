extends RefCounted
class_name ResourceNode
## Class definition for ResourceNode

# Adding multiple resource outputs likely means .. 
# [ { Currency: Pct }, { Currency: Pct } ] .. maybe?
# TBD.
var max_workers := 2

var yield_id: String
var yield_ref: Currency
var yield_qty: float
var node_id: String

var assigned_worker_ids: Array[int] = []

signal updated

func _init(
	p_node_id: String,
	p_yield_id: String,
	yield_qty: float = 100.0,
):
	self.node_id = p_node_id
	self.yield_id = p_yield_id
	self.yield_ref = Game.currencies[p_yield_id]
	self.yield_qty = yield_qty

func get_assigned_count() -> int:
	return assigned_worker_ids.size()

func can_assign() -> bool:
	return get_assigned_count() < max_workers and yield_qty > 0.0
