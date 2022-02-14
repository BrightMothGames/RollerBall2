extends Spatial

var graphNodes
var startNode
var inNetwork = []
onready var rng = RandomNumberGenerator.new()
onready var Graph = $"Graph"
onready var grid = $"Grid"
onready var rooms = $"Rooms"
onready var GridNode = load("res://tiles/debugTile.tscn")
onready var gridMap = $"GridMap"
var gridNodes

func createGraph(w, h,default):
	var graph = []

	for x in range(w):
		var col = []
		col.resize(h)
		graph.append(col)
	
	for x in w:
		for y in h:
			graph[x][y] = default
	
	return graph

func _ready():
	graphNodes = createGraph(11, 11, null)
	gridNodes = createGraph(50,50, null)
	
	for i in Graph.get_children():
			if i.has_method("connectToParentGraph"):
				i.connectToParentGraph()
				i.add_to_group("graphNode")
	
	run()
	print("ran")
		
func _process(delta):
	if Input.is_action_just_released("Fire"):
		get_tree().reload_current_scene()
		print("reload")


func getNeighbors(node):
	var x=node.pos.x
	var y=node.pos.y
	var neighbors = []
	if node.type != "Room":
		return neighbors
	
	if graphNodes[x-1][y].type != "Edge":
		neighbors.append(graphNodes[x-2][y])
	else:
		neighbors.append(graphNodes[x-1][y])
	if graphNodes[x+1][y].type != "Edge":
		neighbors.append(graphNodes[x+2][y])
	else:
		neighbors.append(graphNodes[x+1][y])
	
	if graphNodes[x][y-1].type != "Edge":
		neighbors.append(graphNodes[x][y-2])
	else:
		neighbors.append(graphNodes[x][y-1])	
		
	if graphNodes[x][y+1].type != "Edge":
		neighbors.append(graphNodes[x][y+2])
	else:
		neighbors.append(graphNodes[x][y+1])	
		
	return neighbors

func connectTwoNodes(nodeA,nodeB):
	if nodeA.type != "Room":
		return
	
	nodeA.add_to_group("network")
	
	if nodeB.type == "Edge":
		if nodeA.pos.x == nodeB.pos.x:
			if nodeA.pos.y > nodeB.pos.y:
				nodeA.connectedNorth = nodeB
			else:
				nodeA.connectedSouth = nodeB
		else:
			if nodeA.pos.x > nodeB.pos.x:
				nodeA.connectedWest = nodeB
			else:
				nodeA.connectedEast = nodeB

	else:
		nodeB.add_to_group("network")

		if nodeA.pos.x == nodeB.pos.x:
			if nodeA.pos.y > nodeB.pos.y:
				var n = graphNodes[nodeA.pos.x][nodeA.pos.y-1]
				n.type = "Door"
				n.add_to_group("door")
				n.radius = .06
				n.translation = lerp(nodeA.translation,nodeB.translation,.5)
				nodeA.connectedNorth = graphNodes[nodeA.pos.x][nodeA.pos.y-1]
				nodeB.connectedSouth = graphNodes[nodeB.pos.x][nodeB.pos.y+1]
			else:
				var n = graphNodes[nodeA.pos.x][nodeA.pos.y+1]
				n.type = "Door"
				n.add_to_group("door")
				n.radius = .06
				n.translation = lerp(nodeA.translation,nodeB.translation,.5)
				nodeA.connectedSouth = graphNodes[nodeA.pos.x][nodeA.pos.y+1]
				nodeB.connectedNorth = graphNodes[nodeB.pos.x][nodeB.pos.y-1]
		else:
			if nodeA.pos.x > nodeB.pos.x:
				var n = graphNodes[nodeA.pos.x-1][nodeA.pos.y]
				n.type = "Door"
				n.add_to_group("door")
				n.radius = .06
				n.translation = lerp(nodeA.translation,nodeB.translation,.5)
				nodeA.connectedWest = graphNodes[nodeA.pos.x-1][nodeA.pos.y]
				nodeB.connectedEast = graphNodes[nodeB.pos.x+1][nodeB.pos.y]
			else:
				var n = graphNodes[nodeA.pos.x+1][nodeA.pos.y]
				n.type = "Door"
				n.add_to_group("door")
				n.radius = .06
				n.translation = lerp(nodeA.translation,nodeB.translation,.5)
				nodeA.connectedEast = graphNodes[nodeA.pos.x+1][nodeA.pos.y]
				nodeB.connectedWest = graphNodes[nodeB.pos.x-1][nodeB.pos.y]
	
	
