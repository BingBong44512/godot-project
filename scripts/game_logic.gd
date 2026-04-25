extends Node2D

const SUNLIGHT = 5

const P1 := SUNLIGHT * 10 + 5
const P2 := SUNLIGHT * 100 + 10

var toads :=0
var eagle:=0
var owl:=0
var bear:=0
var wolf := 0
var bison := 0
var elk := 0
var snake :=0
var grass :=0
var money := 100
var timer := 0.0

@export var health:=0:
	get:
		var energy = SUNLIGHT * grass
		if P1 * (toads+elk+bison+snake) > energy:
			energy -= P1 * (toads+elk+bison+snake)
		else:
			energy += P1 * (toads+elk+bison+snake)
		if P2 * (eagle+owl+bear+wolf)> energy:
			energy -= P2 * (eagle+owl+bear+wolf)
		else:	
			energy += P2 * (eagle+owl+bear+wolf)
		return energy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer +=delta
	if timer>=10.0:
		timer =0
		money += health/5
	
