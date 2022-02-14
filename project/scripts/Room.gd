extends Spatial

onready var roomGeo = $"Navigation/NavigationMeshInstance/GridMap"
onready var navMesh = $"Navigation/NavigationMeshInstance"
onready var player = $"Player"

var roomSize = Vector2(11,11)

func _ready():
	generateRoom()
	#placePlayer()

func generateRoom():
	for x in roomSize.x:
		for y in roomSize.y:
			roomGeo.set_cell_item(x,0,y,1)
			if x == 0 or x == roomSize.x-1:
				roomGeo.set_cell_item(x,1,y,1)
				roomGeo.set_cell_item(x,2,y,1)
			if y == 0 or y == roomSize.y-1:
				roomGeo.set_cell_item(x,1,y,1)
				roomGeo.set_cell_item(x,2,y,1)
				
func placePlayer():
	player.global_translate(to_global(roomGeo.map_to_world(roomSize.x/2, 1, roomSize.y/2)))
