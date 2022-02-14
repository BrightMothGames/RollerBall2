extends KinematicBody

var velocity = Vector3()

var bullet_settings
#var dropoff:float
#var damage:float
#var speed:float
#var size:float
#var color:Color
#var owner:Node
#var initial_transform:Transform
#var initial_velocity:Vector3

onready var animPlayer = $"AnimationPlayer"

#global_transform, inherited_velocity , bullet_settings
func start(passed_global_transform, passed_inherited_velocity , passed_bullet_settings):
	bullet_settings = passed_bullet_settings
	if bullet_settings.owner.name == "player":
		collision_mask = 2
	else:
		collision_mask = 1
	collision_mask += 12
	global_transform = passed_global_transform
	velocity = (bullet_settings.speed*transform.basis.z)#+passed_inherited_velocity
	add_to_group("playerBullet")

func _physics_process(delta):
	velocity.y -= bullet_settings.dropoff
	if animPlayer.current_animation == "hit":
		return
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit()
		if collision.collider.has_method("hit"):
			collision.collider.hit(translation, velocity)

	
func _ready():
	pass
	
func hit():
	collision_layer = 0
	collision_mask = 0
	animPlayer.play("hit")

func _on_Timer_timeout():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()
