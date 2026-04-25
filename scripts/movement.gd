extends Node2D

const SPEED = 60
var thought
var animal := ""
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	animated_sprite_2d.play(animal)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !(thought) or (position.x<thought.x+10 and position.x>thought.x-10  and position.y<thought.y+10 and position.y>thought.y-10):
		thought = Vector2(randi()%1000,randi()%1000)
	if thought.x>position.x:
		position.x+= SPEED * delta
	else:
		position.x-= SPEED * delta
	if thought.y>position.y:
		position.y+= SPEED * delta
	else:
		position.y-= SPEED * delta
