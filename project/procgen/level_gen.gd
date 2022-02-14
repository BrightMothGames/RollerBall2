extends Spatial

const levelWidth = 5
const levelDepth = 5
const roomSpacing = 10
const roomRandomness = 3
const connectionType = ["empty", "locked", "closed", "open"]
onready var RNG = Random.RunSeed
onready var camera = $Camera

const firstGenRounds = 2
const firstGenProbability = 0.75

const voronoiRes = Vector2(levelWidth*16,levelDepth*16)
var centerOffsetMargin
var voronoiArray

class room:
	extends Spatial
	var empty = true
	var type
	var inNetwork = false
	var processed = false
	var connectionNorth
	var northConnectionType = connectionType[0]
	var connectionSouth
	var southConnectionType = connectionType[0]
	var connectionEast
	var eastConnectionType = connectionType[0]
	var connectionWest
	var westConnectionType = connectionType[0]
	var doors = []
	var voronoiPoints = []
	var convexHull
	var roomBounds = []
	var xMin
	var xMax
	var yMin
	var yMax
	var color = Color.white
	
	func is_type(type): return type == "room"
	
class door:
	extends Spatial
	var inNetwork
	var state = "closed"
	var connectionA
	var connectionB
	
	func is_type(type): return type == "door"

class voronoiPoint:
	extends Spatial
	var belongsTo
	
func _ready():
	voronoiArray = create2Darray(voronoiRes.x,voronoiRes.y, null)
	createLevel()

func create2Darray(w, h,default):
	var graph = []

	for x in range(w):
		var col = []
		col.resize(h)
		graph.append(col)
	
	for x in w:
		for y in h:
			graph[x][y] = default
	
	return graph


func _process(_delta):
	if Input.is_action_just_released("Fire"):
		get_tree().reload_current_scene()


func createLevel():
	createGraph()
	var nodes = get_tree().get_nodes_in_group("rooms")
	connectRooms(nodes)
	randomizeRoomPositions(nodes)
	pickRandomEntryRoom(nodes)
	moveCamera(camera)
	
	firstGen(nodes)
	generateVoronoi(voronoiRes)
	findVoronoiCorners(voronoiArray)
	
	roomBounds(get_tree().get_nodes_in_group("rooms"))
	
	
	debugGeometry(nodes)
	debugGeometry(get_tree().get_nodes_in_group("doors"))
	#debugVoronoi()
	debugVoronoiRoomBounds()
	
	
	for n in nodes:
		print(str(n.translation) + str(n.type))
	
	print("end of ready")

func moveCamera(node):
	node.translation.x = levelWidth as float * roomSpacing as float / 2
	node.translation.z = levelDepth as float * roomSpacing as float / 2
	node.translation.y = max(levelWidth,levelDepth) as float * roomSpacing as float / 2
	node.size = max(levelWidth,levelDepth) as float * roomSpacing as float * 1.25

func debugGeometry(nodes):
	for n in nodes:
		var s = CSGSphere.new()
		n.add_child(s)
		s.radius = .15
		s.material = SpatialMaterial.new()
		s.material.albedo_color = Color.red
		if n.is_type("room"):
			if n.inNetwork:
				s.material.albedo_color = Color.yellow
			if n.type == "Entry":
				s.material.albedo_color = Color.green
		if n.is_type("door"):
			s.material.albedo_color = Color.purple
			
	for line in Draw.Lines.size():
		Draw.Remove_Line(line)
	
	var ln = 0
	for d in get_tree().get_nodes_in_group("doors"):
		Draw.Draw_Line3D(ln, d.connectionA.translation, d.connectionB.translation, Color.magenta, 4)
		ln += 1

func debugVoronoi():
	for n in voronoiArray:
		var s = CSGBox.new()
		n.add_child(s)
		s.width = ((levelWidth * roomSpacing-roomSpacing)/voronoiRes.x)*1.25
		s.depth = ((levelDepth * roomSpacing-roomSpacing)/voronoiRes.y)*1.25
		s.material = SpatialMaterial.new()
		s.material.albedo_color = n.belongsTo.color
		
	for n in get_tree().get_nodes_in_group("rooms"):
		for p in n.voronoiPoints:
			var s = CSGSphere.new()
			n.add_child(s)
			s.radius = 0.25
			s.global_transform.origin.x = p.x
			s.global_transform.origin.z = p.y
			s.material = SpatialMaterial.new()
			s.material.albedo_color = Color.white

