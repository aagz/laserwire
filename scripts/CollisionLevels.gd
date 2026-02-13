extends Node

const layer_names := [
	"service",
	"emitter",
	"receiver",
	"laser",
	"wall",
	"mirror",
	"mirror_reflect",
]

var LAYERS := {}

func _ready():
	for i in range(layer_names.size()):
		LAYERS[layer_names[i]] = 1 << i
