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

func calculate_cylinder_inertia(m, r, h):
	var I_y = 0.5 * m * r * r
	var I_xz = (1.0/12.0) * m * (3*r*r + h*h)
	return Vector3(I_xz, I_y, I_xz)

func calculate_hollow_cylinder_inertia(m, r_in, r_out, h):
	var I_y = 0.5 * m * (r_in*r_in + r_out*r_out)
	var I_xz = (1.0/12.0) * m * (3*(r_in*r_in + r_out*r_out) + h*h)
	return Vector3(I_xz, I_y, I_xz)

func setup(config):
	# Clear existing parts
	for child in $Visuals/Tip.get_children(): child.queue_free()
	for child in $Visuals/Metal.get_children(): child.queue_free()
	for child in $Visuals/UpperRing.get_children(): child.queue_free()
	for child in $Visuals/LowerRing.get_children(): child.queue_free()

	# Get Config Properties
	var scale_factor = config.get("scale", 1.0)
	var material_idx = config.get("material", 0)
	var material_data = Global.materials[material_idx] if material_idx < Global.materials.size() else Global.materials[0]

	# Load Tip
	var tip_data = Global.tips[config["tip"]]
	var tip_instance = tip_data["scene"].instantiate()
	$Visuals/Tip.add_child(tip_instance)
	if "color" in tip_data:
		apply_color(tip_instance, tip_data["color"] * material_data["color_tint"])

	# Load Metal
	var metal_data = Global.metals[config["metal"]]
	var metal_instance = metal_data["scene"].instantiate()
	$Visuals/Metal.add_child(metal_instance)
	if "color" in metal_data:
		apply_color(metal_instance, metal_data["color"] * material_data["color_tint"])

	# Load Upper Ring
	var upper_ring_data = Global.upper_rings[config["upper_ring"]]
	var upper_ring_instance = upper_ring_data["scene"].instantiate()
	$Visuals/UpperRing.add_child(upper_ring_instance)
	if "color" in upper_ring_data:
		apply_color(upper_ring_instance, upper_ring_data["color"] * material_data["color_tint"])

	# Load Lower Ring
	var lower_ring_data = Global.lower_rings[config["lower_ring"]]
	var lower_ring_instance = lower_ring_data["scene"].instantiate()
	$Visuals/LowerRing.add_child(lower_ring_instance)
	if "color" in lower_ring_data:
		apply_color(lower_ring_instance, lower_ring_data["color"] * material_data["color_tint"])

	# Apply Scale to Visuals
	$Visuals.scale = Vector3(scale_factor, scale_factor, scale_factor)

	# --- PHYSICS UPDATE ---

	# 1. Update Colliders & Gather Dimensions
	var tip_radius = 0.1 * scale_factor
	var tip_height = 0.1 * scale_factor
	if has_node("TipCollider"):
		var tip_col = $TipCollider
		if tip_col.shape is SphereShape3D:
			tip_col.shape = tip_col.shape.duplicate()
			tip_col.shape.radius = tip_radius
		tip_col.position.y = -0.1 * scale_factor

	var metal_radius = metal_data.get("radius", 0.25) * scale_factor
	var metal_height = metal_data.get("height", 0.1) * scale_factor
	if has_node("MetalCollider"):
		var metal_col = $MetalCollider
		if metal_col.shape is CylinderShape3D:
			metal_col.shape = metal_col.shape.duplicate()
			metal_col.shape.radius = metal_radius
			metal_col.shape.height = metal_height

	var ur_radius = upper_ring_data.get("radius", 0.28) * scale_factor
	var ur_height = upper_ring_data.get("height", 0.05) * scale_factor
	if has_node("UpperRingCollider"):
		var ur_col = $UpperRingCollider
		ur_col.position.y = 0.08 * scale_factor
		if ur_col.shape is CylinderShape3D:
			ur_col.shape = ur_col.shape.duplicate()
			ur_col.shape.radius = ur_radius
			ur_col.shape.height = ur_height

	var lr_radius = lower_ring_data.get("radius", 0.28) * scale_factor
	var lr_height = lower_ring_data.get("height", 0.05) * scale_factor
	if has_node("LowerRingCollider"):
		var lr_col = $LowerRingCollider
		lr_col.position.y = 0.02 * scale_factor
		if lr_col.shape is CylinderShape3D:
			lr_col.shape = lr_col.shape.duplicate()
			lr_col.shape.radius = lr_radius
			lr_col.shape.height = lr_height

	# RayCast Scaling
	ray.target_position = Vector3(0, -0.2 * scale_factor * 1.5, 0) # Extended reach

	# 2. Mass Calculation
	var m_mult = material_data["mass_multiplier"]
	var volume_scale = scale_factor * scale_factor * scale_factor

	var m_tip = tip_data["mass"] * m_mult * volume_scale
	var m_metal = metal_data["mass"] * m_mult * volume_scale
	var m_ur = upper_ring_data["mass"] * m_mult * volume_scale
	var m_lr = lower_ring_data["mass"] * m_mult * volume_scale

	mass = m_tip + m_metal + m_ur + m_lr

	# 3. Center of Mass Calculation
	# Local Y positions relative to RigidBody origin
	var y_tip = -0.1 * scale_factor
	var y_metal = 0.0
	var y_ur = 0.08 * scale_factor
	var y_lr = 0.02 * scale_factor

	var com_y = (m_tip * y_tip + m_metal * y_metal + m_ur * y_ur + m_lr * y_lr) / mass

	center_of_mass_mode = CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0, com_y, 0)

	# 4. Inertia Calculation (Parallel Axis Theorem)
	var I_total = Vector3.ZERO

	# Tip (Solid Cylinder approx)
	var I_tip_local = calculate_cylinder_inertia(m_tip, tip_radius, tip_height)
	var d_tip = y_tip - com_y
	I_total.x += I_tip_local.x + m_tip * d_tip * d_tip
	I_total.z += I_tip_local.z + m_tip * d_tip * d_tip
	I_total.y += I_tip_local.y

	# Metal (Solid Cylinder)
	var I_metal_local = calculate_cylinder_inertia(m_metal, metal_radius, metal_height)
	var d_metal = y_metal - com_y
	I_total.x += I_metal_local.x + m_metal * d_metal * d_metal
	I_total.z += I_metal_local.z + m_metal * d_metal * d_metal
	I_total.y += I_metal_local.y

	# Upper Ring (Hollow Cylinder approx)
	var I_ur_local = calculate_hollow_cylinder_inertia(m_ur, metal_radius, ur_radius, ur_height)
	var d_ur = y_ur - com_y
	I_total.x += I_ur_local.x + m_ur * d_ur * d_ur
	I_total.z += I_ur_local.z + m_ur * d_ur * d_ur
	I_total.y += I_ur_local.y

	# Lower Ring (Hollow Cylinder approx)
	var I_lr_local = calculate_hollow_cylinder_inertia(m_lr, metal_radius, lr_radius, lr_height)
	var d_lr = y_lr - com_y
	I_total.x += I_lr_local.x + m_lr * d_lr * d_lr
	I_total.z += I_lr_local.z + m_lr * d_lr * d_lr
	I_total.y += I_lr_local.y

	inertia = I_total

	# Update Game Params
	spin_friction = tip_data["friction"] * material_data["friction_multiplier"]
	stability_factor = tip_data["stability"]
	movement_speed = tip_data["movement_speed"]
	stamina_drain_rate = tip_data["stamina_drain"]

	if physics_material_override:
		physics_material_override.bounce = material_data.get("bounce_multiplier", 0.0)
	else:
		var pm = PhysicsMaterial.new()
		pm.bounce = material_data.get("bounce_multiplier", 0.0)
		physics_material_override = pm