func debugVoronoiRoomBounds():
	for v in get_tree().get_nodes_in_group("voronoiPoints"):
		var s = CSGBox.new()
		v.add_child(s)
		s.width = ((levelWidth * roomSpacing-roomSpacing)/voronoiRes.x)
		s.depth = ((levelDepth * roomSpacing-roomSpacing)/voronoiRes.y)
		s.material = SpatialMaterial.new()
		s.material.albedo_color = Color.gray

		for n in get_tree().get_nodes_in_group("network"):
			var vec = Vector2(v.translation.x,v.translation.z)
			if Geometry.is_point_in_polygon(vec, n.roomBounds):
				s.material.albedo_color = Color.black
				v.belongsTo = n
				
				var margin = centerOffsetMargin
				if vec.x >= n.xMin + margin and vec.x <= n.xMax - margin and vec.y >= n.yMin + margin and vec.y <= n.yMax - margin:
					s.material.albedo_color = n.color
					
	#			if vec.x < n.roomBounds[2].x and vec.x+.1 > n.roomBounds[2].x+margin and vec.y > n.roomBounds[0].y-.04 and vec.y < n.roomBounds[2].y+.04:
	#				s.material.albedo_color = Color.black
	#
	#			if vec.y > n.roomBounds[0].y and vec.y-offset < n.roomBounds[0].y-margin and vec.x > n.roomBounds[0].x and vec.x < n.roomBounds[2].x:
	#				s.material.albedo_color = Color.black
	#
	#			if vec.y < n.roomBounds[2].y and vec.y+offset > n.roomBounds[2].y+margin and vec.x > n.roomBounds[0].x and vec.x < n.roomBounds[2].x:
	#				s.material.albedo_color = Color.black

func createGraph():
	for x in levelWidth:
		for z in levelDepth:
			var r = room.new()
			add_child(r)
			r.translation.x = x * roomSpacing
			r.translation.z = z * roomSpacing
			r.add_to_group("rooms")
			var i = fmod(r.get_index(),.816)
			r.color = Color.from_hsv(i,1,1)
			#print(r.translation)

func connectRooms(nodes):
	#print(nodes)
	for n in nodes:
		#print(n.translation)
		for nn in nodes:
			#print(nn.translation)
			if nn.translation.x == n.translation.x -roomSpacing and nn.translation.z == n.translation.z:
				n.connectionNorth = nn
				#print("connected " + " north to " + str(nn.translation))
			if nn.translation.x == n.translation.x +roomSpacing and nn.translation.z == n.translation.z:
				n.connectionSouth = nn
				#print("connected " + " south to " + str(nn.translation))
			if nn.translation.x == n.translation.x and nn.translation.z == n.translation.z +roomSpacing:
				n.connectionEast = nn
				#print("connected " + " east to " + str(nn.translation))
			if nn.translation.x == n.translation.x and nn.translation.z == n.translation.z -roomSpacing:
				n.connectionWest = nn
				#print("connected " + " west to " + str(nn.translation))

func randomizeRoomPositions(nodes):
	for n in nodes:
		n.translation.x += RNG.randf_range(-roomRandomness, roomRandomness)
		n.translation.z += RNG.randf_range(-roomRandomness, roomRandomness)

func pickRandomEntryRoom(nodes):
	var rand = RNG.randi_range(0,nodes.size())
	var n = nodes[rand-1]
	n.type = "Entry"
	n.empty = false
	n.inNetwork = true
	n.add_to_group("network")

func connectTwoNodes(nodeA,nodeB,type):
	var d
	match type:
		"locked", "closed", "open":
			d = door.new()
		_:
			return
	
	add_child(d)
	d.add_to_group("doors")
	d.state = type
	d.connectionA = nodeA
	d.connectionB = nodeB
	d.inNetwork = true
	d.translation.x = (nodeA.translation.x + nodeB.translation.x) / 2
	d.translation.z = (nodeA.translation.z + nodeB.translation.z) / 2
	nodeA.doors.append(Vector2(d.translation.x,d.translation.z))
	nodeB.doors.append(Vector2(d.translation.x,d.translation.z))
	
	nodeB.inNetwork = true
	nodeB.add_to_group("network")
	
	if nodeA.connectionNorth == nodeB:
		nodeA.connectionNorth = d
		nodeB.connectionSouth = d
		return
	if nodeA.connectionSouth == nodeB:
		nodeA.connectionSouth = d
		nodeB.connectionNorth = d
		return
	if nodeA.connectionEast == nodeB:
		nodeA.connectionEast = d
		nodeB.connectionWest = d
		return
	if nodeA.connectionWest == nodeB:
		nodeA.connectionWest = d
		nodeB.connectionEast = d

func firstGen(nodes):
	for r in firstGenRounds:
		for n in nodes:
			if n.inNetwork and not n.processed:
				n.processed = true
				var connections = []
				if n.connectionNorth and n.connectionNorth.is_type("room") and not n.connectionNorth.inNetwork:
					connections.append(n.connectionNorth)
				if n.connectionSouth and n.connectionSouth.is_type("room") and not n.connectionSouth.inNetwork:
					connections.append(n.connectionSouth)
				if n.connectionEast and n.connectionEast.is_type("room") and not n.connectionEast.inNetwork:
					connections.append(n.connectionEast)
				if n.connectionWest and n.connectionWest.is_type("room") and not n.connectionWest.inNetwork:
					connections.append(n.connectionWest)
				
				connections.shuffle()
				var loops = int(connections.size() * firstGenProbability)
				for w in loops:
					if connections.size() == 0:
						break
					var nn = connections[RNG.randi_range(0,connections.size()-1)]
					connectTwoNodes(n,nn,"closed")
					connections.erase(nn)
				break

