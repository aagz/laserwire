extends RayCast2D

var line_core: Line2D
var line_glow: Line2D
var impact: Sprite2D

var glow_shader := load("res://shaders/laser_glow.gdshader") as Shader

const MAX_LEN := 10000.0
const MAX_BOUNCES := 25
const EPS := 0.5

func _ready() -> void:
	enabled = true
	position = Vector2(100, 100)

	# --- Lines ---
	line_core = Line2D.new()
	line_glow = Line2D.new()
	
	#var glow_material := ShaderMaterial.new()
	#glow_material.shader = glow_shader
	#
	#line_glow.material = glow_material
	#
	#glow_material.set_shader_parameter("glow_intensity ", 6.0)
	#glow_material.set_shader_parameter("core_width ", 1.0)
	#glow_material.set_shader_parameter("core_length ", 1.0) 

	for l in [line_glow, line_core]:
		l.joint_mode = Line2D.LINE_JOINT_ROUND
		l.begin_cap_mode = Line2D.LINE_CAP_ROUND
		l.end_cap_mode = Line2D.LINE_CAP_ROUND
		l.antialiased = true
		l.top_level = true
		get_parent().call_deferred("add_child", l)

	# core
	line_core.width = 3
	line_core.default_color = Color("d700e0ff")
	var mat_add_core := CanvasItemMaterial.new()
	mat_add_core.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	line_core.material = mat_add_core

	## glow
	line_glow.width = 8
	line_glow.default_color = Color("fc8aff4d")
	var mat_add_glow := CanvasItemMaterial.new()
	mat_add_glow.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
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

func _physics_process(_dt: float) -> void:
	var start_origin := global_position
	var origin := global_position

	var pts := PackedVector2Array()
	pts.append(origin)

	var mouse_g := Vector2(200,100) # get_global_mouse_position()
	var dir := (mouse_g - origin).normalized()

	var remaining := MAX_LEN
	var last_point := origin

	for _i in MAX_BOUNCES:
		global_position = origin
		target_position = dir * remaining
		force_raycast_update()

		if !is_colliding():
			last_point = origin + dir * remaining
			pts.append(last_point)
			break

		var pt := get_collision_point()
		var n := get_collision_normal()
		pts.append(pt)
		last_point = pt

		var collider := get_collider()
		if collider == null or !collider.is_in_group("mirror"):
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
	impact.scale = Vector2.ONE * (0.9 + 0.15 * sin(Time.get_ticks_msec() / 80.0))