func run():
	Draw.Lines = []
	rng.randomize()
		
	for i in Graph.get_children():
		var mag = .5
		i.translation.x += rng.randf_range(-mag,mag)
		i.translation.z += rng.randf_range(-mag,mag)
	
	var rand = rng.randi_range(0,8)
	match rand:
		0:
			startNode = graphNodes[1][1]
		1:
			startNode = graphNodes[3][1]
		2:
			startNode = graphNodes[5][1]
		3:
			startNode = graphNodes[7][1]
		4:
			startNode = graphNodes[9][1]
		5:
			startNode = graphNodes[1][3]
		6:
			startNode = graphNodes[1][5]
		7:
			startNode = graphNodes[1][7]
		8:
			startNode = graphNodes[1][9]
	
	startNode = graphNodes[rng.randi_range(0,4)*2+1][rng.randi_range(0,4)*2+1]
	
	startNode.get_child(0).material = load("res://shaders/green.tres")
	startNode.add_to_group("network")
	inNetwork.append(startNode)
	
	var n = getNeighbors(startNode)

	for i in n.size():
		connectTwoNodes(startNode,n[i])
		n[i].get_child(0).material = load("res://shaders/purple.tres")

	var randomSet = get_tree().get_nodes_in_group("network")
	randomSet.shuffle()

	var connectChance = .3

	for i in randomSet:
		if !i.connectedNorth and i.pos.y-2>=0 and rng.randf() > connectChance:
			if !graphNodes[i.pos.x][i.pos.y-2].is_in_group("network"):
				connectTwoNodes(i,graphNodes[i.pos.x][i.pos.y-2])
			else:
				if rng.randf() < connectChance:
					connectTwoNodes(i,graphNodes[i.pos.x][i.pos.y-2])
			
		if !i.connectedSouth and i.pos.y+2<=10 and rng.randf() > connectChance:
			if !graphNodes[i.pos.x][i.pos.y+2].is_in_group("network"):
				connectTwoNodes(i,graphNodes[i.pos.x][i.pos.y+2])
			else:
				if rng.randf() < connectChance:
					connectTwoNodes(i,graphNodes[i.pos.x][i.pos.y+2])
					
		if !i.connectedEast and i.pos.x+2<=10 and rng.randf() > connectChance:
			if !graphNodes[i.pos.x+2][i.pos.y].is_in_group("network"):
				connectTwoNodes(i,graphNodes[i.pos.x+2][i.pos.y])
			else:
				if rng.randf() < connectChance:
					connectTwoNodes(i,graphNodes[i.pos.x+2][i.pos.y])
					
		if !i.connectedWest and i.pos.x-2>=0 and rng.randf() > connectChance:
			if !graphNodes[i.pos.x-2][i.pos.y].is_in_group("network"):
				connectTwoNodes(i,graphNodes[i.pos.x-2][i.pos.y])
			else:
				if rng.randf() < connectChance:
					connectTwoNodes(i,graphNodes[i.pos.x-2][i.pos.y])
			
	for i in get_tree().get_nodes_in_group("network"):
		if i.has_method("drawConnection"):
			i.drawConnection()

	
#	var r = CSGPolygon.new()
#	r.rotation.x = 90
#	r.depth = .01
#	r.set_polygon(getBounds(startNode))
#	startNode.add_child(r)
	
#	for i in get_tree().get_nodes_in_group("network"):
#		var r = CSGPolygon.new()
#		r.rotation.x = 90
#		r.depth = .01
#		r.add_to_group("room")
#		r.material = load("res://shaders/purple.tres")
#		#r.set_polygon(getBounds(i))
#		i.add_child(r)

	for i in get_tree().get_nodes_in_group("room"):
		i.get_parent().setColor(Color.white)

	
#	for x in 50:
#		for y in 50:
#			#for i in get_tree().get_nodes_in_group("network"):
#			grid.set_cell_item(x,-2,y,2,0)
#
#	var meshArray = grid.get_meshes()
#
#	for i in meshArray.size()/2:
#			var mesh = meshArray[i*2+1]
#			mesh.material.albedo_color = Color.from_hsv(rng.randf(),1,1)

	for x in 50:
		for y in 50:
			var newGridNode = GridNode.instance()
			grid.add_child(newGridNode)
			newGridNode.pos = Vector2(x,y)
			gridNodes[x][y]=newGridNode
			newGridNode.add_to_group("gridNode")
			newGridNode.translation = Vector3((x as float/4-1),0,(y as float/4-1))
	
	var networkNodes = get_tree().get_nodes_in_group("network")
	
