extends Node2D

onready var player = get_parent()
onready var healthBar = get_node("HealthBar")



func _ready():
	update_maxHealth()
	update_curHealth()

func update_ui(variable):
	self.call("update_" + str(variable))
	
func _process(delta):
	pass

func update_maxHealth():
	for i in player.maxHealth:
		var heart = TextureRect.new()
		heart.texture = load("res://icons/hud_heartEmpty.png")
		healthBar.add_child(heart)
	update_curHealth()
	
func update_curHealth():
	for i in healthBar.get_child_count():
		healthBar.get_child(i).texture = load("res://icons/hud_heartEmpty.png")
	for i in player.curHealth:
		healthBar.get_child(i).texture = load("res://icons/hud_heartFull.png")
