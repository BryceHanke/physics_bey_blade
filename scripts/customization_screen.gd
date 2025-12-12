extends Control

@onready var upper_ring_selector = $Panel/VBoxContainer/UpperRingSelector
@onready var lower_ring_selector = $Panel/VBoxContainer/LowerRingSelector
@onready var metal_selector = $Panel/VBoxContainer/MetalSelector
@onready var tip_selector = $Panel/VBoxContainer/TipSelector
@onready var preview_blade = $PreviewContainer/SubViewport/PreviewWorld/BladePivot/ModularBlade
@onready var blade_pivot = $PreviewContainer/SubViewport/PreviewWorld/BladePivot

var material_selector : OptionButton
var scale_slider : HSlider
var scale_label : Label

func _ready():
	# Create Material Selector (Dynamically adding to VBoxContainer)
	var container = $Panel/VBoxContainer

	# Material Label
	var mat_label = Label.new()
	mat_label.text = "Material"
	container.add_child(mat_label)
	container.move_child(mat_label, 4) # Adjust position

	material_selector = OptionButton.new()
	container.add_child(material_selector)
	container.move_child(material_selector, 5) # Adjust position

	# Scale Label
	var scl_label = Label.new()
	scl_label.text = "Scale"
	container.add_child(scl_label)
	container.move_child(scl_label, 6)

	# Scale Slider
	scale_slider = HSlider.new()
	scale_slider.min_value = 0.5
	scale_slider.max_value = 1.5
	scale_slider.step = 0.05
	scale_slider.value = 1.0
	container.add_child(scale_slider)
	container.move_child(scale_slider, 7)

	scale_label = Label.new()
	scale_label.text = "1.0x"
	container.add_child(scale_label)
	container.move_child(scale_label, 8)

	# Move Spawn Button to end
	container.move_child($Panel/VBoxContainer/SpawnButton, 9)

	# Populate UI
	for i in range(Global.upper_rings.size()):
		upper_ring_selector.add_item(Global.upper_rings[i]["name"], i)

	for i in range(Global.lower_rings.size()):
		lower_ring_selector.add_item(Global.lower_rings[i]["name"], i)

	for i in range(Global.metals.size()):
		metal_selector.add_item(Global.metals[i]["name"], i)

	for i in range(Global.tips.size()):
		tip_selector.add_item(Global.tips[i]["name"], i)

	for i in range(Global.materials.size()):
		material_selector.add_item(Global.materials[i]["name"], i)

	# Connect Signals
	upper_ring_selector.item_selected.connect(_on_part_changed)
	lower_ring_selector.item_selected.connect(_on_part_changed)
	metal_selector.item_selected.connect(_on_part_changed)
	tip_selector.item_selected.connect(_on_part_changed)
	material_selector.item_selected.connect(_on_part_changed)
	scale_slider.value_changed.connect(_on_scale_changed)
	$Panel/VBoxContainer/SpawnButton.pressed.connect(_on_spawn_pressed)

	# Initial Setup
	_on_part_changed(0)

func _process(delta):
	blade_pivot.rotate_y(delta * 0.5)

func _on_scale_changed(value):
	scale_label.text = str(value) + "x"
	_on_part_changed(0)

func _on_part_changed(_index):
	var config = {
		"upper_ring": upper_ring_selector.selected,
		"lower_ring": lower_ring_selector.selected,
		"metal": metal_selector.selected,
		"tip": tip_selector.selected,
		"material": material_selector.selected,
		"scale": scale_slider.value
	}
	Global.current_config = config

	# Update Preview
	preview_blade.setup(config)

func _on_spawn_pressed():
	hide()
	Global.is_customizing = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
