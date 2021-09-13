extends KinematicBody

#Kinematic Varibles
const ACCEL = .5
const SPEED = 4
const GRAVITY = .1
const FRICTION = .02
const VELAS = .5
const HELAS = 1
const JUMPHEIGHT = 15
var dir = Vector2()
var planarVelocity = Vector2(0,0)
var globalVelocity = Vector3()
var yVelocity = 0
var fireAngle = Vector3.FORWARD

#Camera Variables
onready var cameraPivotX = $"CameraPivotX"
onready var cameraPivotY = $"CameraPivotX/CameraPivotY"

var lookSensitivity:float = 250
var minLookAngle:float  = 10
var maxLookAngle:float  = 75
var cameraRotation

#Player Graphics Variables
onready var sphere = $"PlayerModel"

#Bullett Variables
onready var bullet = preload("res://bullet.tscn")
onready var muzzle = $"CameraPivotX/Muzzle"
var bulletTimer = Timer.new()
var bulletDelay = .25
var canShoot = true

#Gameplay Variables
onready var gui = find_node("GUI")
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
	bulletTimer.set_one_shot(true)
	bulletTimer.set_wait_time(bulletDelay)
	bulletTimer.connect("timeout", self, "on_timeout")
	add_child(bulletTimer)

func on_timeout():
	canShoot = true

func _physics_process(delta):

	dir = PlayerInput.joyL * ACCEL
		
	planarVelocity += dir.rotated(-cameraPivotX.rotation.y)
	
	planarVelocity.x = lerp(planarVelocity.x, 0, FRICTION)
	planarVelocity.y = lerp(planarVelocity.y, 0, FRICTION)
	
	if planarVelocity.length() > SPEED:
		planarVelocity = planarVelocity.normalized()*SPEED
	
	globalVelocity = Vector3(planarVelocity.x,yVelocity,planarVelocity.y)
		
	#move_and_slide(globalVelocity)
	
	var collision = move_and_collide(globalVelocity * delta)
	if collision:
		globalVelocity = globalVelocity.bounce(collision.normal)
		yVelocity = globalVelocity.y * VELAS
		planarVelocity = Vector2(globalVelocity.x,globalVelocity.z) * HELAS
			
	#if not is_on_floor():
	yVelocity -= GRAVITY

func _process(delta):
	
	#Shooting
	if PlayerInput.rt && canShoot:
		#print("bar")
		shoot()
		canShoot = false
		bulletTimer.start()
	
	
	#Camera
	var rot = Vector3(PlayerInput.joyR.x, PlayerInput.joyR.y, 0)
	cameraRotation = rot * delta * lookSensitivity
	cameraPivotX.rotate_y(-cameraRotation.x/50)
	cameraPivotY.rotate_x(cameraRotation.y/360)
	cameraPivotY.rotation_degrees.x = clamp(cameraPivotY.rotation_degrees.x, minLookAngle, maxLookAngle)
		
	#Player Graphics
	sphere.rotate_x(planarVelocity.y/10)
	sphere.rotate_z(-planarVelocity.x/10)

func shoot():
	#print("shoot")
	# "muzzle" is a spacial placed at the barrel of the gun.
	var b = bullet.instance() #pos, rot, speed, vel, calledBy
	b.start(muzzle.global_transform.origin,    muzzle.global_transform.basis,     5,     Vector3(planarVelocity.x,0,planarVelocity.y),    "Player")
	get_parent().add_child(b)

func hit(position, velocity):
	#print("ow")
	curHealth -= 1
	if curHealth <= 0:
		die()
	self.curHealth -= 1
	planarVelocity += Vector2(velocity.x,velocity.z)
	yVelocity += velocity.y

func die():
	print("YOU DED")