func generateVoronoi(res):
	for y in res.y:
		for x in res.x:
			var p = voronoiPoint.new()
			add_child(p)
			voronoiArray[x][y] = p
			p.translation.x = range_lerp(x,0,res.x,-roomRandomness,levelWidth * roomSpacing-roomSpacing+roomRandomness)
			p.translation.z = range_lerp(y,0,res.y,-roomRandomness,levelDepth * roomSpacing-roomSpacing+roomRandomness)
			p.translation.y = -1.0
			p.add_to_group("voronoiPoints")
	
	centerOffsetMargin = (levelWidth * roomSpacing-roomSpacing+roomRandomness+roomRandomness) / (res.x-1)
	
	var points = get_tree().get_nodes_in_group("voronoiPoints")
	var rooms = get_tree().get_nodes_in_group("rooms")
	for p in points:
		p.belongsTo = rooms[0]
		for r in rooms:
			if p.translation.distance_to(r.translation) < p.translation.distance_to(p.belongsTo.translation):
				p.belongsTo = r

func findVoronoiCorners(arr):
	for x in voronoiRes.x:
		for y in voronoiRes.y:
			var n = [voronoiArray[x][y].belongsTo]
			var pos = Vector2(voronoiArray[x][y].translation.x,voronoiArray[x][y].translation.z)
			if x+1 <= voronoiArray.size()-1:
				if y+1 <= voronoiArray[x].size()-1:
					for xx in 2:
						for yy in 2:
							if not n.has(voronoiArray[x+xx][y+yy].belongsTo):
								n.append(voronoiArray[x+xx][y+yy].belongsTo)
			if n.size() > 2:
				for nn in n:
					nn.voronoiPoints.append(pos)

			n = [voronoiArray[x][y].belongsTo]

			if y == 0 or y == voronoiRes.y-1:
				if x+1 <= voronoiArray.size()-1:
					if not n.has(voronoiArray[x+1][y].belongsTo):
						n.append(voronoiArray[x+1][y].belongsTo)
			
			if x == 0 or x == voronoiRes.x-1:
				if y+1 <= voronoiArray[x].size()-1:
					if not n.has(voronoiArray[x][y+1].belongsTo):
						n.append(voronoiArray[x][y+1].belongsTo)
			
			if n.size() > 1:
				for nn in n:
					nn.voronoiPoints.append(pos)
			
			n = voronoiArray[x][y].belongsTo
			
			if x == 0 and y == 0:
				n.voronoiPoints.append(pos)
			if x == 0 and y == voronoiRes.y-1:
				n.voronoiPoints.append(pos)
			if x == voronoiRes.x-1 and y == 0:
				n.voronoiPoints.append(pos)
			if x == voronoiRes.x-1 and y == voronoiRes.y-1:
				n.voronoiPoints.append(pos)

#	for n in get_tree().get_nodes_in_group("rooms"):
#		print(n.voronoiPoints)

func roomBounds(nodes):
	
	for n in nodes:
		if n.doors.size() > 0:
			for d in n.doors:
				n.voronoiPoints.append(d)
		
		n.convexHull = Geometry.convex_hull_2d(n.voronoiPoints as PoolVector2Array)
		
		for vec in n.doors:
			n.roomBounds.append(vec)
			var i = (n.convexHull as Array).find(vec)
			if n.voronoiPoints.size() < i+1:
				n.roomBounds.append(n.voronoiPoints[i+1])
			else:
				n.roomBounds.append(n.voronoiPoints[1])
		

		var minX = n.translation.x-centerOffsetMargin
		var minY = n.translation.z-centerOffsetMargin
		var maxX = n.translation.x+centerOffsetMargin
		var maxY = n.translation.z+centerOffsetMargin

		for vec in n.roomBounds:
			if vec.x < minX:
				minX = vec.x-centerOffsetMargin
			if vec.x > maxX:
				maxX = vec.x+centerOffsetMargin
			if vec.y < minY:
				minY = vec.y-centerOffsetMargin
			if vec.y > maxY:
				maxY = vec.y+centerOffsetMargin
		
		n.roomBounds = []
		
		n.roomBounds.append(Vector2(minX,minY))
		n.roomBounds.append(Vector2(maxX,minY))
		n.roomBounds.append(Vector2(maxX,maxY))
		n.roomBounds.append(Vector2(minX,maxY))
		
		n.xMin = minX
		n.xMax = maxX
		n.yMin = minY
		n.yMax = maxY
