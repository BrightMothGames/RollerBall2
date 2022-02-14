extends KinematicBody

#Kinematic Varibles
const ACCEL = .5
const SPEED = 4
const GRAVITY = .1
const FRICTION = .02
const VELAS = .5
const HELAS = 1
const JUMPHEIGHT = 3
var dir = Vector2()
var planarVelocity = Vector2(0,0)
var globalVelocity = Vector3()
var yVelocity = 0
var fireAngle = Vector3.FORWARD

#Camera Variables
onready var cameraPivotX = $"camera_pivot_x"
onready var cameraPivotY = $"camera_pivot_x/camera_pivot_y"

var lookSensitivity:float = 400
var minLookAngle:float  = 10
var maxLookAngle:float  = 75
var cameraRotation

#Player Graphics Variables
onready var sphere = $"player_model"
var material
export var playerColor = Color(0,1,0) setget set_playerColor
onready var animPlayer = $"animation_player"

#Bullett Variables
var bullet_settings = load("res://classes/bullet_settings.gd").new()

#Loadout variables
onready var loadout = $"loadout"

#onready var bullet = preload("res://bullet.tscn")
onready var guns = $"guns"
export var can_shoot = true

#Gameplay Variables
onready var iFrames = $"i_frame_timer"
onready var gui = $"gui"
onready var jumpRayCast = $"jump_ray_cast"
var maxHealth = 5 setget update_maxHealth
var curHealth = 5 setget update_curHealth


func update_maxHealth(value):
	maxHealth = value
	gui.update_ui("maxHealth")

func update_curHealth(value):
	curHealth = value
	#print("updatecurhealth")
	gui.update_ui("curHealth")

func _ready():
	material = get_node("player_model/sphere").material
	
	#Default bullet settings
	bullet_settings.dropoff = 0.01
	bullet_settings.damage = 1
	bullet_settings.speed = 3
	bullet_settings.size = 1
	bullet_settings.color = Color.white
	bullet_settings.owner = self
	bullet_settings.initial_transform = transform
	bullet_settings.initial_velocity = Vector3(0.0,0.0,1.0)
	
	update_loadout()

func update_loadout():
	for n in loadout.get_children():
		if n.has_function("update_bullet"):
			bullet_settings = n.update_bullet(bullet_settings)
	
	guns.bullet_settings = bullet_settings
	guns.update_loadout()


func _physics_process(delta):

	dir = PlayerInput.joyL * ACCEL
	
		
	planarVelocity += dir.rotated(-cameraPivotX.rotation.y)
	
	planarVelocity.x = lerp(planarVelocity.x, 0, FRICTION)
	planarVelocity.y = lerp(planarVelocity.y, 0, FRICTION)
	
	if planarVelocity.length() > SPEED:
		planarVelocity = planarVelocity.normalized()*SPEED
	
	if PlayerInput.lt && jumpRayCast.is_colliding():
		yVelocity += JUMPHEIGHT
	
	globalVelocity = Vector3(planarVelocity.x,yVelocity,planarVelocity.y)
		
	#move_and_slide(globalVelocity)
	
	var collision = move_and_collide(globalVelocity * delta)
	if collision:
		globalVelocity = globalVelocity.bounce(collision.normal)
		yVelocity = globalVelocity.y * VELAS
		planarVelocity = Vector2(globalVelocity.x,globalVelocity.z) * HELAS
			
	#if not is_on_floor():
	yVelocity -= GRAVITY
	
	#rotate all guns to match view
	guns.rotation.y = cameraPivotX.rotation.y

func _process(delta):
	#Camera
	var rot = Vector3(PlayerInput.joyR.x, PlayerInput.joyR.y, 0)
	cameraRotation = rot * delta * lookSensitivity
	cameraPivotX.rotate_y(-cameraRotation.x/50)
	cameraPivotY.rotate_x(cameraRotation.y/360)
	cameraPivotY.rotation_degrees.x = clamp(cameraPivotY.rotation_degrees.x, minLookAngle, maxLookAngle)
		
	#Player Graphics
	sphere.rotate_x(planarVelocity.y/10)
	sphere.rotate_z(-planarVelocity.x/10)
	

func set_playerColor(col):
	if material:
		material.set_shader_param("color",Vector3(col.r,col.g,col.b))
	playerColor = col

func hit(position:Vector3 = Vector3.ZERO, velocity:Vector3 = Vector3.ZERO):
	if not iFrames.is_stopped():
		return
	animPlayer.play("hit")
	iFrames.start()
	print("ow")
	if curHealth <= 0:
		die()
	self.curHealth -= 1
	planarVelocity += Vector2(velocity.x,velocity.z)
	yVelocity += velocity.y

func die():
	print("YOU DED")
	get_tree().reload_current_scene()
