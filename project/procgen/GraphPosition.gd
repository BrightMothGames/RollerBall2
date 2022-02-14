extends Position3D

export var pos:Vector2
export(String, "Room", "Door", "Wall", "Edge") var type
var radius = .2 setget setRadius
var color = Color.white
var s

var connectedEast
var connectedWest
var connectedNorth
var connectedSouth
var connectionPoints = []
var roomBounds = []
var roomID
var voronoiPoints = []


var mat

func _ready():
	mat = load("res://tiles/tileColor.tres").duplicate(true)
	pos.x = translation.x
	pos.y = translation.z
	s = CSGSphere.new()
	s.radius = .02
	match type:
		"Room":
			s.radius = .2
			add_to_group("rooms")
	add_child(s)
	roomID = pos
	

func setRadius(r):
	radius = r
	s.radius = r
	
func setColor():
	var i = fmod(get_index(),.816)
	var c = Color.from_hsv(i,1,1)
	get_child(1).material.albedo_color = c
		#print(get_child(1).material.albedo_color)
	color = c

func connectToParentGraph():
	var n = get_parent()
	get_parent().get_parent().graphNodes[pos.x][pos.y] = self
	
func drawConnection():
	Draw.Camera_Node = get_viewport().get_camera()
	if connectedNorth and connectedNorth.type != "Edge":
		Draw.Draw_Line3D(int(str(get_instance_id())+"1"), translation, connectedNorth.translation, Color.magenta, .3)
	if connectedSouth and connectedSouth.type != "Edge":
		Draw.Draw_Line3D(int(str(get_instance_id())+"2"), translation, connectedSouth.translation, Color.magenta, .3)
	if connectedEast and connectedEast.type != "Edge":
		Draw.Draw_Line3D(int(str(get_instance_id())+"3"), translation, connectedEast.translation, Color.magenta, .3)
	if connectedWest and connectedWest.type != "Edge":
		Draw.Draw_Line3D(int(str(get_instance_id())+"4"), translation, connectedWest.translation, Color.magenta, .3)
		
func drawRoom():
	#voronoiPoints.append(Vector2(translation.x,translation.z))

	if connectedEast:
		connectionPoints.append(Vector2(connectedEast.translation.x,connectedEast.translation.z))
		voronoiPoints.append(Vector2(connectedEast.translation.x,connectedEast.translation.z))
	if connectedWest:
		connectionPoints.append(Vector2(connectedWest.translation.x,connectedWest.translation.z))
		voronoiPoints.append(Vector2(connectedWest.translation.x,connectedWest.translation.z))
	if connectedNorth:
		connectionPoints.append(Vector2(connectedNorth.translation.x,connectedNorth.translation.z))
		voronoiPoints.append(Vector2(connectedNorth.translation.x,connectedNorth.translation.z))
	if connectedSouth:
		connectionPoints.append(Vector2(connectedSouth.translation.x,connectedSouth.translation.z))
		voronoiPoints.append(Vector2(connectedSouth.translation.x,connectedSouth.translation.z))
	
	var roomHull = []
	voronoiPoints = Geometry.convex_hull_2d(voronoiPoints)
	for vec in connectionPoints:
		roomHull.append(vec)
		var i = (voronoiPoints as Array).find(vec)
		roomHull.append(voronoiPoints[i+1])
		

	var minX = translation.x-.5
	var minY = translation.z-.5
	var maxX = translation.x+.5
	var maxY = translation.z+.5

	for vec in roomHull:
		if vec.x < minX:
			minX = vec.x
		if vec.x > maxX:
			maxX = vec.x
		if vec.y < minY:
			minY = vec.y
		if vec.y > maxY:
			maxY = vec.y

	roomBounds.append(Vector2(minX,minY))
	roomBounds.append(Vector2(maxX,minY))
	roomBounds.append(Vector2(maxX,maxY))
	roomBounds.append(Vector2(minX,maxY))
		
	print(roomBounds)
	
	#visible = false
	if voronoiPoints.size() > 2:
		var arr_mesh
		print("there's a room here")
		var m = MeshInstance.new()
		#var voronoiPointsHull = Geometry.convex_hull_2d(voronoiPoints)
		var surfTool = SurfaceTool.new()
		surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
		for i in roomBounds.size():
			surfTool.add_normal(Vector3(0,0,-1))
			var p = Vector3(roomBounds[i].x as float,1,roomBounds[i].y as float)
			#p = lerp(translation,p,.95)
			print(p)
			surfTool.add_vertex(p)
		arr_mesh = surfTool.commit()
		
		m.mesh = arr_mesh
		m.material_override = mat
		m.material_override.set_shader_param("albedo",color)
		#m.visible = false
		get_parent().get_parent().rooms.add_child(m)
		m.add_to_group("roomGeom")
		
#		for p in voronoiPoints.size():
#			var ppos = voronoiPoints[p]
#			var sph = CSGSphere.new()
#			sph.radius = .1
#			add_child(sph)
#			sph.translation = Vector3(ppos.x,1,ppos.y)-translation
