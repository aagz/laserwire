extends Area2D
class_name Mirror


@export var draggable = true
@export var rotateable = true
@export var size : Vector2 = Vector2(20, 72):
	set(value):
		size = value
		_apply_size()
		
var dragging := false
var drag_offset := Vector2.ZERO

 
@onready var correct : Node2D = $Visual/Correct
@onready var correct_color_rect_wall : ColorRect = $Visual/Correct/ColorRect_Wall
@onready var correct_color_rect_mirror : ColorRect = $Visual/Correct/ColorRect_Mirror

@onready var wrong : Node2D = $Visual/Wrong
@onready var wrong_color_rect : ColorRect = $Visual/Wrong/ColorRect

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

@onready var reflection_surface : Area2D = $Reflection_Surface
@onready var mirror_shape : CollisionShape2D = $Reflection_Surface/CollisionShape2D

@onready var rotation_wheel : RotationWheel = $RotationWheel
@onready var rotation_wheel_shape : CollisionShape2D = $RotationWheel/CollisionShape2D


func _ready() -> void:
	var mirror_scale := correct_color_rect_wall.scale
	
	input_pickable = draggable
	if !rotateable:
		rotation_wheel.visible = false
		rotation_wheel.monitoring = false
		rotation_wheel.monitorable = false
	
	for s in [$Visual/Correct/ColorRect_Wall, $Visual/Correct/ColorRect_Mirror, $Visual/Wrong/ColorRect]:
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	collision_layer = Collision.LAYERS["mirror"]
	collision_mask = Collision.LAYERS["wall"] | Collision.LAYERS["emitter"] | Collision.LAYERS["receiver"] | Collision.LAYERS["mirror"]
	reflection_surface.collision_layer = Collision.LAYERS["mirror_reflect"]
	reflection_surface.collision_mask = Collision.LAYERS["wall"] | Collision.LAYERS["mirror"]

	
	reflection_surface.add_to_group("mirror")
	#add_to_group("mirror")
	
	monitoring = true
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	

		
	


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

func _apply_size() -> void:
	if !is_node_ready(): return

	# ColorRect через офсеты (чтобы оставалось по центру)
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	$Visual/Correct/ColorRect_Wall.offset_left = -hx
	$Visual/Correct/ColorRect_Wall.offset_right = hx
	$Visual/Correct/ColorRect_Wall.offset_top = -hy
	$Visual/Correct/ColorRect_Wall.offset_bottom = hy

	$Visual/Wrong/ColorRect.offset_left = -hx
	$Visual/Wrong/ColorRect.offset_right = hx
	$Visual/Wrong/ColorRect.offset_top = -hy
	$Visual/Wrong/ColorRect.offset_bottom = hy

	# Коллизия корпуса
	var body := $CollisionShape2D.shape as RectangleShape2D
	if body: body.size = size

	# Поверхность отражения (пример: фиксируем ширину 8, высоту как у size)
	var surf := $Reflection_Surface/CollisionShape2D.shape as RectangleShape2D
	if surf: surf.size = Vector2(8, size.y)

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
				

				
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation += 0.025
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation -= 0.025
			
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_released("ui_left_mouse_button"):
		dragging = false
		
	if dragging:
		var mouse_world: Vector2 = get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
		global_position = mouse_world - drag_offset
		
