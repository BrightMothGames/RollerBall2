extends MeshInstance

var timer
var color = Color.white setget setColor
var pos = Vector2.ZERO
var belongsToRoom

func _ready():
	self.color = Color.magenta
	
func setColor(value):
	color = value
	material_override.set_shader_param("albedo" ,value)

