extends KinematicBody

var gravity = -.01

var velocity = Vector3()


onready var animPlayer = $"AnimationPlayer"

func start(pos, rot, speed, vel, grav, calledBy):
	gravity = grav
	if calledBy == "Player":
		collision_mask = 2
	else:
		collision_mask = 1
	collision_mask += 12
	transform.basis = rot
	translation = pos
	velocity = (speed*get_transform().basis.z)+(vel/3)
	add_to_group("playerBullet")

func _physics_process(delta):
	velocity.y += gravity
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
