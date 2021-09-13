extends Spatial

onready var timer = $"Timer"
onready var enemy = load("res://Enemy.tscn")
var rng = RandomNumberGenerator.new()


export var delay = 5
export var onlyOnce = false
export var numberToSpawn = 3
var haveSpawned = 0

func _ready():
	timer.start(.1)
	var time = OS.get_datetime()
	rng.seed = time.hour + time.minute + time.second
	
func _process(delta):
	pass
	
func spawn():
	haveSpawned += 1
	if not onlyOnce && haveSpawned < numberToSpawn:
		timer.start(delay+rng.randf_range(-1,1))
	var e = enemy.instance()
	var parent = get_parent()
	parent.add_child(e)
	e.translation = translation
	e.translation.x += rng.randf_range(-1,1)
	e.translation.z += rng.randf_range(-1,1)
	e.translation.y = .5
	print(e.translation)

func _on_Timer_timeout():
	spawn()
