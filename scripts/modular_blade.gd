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

func apply_color(node, color):
	if node is MeshInstance3D or node is CSGShape3D:
		if node.material_override:
			node.material_override = node.material.duplicate()
			node.material.albedo_color = color
		else:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			node.material_override = mat
	for child in node.get_children():
		apply_color(child, color)

func setup(config):
	# Clear existing parts
	for child in $Visuals/Tip.get_children(): child.queue_free()
	for child in $Visuals/Metal.get_children(): child.queue_free()
	for child in $Visuals/UpperRing.get_children(): child.queue_free()
	for child in $Visuals/LowerRing.get_children(): child.queue_free()

	# Load Tip
	var tip_data = Global.tips[config["tip"]]
	var tip_instance = tip_data["scene"].instantiate()
	$Visuals/Tip.add_child(tip_instance)
	if "color" in tip_data:
		apply_color(tip_instance, tip_data["color"])

	# Load Metal
	var metal_data = Global.metals[config["metal"]]
	var metal_instance = metal_data["scene"].instantiate()
	$Visuals/Metal.add_child(metal_instance)
	if "color" in metal_data:
		apply_color(metal_instance, metal_data["color"])

	# Load Upper Ring
	var upper_ring_data = Global.upper_rings[config["upper_ring"]]
	var upper_ring_instance = upper_ring_data["scene"].instantiate()
	$Visuals/UpperRing.add_child(upper_ring_instance)
	if "color" in upper_ring_data:
		apply_color(upper_ring_instance, upper_ring_data["color"])

	# Load Lower Ring
	var lower_ring_data = Global.lower_rings[config["lower_ring"]]
	var lower_ring_instance = lower_ring_data["scene"].instantiate()
	$Visuals/LowerRing.add_child(lower_ring_instance)
	if "color" in lower_ring_data:
		apply_color(lower_ring_instance, lower_ring_data["color"])

	# Update Physics Stats
	mass = tip_data["mass"] + metal_data["mass"] + upper_ring_data["mass"] + lower_ring_data["mass"]
	spin_friction = tip_data["friction"]
	stability_factor = tip_data["stability"]
	movement_speed = tip_data["movement_speed"]
	stamina_drain_rate = tip_data["stamina_drain"]

	# Ensure low bounce physics material
	if physics_material_override:
		physics_material_override.bounce = 0.0
	else:
		var pm = PhysicsMaterial.new()
		pm.bounce = 0.0
		physics_material_override = pm

	# Update Colliders
	if has_node("MetalCollider"):
		var metal_collider = $MetalCollider
		if metal_collider.shape is CylinderShape3D:
			metal_collider.shape = metal_collider.shape.duplicate()
			metal_collider.shape.radius = metal_data.get("radius", 0.25)
			metal_collider.shape.height = metal_data.get("height", 0.1)

	if has_node("UpperRingCollider"):
		var upper_ring_collider = $UpperRingCollider
		if upper_ring_collider.shape is CylinderShape3D:
			upper_ring_collider.shape = upper_ring_collider.shape.duplicate()
			upper_ring_collider.shape.radius = upper_ring_data.get("radius", 0.28)
			upper_ring_collider.shape.height = upper_ring_data.get("height", 0.05)

	if has_node("LowerRingCollider"):
		var lower_ring_collider = $LowerRingCollider
		if lower_ring_collider.shape is CylinderShape3D:
			lower_ring_collider.shape = lower_ring_collider.shape.duplicate()
			lower_ring_collider.shape.radius = lower_ring_data.get("radius", 0.28)
			lower_ring_collider.shape.height = lower_ring_data.get("height", 0.05)

	# Adjust Center of Mass
	# Fixes "Condition center_of_mass_mode != CENTER_OF_MASS_MODE_CUSTOM is true"
	center_of_mass_mode = CENTER_OF_MASS_MODE_CUSTOM
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

	# Fixes "Condition p_pitch_scale <= 0.0 is true"
	var new_pitch = angular_velocity.length() / 20.0
	$AudioStreamPlayer3D.pitch_scale = max(0.01, new_pitch)

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
		var point = ray.get_collision_point() # parameter shadowing fix

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
