extends Area2D
class_name RotationWheel

@onready var rotation_shape : CollisionShape2D = $CollisionShape2D
@onready var mirror : Mirror = get_parent()

var dragging := false
var alpha : float = 0.0
var tween : Tween

var prev_local_angle : float = 0.0
var target_rotation : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	
	input_pickable = mirror.rotateable
	#monitoring = false
	rotation_shape.disabled = !mirror.rotateable  # Shape active

func _on_mouse_enter():
	_rotation_wheel_tween_alpha(0.05)

func _process(_delta):
	var local = to_local(get_global_mouse_position())
	var hovered = local.length() <= 50.0
	var target_alpha = 0.15 if hovered or dragging else 0.0
	if abs(alpha - target_alpha) > 0.01:  # Только если изменилось
		_rotation_wheel_tween_alpha(target_alpha)

func _rotation_wheel_tween_alpha(target: float) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "alpha", target, 0.3).set_ease(Tween.EASE_IN_OUT)
	queue_redraw()
	
func _draw():
	draw_arc(Vector2.ZERO, 50, 0, TAU, 32, Color(Color.WHITE, alpha), 1, true)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var local = to_local(event.global_position)
		if local.length() <= rotation_shape.shape.radius:
			dragging = event.pressed
			if dragging:
				prev_local_angle = local.angle()

func _physics_process(delta):
	if Input.is_action_just_released("ui_left_mouse_button"):
		dragging = false
	
	if dragging and mirror.rotateable:
		var mouse_pos = to_local(get_global_mouse_position())
		var angle = mouse_pos.angle()
		var delta_angle = angle - prev_local_angle
		
		target_rotation += delta_angle
		prev_local_angle = angle
		
		# Сглаживание ТОЛЬКО при dragging
		get_parent().rotation = lerp_angle(get_parent().rotation, target_rotation, delta * 20)
