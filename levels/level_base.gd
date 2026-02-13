extends Node2D


signal level_completed 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_completed.connect(get_tree().root.get_node("Main").on_level_completed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
