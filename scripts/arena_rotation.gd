extends Node3D


func _physics_process(delta):
	rotation_degrees.y -= delta*15
