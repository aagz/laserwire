extends StaticBody2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	input_pickable = true
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect_Mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				var mb := event as InputEventMouseButton
				var mouse_world: Vector2 = get_canvas_transform().affine_inverse() * mb.position
				drag_offset = mouse_world - global_position
			else:
				dragging = false
				
		if Input.is_action_just_released("ui_left_mouse_button"):
			dragging = false
				
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation += 0.025
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation -= 0.025
			

			
	

func _process(_dt: float) -> void:
	if dragging:
		var mouse_world: Vector2 = get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
		global_position = mouse_world - drag_offset
