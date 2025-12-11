extends Node3D

var cam_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.is_customizing: return
	if !Input.is_action_pressed("mouse"):
		if Input.is_action_pressed("fast"):
			cam_speed = 5
		else:
			cam_speed = 1
		if Input.is_action_pressed("forward"):
			global_position -= $Camera3D.global_basis.z * delta * cam_speed
		if Input.is_action_pressed("backward"):
			global_position += $Camera3D.global_basis.z * delta * cam_speed
		if Input.is_action_pressed("right"):
			global_position += $Camera3D.global_basis.x * delta * cam_speed
		if Input.is_action_pressed("left"):
			global_position -= $Camera3D.global_basis.x * delta * cam_speed
		if Input.is_action_pressed("up"):
			global_position += $Camera3D.global_basis.y * delta * cam_speed
		if Input.is_action_pressed("down"):
			global_position -= $Camera3D.global_basis.y * delta * cam_speed
