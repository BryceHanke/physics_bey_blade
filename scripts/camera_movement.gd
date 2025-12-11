extends Node3D

@export var SENS : float = 0.0025

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_movement(event)

func _process(delta):
	temp_pause()
	rotation.x = clampf(rotation.x, deg_to_rad(-90), deg_to_rad(90))

func mouse_movement(event):
	if Global.is_customizing: return
	if !Input.is_action_pressed("mouse"):
		$"..".rotate_y((-event.relative.x) * (SENS))
		rotate_x((-event.relative.y) * (SENS))

func temp_pause():
	if Global.is_customizing: return
	if Input.is_action_just_pressed("mouse") or Input.is_action_just_released("mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
