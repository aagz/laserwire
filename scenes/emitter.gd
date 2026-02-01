extends Area2D
class_name Emitter


var line_core: Line2D
var line_glow: Line2D
var impact: Sprite2D

var glow_shader := load("res://shaders/laser_glow.gdshader") as Shader

@onready var raycast = $Laser2DWithLine
@onready var outline = $Outline
@onready var core = $Core

@onready var laser_id = str(randi())

const MAX_LEN := 10000.0
const MAX_BOUNCES := 25
const EPS := 0.5

@export var main_color := Color.RED

var lerp_time := randf_range(280,320)


var current_receiver

func _ready() -> void:
	
	raycast.enabled = true
	
	monitorable = true
	
	#raycast.collision_layer = Collision.LAYERS["laser"]
	raycast.collision_mask = Collision.LAYERS["wall"] | Collision.LAYERS["mirror"] | Collision.LAYERS["mirror_reflect"] | Collision.LAYERS["receiver"] | Collision.LAYERS["emitter"]
	#position = Vector2(100, 100)

	# --- Lines ---
	line_core = Line2D.new()
	line_core.z_index = 3
	line_glow = Line2D.new()
	line_glow.z_index = 2
	
	


	for l in [line_glow, line_core]:
		l.joint_mode = Line2D.LINE_JOINT_ROUND
		l.begin_cap_mode = Line2D.LINE_CAP_ROUND
		l.end_cap_mode = Line2D.LINE_CAP_ROUND
		l.antialiased = true
		l.top_level = true
		
		#var glow_material := ShaderMaterial.new()
		#glow_material.shader = glow_shader
		#
		#l.material = glow_material
		#
		#glow_material.set_shader_parameter("glow_strength",10.5)
		#glow_material.set_shader_parameter("softness ", 2.5)
		outline.default_color = main_color
		core.color = main_color
		
		get_parent().call_deferred("add_child", l)

	# core
	line_core.width = 3
	line_core.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line_core.default_color = main_color
	var mat_add_core := CanvasItemMaterial.new()
	mat_add_core.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	line_core.material = mat_add_core

	### glow
	line_glow.default_color = Color(main_color, 0.1)
	var mat_add_glow := CanvasItemMaterial.new()
	mat_add_glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	line_glow.material = mat_add_glow

	# --- Impact sprite ---
	impact = Sprite2D.new()
	impact.texture = preload("res://glowing_circle.png")
	impact.top_level = true
	impact.z_index = 10
	get_parent().call_deferred("add_child", impact)

	var impact_mat := CanvasItemMaterial.new()
	impact_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	impact.material = impact_mat
	impact.modulate = main_color

func _process(_delta: float) -> void:
	line_glow.width = 6 + 2 * sin(Time.get_ticks_msec() / lerp_time)
	line_glow.default_color = Color(main_color, 0.1 + 0.2 * sin(Time.get_ticks_msec() / lerp_time))

func _physics_process(_dt: float) -> void:
	var start_origin := global_position
	var origin := global_position

	var pts := PackedVector2Array()
	pts.append(origin)

	var mouse_g := Vector2(global_position.x + 100, global_position.y)# Vector2(200,100) # get_global_mouse_position()
	var dir := (mouse_g - origin).normalized()

	var remaining := MAX_LEN
	var last_point := origin
	

	for _i in MAX_BOUNCES:
		global_position = origin
		raycast.target_position = dir * remaining
		raycast.force_raycast_update()

		if !raycast.is_colliding():
			last_point = origin + dir * remaining
			pts.append(last_point)
			break

		var pt: Vector2 = raycast.get_collision_point()
		var n : Vector2 = raycast.get_collision_normal()
		pts.append(pt)
		last_point = pt

		var collider : Object = raycast.get_collider()
		if current_receiver and !collider.is_in_group("mirror") and !collider.is_in_group("receiver"):
			current_receiver.laser_exited(laser_id)
			current_receiver = null
		elif collider == null:
			break
		elif collider.is_in_group("receiver"):
			var receiver = collider
			current_receiver = receiver
			receiver.laser_entered(laser_id, main_color)
			break
		elif !collider.is_in_group("mirror"):
			break

		remaining -= origin.distance_to(pt)
		if remaining <= 0.0:
			break

		dir = dir.bounce(n)
		origin = pt + dir * EPS

	# вернуть RayCast2D на место
	global_position = start_origin

	# применяем точки к линиям
	line_core.points = pts
	line_glow.points = pts

	# точка на конце
	impact.global_position = last_point
	impact.scale = Vector2.ONE * (0.4 + 0.15 * sin(Time.get_ticks_msec() / lerp_time))
