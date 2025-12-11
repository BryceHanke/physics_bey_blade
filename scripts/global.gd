extends Node

var current_config = {
	"tip": 0,
	"metal": 0,
	"ring": 0
}

var tips = [
	{
		"name": "Sharp Tip",
		"scene": preload("res://scenes/parts/tips/SharpTip.tscn"),
		"mass": 0.05,
		"friction": 0.05,
		"stability": 2.0,
		"movement_speed": 10.0,
		"stamina_drain": 0.5
	},
	{
		"name": "Flat Tip",
		"scene": preload("res://scenes/parts/tips/FlatTip.tscn"),
		"mass": 0.05,
		"friction": 0.3,
		"stability": 1.0,
		"movement_speed": 50.0,
		"stamina_drain": 2.0
	}
]

var metals = [
	{
		"name": "Standard Metal",
		"scene": preload("res://scenes/parts/metals/Metal1.tscn"),
		"mass": 0.5,
		"defense": 1.0,
		"radius": 0.235,
		"height": 0.1
	},
	{
		"name": "Heavy Metal",
		"scene": preload("res://scenes/parts/metals/Metal2.tscn"),
		"mass": 0.8,
		"defense": 1.5,
		"radius": 0.25,
		"height": 0.15
	}
]

var rings = [
	{
		"name": "Storm Ring",
		"scene": preload("res://scenes/parts/rings/Ring1.tscn"),
		"mass": 0.1,
		"attack": 1.2,
		"radius": 0.28,
		"height": 0.05
	},
	{
		"name": "Shield Ring",
		"scene": preload("res://scenes/parts/rings/Ring2.tscn"),
		"mass": 0.15,
		"attack": 0.8,
		"radius": 0.30,
		"height": 0.08
	}
]
