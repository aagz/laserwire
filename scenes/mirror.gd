extends Area2D
class_name Mirror

var dragging := false
var drag_offset := Vector2.ZERO

var wheel_dragging := false
 
@onready var correct : Node2D = $Visual/Correct
@onready var wrong : Node2D = $Visual/Wrong

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

@onready var reflection_surface : Area2D = $Reflection_Surface
@onready var mirror_shape : CollisionShape2D = $Reflection_Surface/CollisionShape2D

@onready var rotation_wheel : Area2D = $RotationWheel
@onready var rotation_shape : CollisionShape2D = $RotationWheel/CollisionShape2D


func _ready() -> void:
	input_pickable = true
	
	for s in [$Visual/Correct/ColorRect_Wall, $Visual/Correct/ColorRect_Mirror, $Visual/Wrong/ColorRect2]:
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	collision_layer = Collision.LAYERS["mirror"]
	collision_mask = Collision.LAYERS["wall"] | Collision.LAYERS["emitter"] | Collision.LAYERS["receiver"] | Collision.LAYERS["mirror"]
	reflection_surface.collision_layer = Collision.LAYERS["mirror_reflect"]
	reflection_surface.collision_mask = Collision.LAYERS["wall"] | Collision.LAYERS["mirror"]
	rotation_wheel.collision_layer = 1
	rotation_wheel.collision_mask = 0
	
	reflection_surface.add_to_group("mirror")
	
	monitoring = true
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	rotation_wheel.input_pickable = true
	rotation_wheel.input_event.connect(_on_rotation_wheel_input)
	rotation_wheel.monitoring = false  # Только input, не area events
	rotation_shape.disabled = false  # Shape active

func _on_area_entered(area):
	print("Collide with ", area.name)
	if area.get_parent() == self or area == self: return
	
	correct.visible = false
	wrong.visible = true
	mirror_shape.set_deferred("disabled", true)
	
func _on_area_exited(area):
	print("Exit from ", area.name)
	correct.visible = true
	wrong.visible = false
	mirror_shape.set_deferred("disabled", false)
	
func _on_rotation_wheel_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	
	print("Wheel clicked! shape_idx: ", _shape_idx)  # Debug
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		wheel_dragging = event.pressed  # Hold для вращения
		
func _draw():
	draw_arc(Vector2.ZERO, 50, 0, 360, 32, Color(Color.WHITE, 0.05), 1, true)

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
		
	if wheel_dragging:
		var wheel_center = rotation_wheel.global_position
		var mouse_pos = get_global_mouse_position()
		var angle = wheel_center.angle_to(mouse_pos)
		rotation = angle - PI/2  # Offset для "look right"
		print("Wheel rotate to mouse angle:", rad_to_deg(angle))
