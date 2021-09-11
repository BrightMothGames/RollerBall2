extends Node

var joyLX = 0
var joyLY = 0
var joyRX = 0
var joyRY = 0

var joyL = Vector2.ZERO
var joyR = Vector2.ZERO

var rt:bool

var mouseDelta = Vector2.ZERO
var sensitivity = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.center_window()

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative/sensitivity

func _process(_delta):
	rt = Input.is_action_pressed("Fire")
	
	joyLX = -Input.get_action_strength("MoveX+") + Input.get_action_strength("MoveX-")
	joyLY = Input.get_action_strength("MoveY+") - Input.get_action_strength("MoveY-")
	
	joyRX = Input.get_action_strength("LookX+") - Input.get_action_strength("LookX-")
	joyRY = Input.get_action_strength("LookY+") - Input.get_action_strength("LookY-")
	
	joyL = Vector2(joyLX,joyLY)
	joyR = Vector2(joyRX,joyRY) + mouseDelta

	if Input.is_action_just_released("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	
	mouseDelta = lerp(mouseDelta,Vector2.ZERO,.5)