#	var graphNodes = []
#	for i in get_tree().get_nodes_in_group("graphNode"):
#		if i.type == "Room":
#			graphNodes.append(i)
	
	for i in get_tree().get_nodes_in_group("graphNode"):
		i.color = Color.from_hsv(rng.randf(),1,1,1)
		#print(i.color)
	
	for i in get_tree().get_nodes_in_group("gridNode"):
		var closest = Graph.get_child(0)
		for ii in get_tree().get_nodes_in_group("rooms"):
			if i.translation.distance_to(ii.translation) < i.translation.distance_to(closest.translation):
				closest = ii
		i.material_override.set_shader_param("albedo" , closest.color)
		i.belongsToRoom = closest.roomID
		
	var filez = File.new()
	filez.open("res://savearray.txt",File.READ)
	var sparray = filez.get_var()
	filez.close()

	for i in get_tree().get_nodes_in_group("gridNode"):
		#i.visible = false
		#print(sparray.size())
		var x = i.pos.x
		var y = i.pos.y
		var pos2d = Vector2(x as float/4,y as float/4)-Vector2(1,1)
		if x < 49 and y < 49:
			#gridNodes[x][y].material_override.set_shader_param("albedo" , Color.from_hsv(i/sparray.size() as float,1,1,1))
			var curRoomID = gridNodes[x][y].belongsToRoom
			var neighbors = []
			for yy in 2:
				for xx in 2:
					if gridNodes[xx+x][yy+y].belongsToRoom != curRoomID:
						var rid = gridNodes[xx+x][yy+y].belongsToRoom
						if not neighbors.has(graphNodes[rid.x][rid.y]):
							print("corner found")
							neighbors.append(graphNodes[rid.x][rid.y])
						
			if neighbors.size() > 1:
				#i.get_child(1).visible = true
				#if not graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.has(Vector2(x,y)):
				graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.append(pos2d)
				for ii in neighbors:
					#if not ii.voronoiPoints.has(Vector2(x,y)):
					ii.voronoiPoints.append(pos2d)
					
		if y == 0 or y == 49:
			#gridNodes[x][y].material_override.set_shader_param("albedo" , Color.from_hsv(i/sparray.size() as float,1,1,1))
			var curRoomID = gridNodes[x][y].belongsToRoom
			var neighbors = []
			for xx in 2:
				if gridNodes[clamp(xx+x,0,49)][y].belongsToRoom != curRoomID:
					var rid = gridNodes[xx+x][y].belongsToRoom
					if not neighbors.has(graphNodes[rid.x][rid.y]):
						print("corner found")
						neighbors.append(graphNodes[rid.x][rid.y])
						
			if neighbors.size() > 0:
				#i.get_child(1).visible = true
				#if not graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.has(Vector2(x,y)):
				graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.append(pos2d)
				for ii in neighbors:
					#if not ii.voronoiPoints.has(Vector2(x,y)):
					ii.voronoiPoints.append(pos2d)
					
		if x == 0 or x == 49:
			#gridNodes[x][y].material_override.set_shader_param("albedo" , Color.from_hsv(i/sparray.size() as float,1,1,1))
			var curRoomID = gridNodes[x][y].belongsToRoom
			var neighbors = []
			for yy in 2:
				if gridNodes[x][clamp(yy+y,0,49)].belongsToRoom != curRoomID:
					var rid = gridNodes[x][yy+y].belongsToRoom
					if not neighbors.has(graphNodes[rid.x][rid.y]):
						print("corner found")
						neighbors.append(graphNodes[rid.x][rid.y])
						
			if neighbors.size() > 0:
				#i.get_child(1).visible = true
				#if not graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.has(Vector2(x,y)):
				graphNodes[i.belongsToRoom.x][i.belongsToRoom.y].voronoiPoints.append(pos2d)
				for ii in neighbors:
					#if not ii.voronoiPoints.has(Vector2(x,y)):
					ii.voronoiPoints.append(pos2d)
					

	
	for node in get_tree().get_nodes_in_group("network"):
		#print(str(node.roomID) + " with points" + str(node.voronoiPoints))
		node.drawRoom()
		#pass

	grid.visible = false
