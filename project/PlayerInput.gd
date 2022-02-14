extends Node

var joyLX = 0
var joyLY = 0
var joyRX = 0
var joyRY = 0

var joyL = Vector2.ZERO
var joyR = Vector2.ZERO

var rt:bool
var lt:bool

var mouseDelta = Vector2.ZERO
var sensitivity = 10

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#OS.current_screen = 1
	OS.center_window()
	#OS.window_maximized = true

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative/sensitivity
		
	if event == InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	rt = Input.is_action_pressed("Fire")
	lt = Input.is_action_pressed("Jump")
	
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


