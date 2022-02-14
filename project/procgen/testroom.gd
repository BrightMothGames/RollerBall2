extends MeshInstance

var pointArray = []
var arr_mesh 

func _ready():
	pointArray.append(Vector3(0,0,0))
	pointArray.append(Vector3(0,1,0))
	pointArray.append(Vector3(1,1,0))
	pointArray.append(Vector3(1,0,0))
	updateMesh()
	
func addPoint(vec):
	var closest = 0
#	if pointArray.size() > 0:
#		for i in pointArray.size():
#			if pointArray[i].distance_to(vec) < pointArray[closest].distance_to(vec):
#				closest = i
	pointArray.insert(closest, vec)
	updateMesh()
	
func updateMesh():
	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
	if pointArray.size() > 2:
		for i in pointArray.size():
			surfTool.add_normal(Vector3(0,0,-1))
			surfTool.add_color(Color(1,1,1,1))
			surfTool.add_vertex(pointArray[i])
	arr_mesh = surfTool.commit()

	mesh = arr_mesh
	print(mesh)


func _process(delta):
	if Input.is_action_just_released("Fire"):
		var v = Vector3(Random.RunSeed.randi_range(0,20),Random.RunSeed.randi_range(0,20),0)
		addPoint(v)


# Initialize the ArrayMesh.
#var arrays = []
#arrays.resize(ArrayMesh.ARRAY_MAX)
#arrays[ArrayMesh.ARRAY_VERTEX] = vertices
## Create the Mesh.
#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
#var m = MeshInstance.new()
#m.mesh = arr_mesh
