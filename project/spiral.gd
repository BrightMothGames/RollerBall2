extends Spatial
var array

func _ready():
	array = createMatrix(50, 50,Vector2.ZERO)
	for x in 50:
		for y in 50:
			array[x][y]= Vector2(x,y)
			
	print(array)
	
	array = spiralOrder(array)
	
	var saveFile = File.new()
	saveFile.open("res://savearray.txt",File.WRITE)
#	for y in 50:
#		var string = ""
#		for x in 50:
#			string = string + str(array[x][y])
#		string.pad_zeros(2)
#		saveFile.store_line(string)
	#saveFile.store_line(str(array))
	saveFile.store_var(array)
	saveFile.close()

func createMatrix(w, h,default):
	var graph = []

	for x in range(w):
		var col = []
		col.resize(h)
		graph.append(col)
	
	for x in w:
		for y in h:
			graph[x][y] = default
	
	return graph


func spiralOrder(matrix):
	var ans = []
 
	if (len(matrix) == 0):
		return ans
 
	var R = matrix.size()
	var C = matrix[0].size()
	var seen = createMatrix(C,R,false)
	var dr = [0, 1, 0, -1]
	var dc = [1, 0, -1, 0]
	var r = 0
	var c = 0
	var di = 0
 
	# Iterate from 0 to R * C - 1
	for i in (R * C):
		ans.append(matrix[r][c])
		seen[r][c] = true
		var cr = r + dr[di]
		var cc = c + dc[di]
 
		if (0 <= cr and cr < R and 0 <= cc and cc < C and not seen[cr][cc]):
			r = cr
			c = cc
		else:
			di = (di + 1) % 4
			r += dr[di]
			c += dc[di]
	
	return ans
