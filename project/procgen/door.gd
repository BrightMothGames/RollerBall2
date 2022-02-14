extends Node

var connectedA
var connectedB


func _ready():
	pass

func drawConnection():
	Draw.Draw_Line3D(int(str(get_index())), connectedA.translation, connectedB.translation,Color.magenta,3)
