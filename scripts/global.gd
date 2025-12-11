extends Node

var is_customizing = false

var current_config = {
	"tip": 0,
	"metal": 0,
	"upper_ring": 0,
	"lower_ring": 0
}

var tips = [
	{
		"name": "Sharp Tip",
		"scene": preload("res://scenes/parts/tips/SharpTip.tscn"),
		"mass": 0.05,
		"friction": 0.05,
		"stability": 2.0,
		"movement_speed": 10.0,
		"stamina_drain": 0.5,
		"color": Color(0.8, 0.2, 0.2)
	},
	{
		"name": "Flat Tip",
		"scene": preload("res://scenes/parts/tips/FlatTip.tscn"),
		"mass": 0.05,
		"friction": 0.3,
		"stability": 1.0,
		"movement_speed": 50.0,
		"stamina_drain": 2.0,
		"color": Color(0.2, 0.2, 0.8)
	},
	{
		"name": "Wide Tip",
		"scene": preload("res://scenes/parts/tips/FlatTip.tscn"), # Reusing FlatTip scene
		"mass": 0.08,
		"friction": 0.2,
		"stability": 1.5,
		"movement_speed": 40.0,
		"stamina_drain": 1.5,
		"color": Color(0.5, 0.0, 0.5)
	},
	{
		"name": "Rubber Tip",
		"scene": preload("res://scenes/parts/tips/FlatTip.tscn"), # Reusing FlatTip scene
		"mass": 0.06,
		"friction": 0.6,
		"stability": 0.8,
		"movement_speed": 80.0,
		"stamina_drain": 4.0,
		"color": Color(0.1, 0.1, 0.1)
	}
]

var metals = [
	{
		"name": "Standard Metal",
		"scene": preload("res://scenes/parts/metals/Metal1.tscn"),
		"mass": 0.5,
		"defense": 1.0,
		"radius": 0.235,
		"height": 0.1,
		"color": Color(0.7, 0.7, 0.7)
	},
	{
		"name": "Heavy Metal",
		"scene": preload("res://scenes/parts/metals/Metal2.tscn"),
		"mass": 0.8,
		"defense": 1.5,
		"radius": 0.25,
		"height": 0.15,
		"color": Color(0.3, 0.3, 0.3)
	},
	{
		"name": "Light Metal",
		"scene": preload("res://scenes/parts/metals/Metal1.tscn"),
		"mass": 0.3,
		"defense": 0.5,
		"radius": 0.22,
		"height": 0.08,
		"color": Color(0.9, 0.9, 0.9)
	},
	{
		"name": "Dense Metal",
		"scene": preload("res://scenes/parts/metals/Metal2.tscn"),
		"mass": 1.0,
		"defense": 2.0,
		"radius": 0.24,
		"height": 0.12,
		"color": Color(0.8, 0.7, 0.2)
	}
]

var upper_rings = [
	{
		"name": "Storm Ring",
		"scene": preload("res://scenes/parts/rings/Ring1.tscn"),
		"mass": 0.1,
		"attack": 1.2,
		"radius": 0.28,
		"height": 0.05,
		"color": Color(1.0, 0.8, 0.0)
	},
	{
		"name": "Shield Ring",
		"scene": preload("res://scenes/parts/rings/Ring2.tscn"),
		"mass": 0.15,
		"attack": 0.8,
		"radius": 0.30,
		"height": 0.08,
		"color": Color(0.0, 0.8, 0.2)
	},
	{
		"name": "Spike Ring",
		"scene": preload("res://scenes/parts/rings/Ring1.tscn"),
		"mass": 0.08,
		"attack": 1.5,
		"radius": 0.29,
		"height": 0.04,
		"color": Color(1.0, 0.0, 0.0)
	},
	{
		"name": "Balance Ring",
		"scene": preload("res://scenes/parts/rings/Ring2.tscn"),
		"mass": 0.12,
		"attack": 1.0,
		"radius": 0.285,
		"height": 0.06,
		"color": Color(0.0, 0.5, 1.0)
	}
]

var lower_rings = [
	{
		"name": "Support Ring",
		"scene": preload("res://scenes/parts/rings/Ring1.tscn"),
		"mass": 0.1,
		"attack": 1.0,
		"radius": 0.28,
		"height": 0.05,
		"color": Color(0.5, 0.5, 0.5)
	},
	{
		"name": "Guard Ring",
		"scene": preload("res://scenes/parts/rings/Ring2.tscn"),
		"mass": 0.15,
		"attack": 0.6,
		"radius": 0.30,
		"height": 0.08,
		"color": Color(0.2, 0.8, 0.8)
	},
	{
		"name": "Wide Ring",
		"scene": preload("res://scenes/parts/rings/Ring2.tscn"),
		"mass": 0.2,
		"attack": 0.8,
		"radius": 0.32,
		"height": 0.05,
		"color": Color(0.6, 0.2, 0.8)
	},
	{
		"name": "Feather Ring",
		"scene": preload("res://scenes/parts/rings/Ring1.tscn"),
		"mass": 0.05,
		"attack": 1.1,
		"radius": 0.27,
		"height": 0.04,
		"color": Color(0.9, 1.0, 0.9)
	}
]
