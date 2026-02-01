extends Node2D

var receivers : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	init_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(receivers)
	pass

func init_level():
	receivers = get_tree().get_nodes_in_group("receivers")
	
	
