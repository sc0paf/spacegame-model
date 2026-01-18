extends RefCounted
class_name CrewModifier
## a workable placeholder?
var id: String
var display_name: String

var production_mult: float = 1.0

var happiness_delta: float = 0.0
var sanity_delta: float = 0.0


# Maybe make these expire?
var time_til_expire: float = -1.0

# flalt per sec
var sanity_per_sec: float = 0.0
var happiness_per_sec: float = 0.0
