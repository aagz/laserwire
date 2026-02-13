extends Area2D
class_name Wall

@onready var color_rect := $Visual/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	collision_layer = Collision.LAYERS["wall"]
	collision_mask = Collision.LAYERS["mirror"]
	monitoring = true  # Включает обнаружение
	monitorable = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
