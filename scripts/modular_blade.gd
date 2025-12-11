extends RigidBody3D

@export var ray : RayCast3D

# Physics Properties
var spin_friction = 0.05
var movement_speed = 10.0
var stability_factor = 1.0
var stamina_drain_rate = 0.5
var ground_friction = 0.5

# State
var is_active = true

func _ready():
	# Initial setup if needed
	pass

func setup(config):
	# Clear existing parts
	for child in $Visuals/Tip.get_children(): child.queue_free()
	for child in $Visuals/Metal.get_children(): child.queue_free()
	for child in $Visuals/Ring.get_children(): child.queue_free()

	# Load Tip
	var tip_data = Global.tips[config["tip"]]
	var tip_instance = tip_data["scene"].instantiate()
	$Visuals/Tip.add_child(tip_instance)

	# Load Metal
	var metal_data = Global.metals[config["metal"]]
	var metal_instance = metal_data["scene"].instantiate()
	$Visuals/Metal.add_child(metal_instance)

	# Load Ring
	var ring_data = Global.rings[config["ring"]]
	var ring_instance = ring_data["scene"].instantiate()
	$Visuals/Ring.add_child(ring_instance)

	# Update Physics Stats
	mass = tip_data["mass"] + metal_data["mass"] + ring_data["mass"]
	spin_friction = tip_data["friction"]
	stability_factor = tip_data["stability"]
	movement_speed = tip_data["movement_speed"]
	stamina_drain_rate = tip_data["stamina_drain"]

	# Update Colliders
	# Ideally, shapes would be updated based on radius/height from data
	# Here we do a simple scaling or parameter update if supported
	var metal_collider = $Colliders/MetalCollider
	if metal_collider.shape is CylinderShape3D:
		metal_collider.shape = metal_collider.shape.duplicate()
		metal_collider.shape.radius = metal_data.get("radius", 0.25)
		metal_collider.shape.height = metal_data.get("height", 0.1)

	var ring_collider = $Colliders/RingCollider
	if ring_collider.shape is CylinderShape3D:
		ring_collider.shape = ring_collider.shape.duplicate()
		ring_collider.shape.radius = ring_data.get("radius", 0.28)
		ring_collider.shape.height = ring_data.get("height", 0.05)

	# Adjust Center of Mass (Simplified)
	center_of_mass = Vector3(0, -0.05, 0)

	# Inertia (Simplified approximation based on cylinder)
	var r = metal_data.get("radius", 0.25) # approx radius based on metal
	var I_y = 0.5 * mass * r * r
	var I_xz = (1.0/12.0) * mass * (3*r*r + 0.1*0.1) # height approx 0.1
	inertia = Vector3(I_xz, I_y, I_xz)

func _physics_process(delta):
	if not is_active: return

	# Handle Audio
	if ray.is_colliding():
		if not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.play()
	else:
		if $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.stop()
	$AudioStreamPlayer3D.pitch_scale = angular_velocity.length() / 20.0

	# 1. Stamina Loss / Spin Friction
	# Apply torque against the spin
	var spin_dir = angular_velocity.normalized()
	if angular_velocity.length() > 0.1:
		apply_torque( -spin_dir * spin_friction )
		# Explicitly reduce angular velocity to simulate air resistance/bearing friction
		angular_velocity *= (1.0 - (stamina_drain_rate * 0.01 * delta))
	else:
		is_active = false

	# 2. Stability (Gyroscopic Effect)
	# If spinning fast, it wants to stay upright (align with global up or local up depending on interpretation)
	# We simulate this by applying a torque that tries to align the local Y with the global Y
	# The strength depends on angular velocity.
	var up_vector = global_transform.basis.y
	var target_up = Vector3.UP

	# If on a slope, maybe align to normal? Real tops precess around gravity.
	# For "Arcade" feel, let's try to align to UP, but weak.
	var alignment_torque = up_vector.cross(target_up)
	var speed = angular_velocity.length()

	# Only apply stability if spinning
	if speed > 1.0:
		apply_torque(alignment_torque * stability_factor * speed)

	# 3. Movement (Precession / Walking)
	# When tilted, the point of contact is not center.
	if ray.is_colliding():
		var normal = ray.get_collision_normal()
		var point = ray.get_collision_point()

		# Simple "Walk": move in direction of tilt cross up
		# If tilted, move perpendicular to tilt.
		var tilt = up_vector.cross(normal) # Axis of tilt
		if tilt.length() > 0.01:
			# Precession direction
			var walk_dir = tilt.rotated(normal, PI/2).normalized()

			# Force depends on how much we are tilted and spin speed
			var walk_force = walk_dir * speed * movement_speed * tilt.length()
			apply_central_force(walk_force)

	# 4. Gravity / Precession Torque
	# Gravity pulls the center of mass down. Since pivot is at bottom, this creates torque.
	# RigidBody handles gravity force, but we might want to exaggerate precession.
	# Precession torque = r x F_g
	# For now, let RigidBody handle the falling over part.
