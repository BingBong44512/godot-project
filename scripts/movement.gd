extends Node2D

const SPEED = 60
const MAX_HUNGER = 100.0
const REPRODUCE_THRESHOLD = 80.0
const HUNGER_DECAY = 2.0 # Per second

var thought
var animal := ""
var hunger = 50.0
var repro_timer = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var world = get_parent() # TileMapLayer

func _ready():
	animated_sprite_2d.play(animal)
	add_to_group("animals")
	add_to_group(animal)
	if is_predator():
		add_to_group("predators")
	else:
		add_to_group("herbivores")

func _physics_process(delta: float) -> void:
	# Hunger decay
	hunger -= HUNGER_DECAY * delta
	repro_timer += delta
	
	# Visual Juice: Breathing effect
	var breathe = 1.0 + (sin(Time.get_ticks_msec() * 0.005) * 0.05)
	animated_sprite_2d.scale = Vector2(breathe, breathe)
	
	if hunger <= 0:
		die()
		return

	# Movement logic
	if !(thought) or (position.distance_to(thought) < 15):
		find_new_thought()

	move_towards_thought(delta)
	check_interactions()

func find_new_thought():
	# Predators look for prey
	if is_predator() and hunger < 80:
		var preys = get_tree().get_nodes_in_group("herbivores")
		if preys.size() > 0:
			var closest = preys[0]
			for p in preys:
				if position.distance_to(p.position) < position.distance_to(closest.position):
					closest = p
			if position.distance_to(closest.position) < 400:
				thought = closest.position
				return

	# Herbivores look for grass
	if hunger < 70 and world is TileMapLayer:
		var my_pos = world.local_to_map(position)
		for x in range(-4, 5):
			for y in range(-4, 5):
				var target = my_pos + Vector2i(x, y)
				if world.get_cell_source_id(target) == GodLogic.grass_id:
					thought = world.map_to_local(target)
					return
	
	thought = position + Vector2(randf_range(-300, 300), randf_range(-300, 300))

func is_predator():
	return animal in ["wolf", "bear", "eagle", "owl"]

func check_interactions():
	if world is TileMapLayer:
		var map_pos = world.local_to_map(position)
		
		# PREDATOR HUNTING
		if is_predator() and hunger < 90:
			for other in get_tree().get_nodes_in_group("herbivores"):
				if position.distance_to(other.position) < 20:
					hunger = MAX_HUNGER
					other.die()
					print(animal, " hunted ", other.animal)
					return

		# HERBIVORE EATING / FERTILIZING
		if world.get_cell_source_id(map_pos) == GodLogic.grass_id:
			if hunger < 90:
				hunger += 20
				# Chance to kill grass
				var is_watered = GodLogic.watered_tiles.has(map_pos)
				if randf() < (0.01 if is_watered else 0.08):
					world.set_cell(map_pos, GodLogic.dead_grass_id, Vector2i(0, 0))
					if "grass" in get_tree().current_scene: get_tree().current_scene.grass -= 1
		
		# SPECIAL ROLE: Small animals fertilize dead grass
		elif animal in ["toad", "snake"] and world.get_cell_source_id(map_pos) == GodLogic.dead_grass_id:
			if randf() < 0.05:
				world.set_cell(map_pos, GodLogic.grass_id, Vector2i(0, 0))
				if "grass" in get_tree().current_scene: get_tree().current_scene.grass += 1

	# REPRODUCTION (unchanged)
	if hunger > REPRODUCE_THRESHOLD and repro_timer > 15.0:
		for other in get_tree().get_nodes_in_group(animal):
			if other != self and position.distance_to(other.position) < 30:
				if other.hunger > REPRODUCE_THRESHOLD:
					reproduce()
					break

func reproduce():
	repro_timer = 0.0
	hunger -= 40 # Cost of reproduction
	var game = get_tree().current_scene
	if animal in game:
		game.set(animal, game.get(animal) + 1)
		var baby = load("res://scenes/animal.tscn").instantiate()
		baby.animal = animal
		baby.position = position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		world.add_child(baby)
		print(animal, " reproduced!")

func die():
	var game = get_tree().current_scene
	if animal in game:
		game.set(animal, game.get(animal) - 1)
	queue_free()
