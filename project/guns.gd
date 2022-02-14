extends Spatial

var bullet_settings

func _ready():
	pass

func update_loadout():
	for n in get_children():
		if "bullet_settings" in n:
			n.bullet_settings = bullet_settings
		
		n.update_loadout()
