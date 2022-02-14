extends Spatial

onready var room = load("res://procgen/Room.tscn")
export var minRoomsToGenerate = 5
export var maxRoomsToGenerate = 10
var roomsToGenerate:int
var roomsGenerated = 0


func _ready():
	roomsToGenerate = Random.RunSeed.randi_range(minRoomsToGenerate,maxRoomsToGenerate)
	
	while roomsGenerated < roomsToGenerate:
		var r = room.instance()
		add_child(r)
		r.translation.x = roomsGenerated * r.roomSize.x
		roomsGenerated += 1
