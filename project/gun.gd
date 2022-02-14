extends Spatial

var bullet_settings

export var dropoff_mult:float = 1
export var dropoff_add:float = 0
export var damage_mult:float = 1
export var damage_add:float = 0
export var speed_mult:float = 1
export var speed_add:float = 0
export var size_mult:float = 1
export var size_add:float = 0
export var initial_transform_add:float = 0
export var initial_velocity_inherit:Vector3 = Vector3(0.33,0.33,0.33)

onready var barrel = $"barrel"
onready var cooldown_timer = $cooldown_timer
onready var bullet = preload("res://bullet.tscn")

func _ready():
	pass

func update_loadout():
	
	bullet_settings.dropoff = 	bullet_settings.dropoff * dropoff_mult 	+ dropoff_add
	bullet_settings.damage =	bullet_settings.damage 	* damage_mult 	+ damage_add
	bullet_settings.speed = 	bullet_settings.speed 	* speed_mult 	+ speed_add
	bullet_settings.size = 		bullet_settings.size 	* size_mult 	+ size_add
	
	bullet_settings.initial_transform = barrel.transform
	
	#bullet_settings.initial_velocity = bullet_settings.initial_velocity * (bullet_settings.owner.globalVelocity*initial_velocity_inherit)
	
func _physics_process(delta):
	if bullet_settings.owner.can_shoot and PlayerInput.rt and cooldown_timer.is_stopped():
		shoot()
		cooldown_timer.start()
	
func shoot():
	#print("shoot")
	# "muzzle" is a spacial placed at the barrel of the gun.
	var b = bullet.instance() #transform, inherited velocity, settings
	b.start(barrel.global_transform, bullet_settings.initial_velocity * (bullet_settings.owner.globalVelocity*initial_velocity_inherit), bullet_settings)
	get_tree().get_root().add_child(b)

