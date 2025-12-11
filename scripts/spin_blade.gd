extends Node3D

var blades = []

@onready var camera_3d = $cam_holder/Camera3D

const BLADE_0 = preload("uid://cn2rehg0jwnvn")
const BLADE_1 = preload("uid://b0xqdps3gqw5r")
const BLADE_2 = preload("uid://dd00u23ilqkhe")
const BLADE_3 = preload("uid://crpgpr23biek3")

var throw_force = 50

func _process(delta):
	if Input.is_action_just_pressed("mouse"):
		for i in blades:
			i.queue_free()
		blades.clear()
	if Input.is_action_just_pressed("ui_left"):
		var new_blade
		new_blade = BLADE_0.instantiate()
		get_tree().current_scene.add_child(new_blade)
		blades.append(new_blade)
		new_blade.global_position = camera_3d.global_position - camera_3d.global_basis.z
		new_blade.apply_impulse(-camera_3d.global_basis.z)
		new_blade.apply_torque_impulse(Vector3(0,throw_force,0))
	if Input.is_action_just_pressed("ui_up"):
		var new_blade
		new_blade = BLADE_1.instantiate()
		get_tree().current_scene.add_child(new_blade)
		blades.append(new_blade)
		new_blade.global_position = camera_3d.global_position - camera_3d.global_basis.z
		new_blade.apply_impulse(-camera_3d.global_basis.z)
		new_blade.apply_torque_impulse(Vector3(0,throw_force,0))
	if Input.is_action_just_pressed("ui_right"):
		var new_blade
		new_blade = BLADE_2.instantiate()
		get_tree().current_scene.add_child(new_blade)
		blades.append(new_blade)
		new_blade.global_position = camera_3d.global_position - camera_3d.global_basis.z
		new_blade.apply_impulse(-camera_3d.global_basis.z)
		new_blade.apply_torque_impulse(Vector3(0,throw_force,0))
	if Input.is_action_just_pressed("ui_down"):
		var new_blade
		new_blade = BLADE_3.instantiate()
		get_tree().current_scene.add_child(new_blade)
		blades.append(new_blade)
		new_blade.global_position = camera_3d.global_position - camera_3d.global_basis.z
		new_blade.apply_impulse(-camera_3d.global_basis.z)
		new_blade.apply_torque_impulse(Vector3(0,throw_force,0))
