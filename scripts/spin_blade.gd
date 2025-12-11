extends Node3D

var blades = []

@onready var camera_3d = $cam_holder/Camera3D

const MODULAR_BLADE = preload("res://scenes/ModularBlade.tscn")
const CUSTOMIZATION_SCREEN = preload("res://scenes/CustomizationScreen.tscn")

var throw_force = 50
var customization_instance

func _ready():
	customization_instance = CUSTOMIZATION_SCREEN.instantiate()
	add_child(customization_instance)
	customization_instance.hide() # Hidden by default, or shown if menu is start

func _process(delta):
	# Toggle Customization Screen
	if Input.is_action_just_pressed("ui_cancel"): # Escape key usually
		if customization_instance.visible:
			customization_instance.hide()
			Global.is_customizing = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			customization_instance.show()
			Global.is_customizing = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_just_pressed("mouse"):
		for i in blades:
			i.queue_free()
		blades.clear()

	# Spawn Custom Blade
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_left"):
		# Only spawn if menu is not visible
		if not customization_instance.visible:
			spawn_blade()

func spawn_blade():
	var new_blade = MODULAR_BLADE.instantiate()
	get_tree().current_scene.add_child(new_blade)
	blades.append(new_blade)

	new_blade.setup(Global.current_config)

	new_blade.global_position = camera_3d.global_position - camera_3d.global_basis.z
	new_blade.apply_impulse(-camera_3d.global_basis.z * 10) # Throw forward
	new_blade.apply_torque_impulse(Vector3(0, throw_force, 0)) # Spin
