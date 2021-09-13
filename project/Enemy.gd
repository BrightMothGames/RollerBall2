extends KinematicBody

const GRAVITY = .1

var enemies = ["Player"]
var tracking = []
var active

var globalVelocity:Vector3

#Bullet Variables
onready var bullet = preload("res://bullet.tscn")
onready var muzzle = $"Muzzle"
onready var animPlayer = $"AnimationPlayer"
var bulletTimer = Timer.new()
var bulletDelay = .5
var canShoot = true

#Navigation
onready var nav = get_parent()
var navTarget
var speed = 1
var path = []
var path_node = 0

#Gameplay Variables
var health = 5

func _ready():
	bulletTimer.set_one_shot(true)
	bulletTimer.set_wait_time(bulletDelay)
	bulletTimer.connect("timeout", self, "on_timeout")
	add_child(bulletTimer)

func _physics_process(delta):
	
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < .25:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _process(delta):
	if tracking.size() > 0:
		navTarget = tracking[0]
		if path_node == path.size():
			move_to(navTarget.global_transform.origin)
		look_at(tracking[0].translation,Vector3.UP)
		if canShoot:
			shoot()
			canShoot = false
			bulletTimer.start()
	
#	for line in Draw.Lines.size():
#		Draw.Remove_Line(line)
#
#	for i in path.size()-1:
#		Draw.Draw_Line3D(i, path[i], path[i+1], Color.magenta, 4)


func on_timeout():
	canShoot = true

func shoot():
	#print("shoot")
	# "muzzle" is a spacial placed at the barrel of the gun.
	var b = bullet.instance() #pos, rot, speed, vel, calledBy
	b.start(muzzle.global_transform.origin,    muzzle.global_transform.basis,   3,   Vector3(0,0,0),   "Enemy")
	get_parent().add_child(b)

func _on_Area_body_entered(body):
	if body.name in enemies:
		tracking.append(body)
		#print(body.name)

func _on_Area_body_exited(body):
	if body.name in enemies:
		tracking.erase(body)
		#print(body.name)

func hit(translation, velocity):
	print("Enemy hit")
	animPlayer.play("hit")
	health -= 1
	if health <= 0:
		die()

func die():
	
	queue_free()

func _on_Timer_timeout():
	if navTarget:
		move_to(navTarget.global_transform.origin)
