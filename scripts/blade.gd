extends RigidBody3D

@export var ray : RayCast3D

@export var pitch = 1

func _physics_process(delta):
	if ray.is_colliding():
		$AudioStreamPlayer3D.set_playing(true)
	else:
		$AudioStreamPlayer3D.set_playing(false)
	if linear_velocity.length() >= 10:
		linear_velocity += (global_basis.z * angular_velocity) * delta * 5
	var n = $RayCast3D.get_collision_normal()
	$AudioStreamPlayer3D.pitch_scale = angular_velocity.length()/100 * pitch
	global_transform = lerp(global_transform, align_with_y(global_transform, n),0.25)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