#	rooms.scale /= 4
#	rooms.translation -= Vector3(1,0,1)

	for y in 149:
		for x in 149:
			gridMap.set_cell_item(x-10,0,y-10,1)
			for node in get_tree().get_nodes_in_group("network"):
				var m = gridMap.map_to_world(x-10,0,y-10)
				m = Vector2(m.x,m.z)
				if Geometry.is_point_in_polygon(m, node.roomBounds):
					gridMap.set_cell_item(x-10,0,y-10,2)
					
				
				if m.x > node.roomBounds[0].x-.04 and m.x-.1 < node.roomBounds[0].x-.04 and m.y > node.roomBounds[0].y-.04 and m.y < node.roomBounds[2].y+.04:
					gridMap.set_cell_item(x-10,0,y-10,1)
				
				if m.x < node.roomBounds[2].x+.04 and m.x+.1 > node.roomBounds[2].x+.04 and m.y > node.roomBounds[0].y-.04 and m.y < node.roomBounds[2].y+.04:
					gridMap.set_cell_item(x-10,0,y-10,1)
				
				if m.y > node.roomBounds[0].y-.04 and m.y-.1 < node.roomBounds[0].y-.04 and m.x > node.roomBounds[0].x and m.x < node.roomBounds[2].x:
					gridMap.set_cell_item(x-10,0,y-10,1)
				
				if m.y < node.roomBounds[2].y+.04 and m.y+.1 > node.roomBounds[2].y+.04 and m.x > node.roomBounds[0].x and m.x < node.roomBounds[2].x:
					gridMap.set_cell_item(x-10,0,y-10,1)
	
	
	for node in get_tree().get_nodes_in_group("network"):
		if node.connectedNorth:
			print("connected north")
			var np = Vector2(node.translation.x,node.translation.z)
			var np2 = np
			var target = Vector2(graphNodes[node.pos.x][node.pos.y-1].translation.x,graphNodes[node.pos.x][node.pos.y-1].translation.z)
			var offset = .1
			
			while np.x > node.translation.x-2:
				print("wiggle")
				np2 = np
				while np2.y > target.y:
					var m = gridMap.world_to_map(Vector3(np2.x,0,np2.y))
					print("north " + str(m.x) + "," + str(m.z) )
					if gridMap.get_cell_item(m.x,m.y,m.z)==1 and gridMap.get_cell_item(m.x,m.y,m.z-1)==2 and gridMap.get_cell_item(m.x,m.y,m.z+1)==2:
						print("door")
						gridMap.set_cell_item(m.x,m.y,m.z,2)
						np.x -= 10
					np2.y -= .05
				np.x += offset
				offset *= -1.5

		if node.connectedWest:
			print("connected west")
			var np = Vector2(node.translation.x,node.translation.z)
			var np2 = np
			var target = Vector2(graphNodes[node.pos.x-1][node.pos.y].translation.x,graphNodes[node.pos.x-1][node.pos.y].translation.z)
			var offset = .1
			
			while np.y > node.translation.y-2:
				print("wiggle")
				np2 = np
				while np2.x > target.x:
					var m = gridMap.world_to_map(Vector3(np2.x,0,np2.y))
					print("west " + str(m.x) + "," + str(m.z) )
					if gridMap.get_cell_item(m.x,m.y,m.z)==1 and gridMap.get_cell_item(m.x-1,m.y,m.z)==2 and gridMap.get_cell_item(m.x+1,m.y,m.z)==2:
						print("door")
						gridMap.set_cell_item(m.x,m.y,m.z,2)
						np.y -= 10
					np2.x -= .05
				np.y += offset
				offset *= -1.5

func getBounds(node):
	var n
	var s
	var e
	var w
	
	n=graphNodes[node.pos.x][node.pos.y-1].translation - node.translation

	s=graphNodes[node.pos.x][node.pos.y+1].translation - node.translation

	e=graphNodes[node.pos.x+1][node.pos.y].translation - node.translation

	w=graphNodes[node.pos.x-1][node.pos.y].translation - node.translation

	
	var minx = min(min(n.x,s.x),min(e.x,w.x))
	var maxx = max(max(n.x,s.x),max(e.x,w.x))
	var miny = min(min(n.z,s.z),min(e.z,w.z))-.11
	var maxy = max(max(n.z,s.z),max(e.z,w.z))+.11
	print(PoolVector2Array([Vector2(minx,miny),Vector2(minx,maxy),Vector2(maxx,maxy),Vector2(maxx,miny)]))
	return PoolVector2Array([Vector2(minx,miny),Vector2(minx,maxy),Vector2(maxx,maxy),Vector2(maxx,miny)])
	