func _physics_process(delta):
	if not is_active: return

	# Handle Audio
	if ray.is_colliding():
		if not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.play()
	else:
		if $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.stop()

	var new_pitch = angular_velocity.length() / 20.0
	$AudioStreamPlayer3D.pitch_scale = max(0.01, new_pitch)

	# --- ENHANCED PHYSICS ---
	var speed = angular_velocity.length()
	var up_vector = global_transform.basis.y

	if speed < 0.1:
		is_active = false
		return

	# 1. Air Resistance (Torque-based, Quadratic)
	var air_drag = 0.00005 * stamina_drain_rate
	apply_torque( -angular_velocity * speed * air_drag )

	# 2. Stability (Restoring Torque)
	var target_up = Vector3.UP
	if ray.is_colliding():
		# Optional: You could align to surface normal, but UP is more "Top-like"
		pass

	var align_vec = up_vector.cross(target_up)
	var righting_strength = stability_factor * 2.0
	apply_torque(align_vec * righting_strength)

	# 3. Ground Interaction (Friction & Movement)
	if ray.is_colliding():
		var point = ray.get_collision_point()
		var normal = ray.get_collision_normal()
		var body_origin = global_transform.origin

		# Detect Ground Material Friction (Optional)
		var collider = ray.get_collider()
		var current_ground_friction = ground_friction # default
		if collider is PhysicsBody3D and collider.physics_material_override:
			current_ground_friction = collider.physics_material_override.friction

		# Vector from COM/Origin to contact point
		var r = point - body_origin

		# Velocity at contact point
		var v_point = linear_velocity + angular_velocity.cross(r)

		# Tangential component (plane of collision)
		var v_normal = v_point.project(normal)
		var v_tangent = v_point - v_normal

		if v_tangent.length() > 0.01:
			var friction_dir = -v_tangent.normalized()

			# Normal Force Approximation
			var gravity_comp = mass * 9.8 * max(0.0, up_vector.dot(Vector3.UP))

			# Effective Friction Coefficient
			var effective_friction = spin_friction * current_ground_friction

			var f_mag = gravity_comp * effective_friction

			# Apply Friction Force at Contact Point
			# This naturally induces torque (precession) and linear force (walking)
			apply_force(friction_dir * f_mag * 2.0, r)
