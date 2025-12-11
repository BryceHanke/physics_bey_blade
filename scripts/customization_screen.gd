extends Control

@onready var upper_ring_selector = $Panel/VBoxContainer/UpperRingSelector
@onready var lower_ring_selector = $Panel/VBoxContainer/LowerRingSelector
@onready var metal_selector = $Panel/VBoxContainer/MetalSelector
@onready var tip_selector = $Panel/VBoxContainer/TipSelector
@onready var preview_blade = $PreviewContainer/SubViewport/PreviewWorld/BladePivot/ModularBlade
@onready var blade_pivot = $PreviewContainer/SubViewport/PreviewWorld/BladePivot

func _ready():
	# Populate UI
	for i in range(Global.upper_rings.size()):
		upper_ring_selector.add_item(Global.upper_rings[i]["name"], i)

	for i in range(Global.lower_rings.size()):
		lower_ring_selector.add_item(Global.lower_rings[i]["name"], i)

	for i in range(Global.metals.size()):
		metal_selector.add_item(Global.metals[i]["name"], i)

	for i in range(Global.tips.size()):
		tip_selector.add_item(Global.tips[i]["name"], i)

	# Connect Signals
	upper_ring_selector.item_selected.connect(_on_part_changed)
	lower_ring_selector.item_selected.connect(_on_part_changed)
	metal_selector.item_selected.connect(_on_part_changed)
	tip_selector.item_selected.connect(_on_part_changed)
	$Panel/VBoxContainer/SpawnButton.pressed.connect(_on_spawn_pressed)

	# Initial Setup
	_on_part_changed(0)

func _process(delta):
	blade_pivot.rotate_y(delta * 0.5)

func _on_part_changed(_index):
	var config = {
		"upper_ring": upper_ring_selector.selected,
		"lower_ring": lower_ring_selector.selected,
		"metal": metal_selector.selected,
		"tip": tip_selector.selected
	}
	Global.current_config = config

	# Update Preview
	preview_blade.setup(config)

func _on_spawn_pressed():
	hide()
	Global.is_customizing = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
