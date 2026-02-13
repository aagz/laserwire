extends Node2D

var receivers : Array[Node]

@onready var level_container: Node2D = $LevelContainer
var level: Node2D

var current_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var language = "automatic"
	# Load here language from the user settings file
	if language == "automatic":
		var preferred_language = OS.get_locale_language()
		TranslationServer.set_locale(preferred_language)
	else:
		TranslationServer.set_locale(language)
	
	init_level(current_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(receivers)
	pass

func init_level(number: int):
	#receivers = get_tree().get_nodes_in_group("receivers")
	for child in level_container.get_children():
		child.queue_free()
		
	
	level = load("res://levels/level_%d.tscn" % number).instantiate()
	level_container.add_child(level)

func on_level_completed():
	current_level += 1
	init_level(current_level)
