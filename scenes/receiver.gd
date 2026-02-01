extends Area2D
class_name Receiver

@onready var outline : Line2D = $Outline
@onready var core : Polygon2D = $Core

@export var expected_color: Color = Color("#e145b8")

var _incoming_lasers := {}
var active := false
var default_color := Color("#222")

var target_color : Color = default_color
var lerp_speed := 5.0

func _ready() -> void:
	outline.default_color = expected_color
	add_to_group("receiver")
	collision_layer = Collision.LAYERS["receiver"]
	
	monitorable = true
	 

func _process(delta: float) -> void:
	core.color = core.color.lerp(target_color, lerp_speed * delta)

func laser_entered(laser_id, color):
	#print(laser_id, color)
	_incoming_lasers[laser_id] = color
	_update_color()
	
func laser_exited(laser_id):
	_incoming_lasers.erase(laser_id)
	_update_color()

func _update_color():
	var laser_colors = _incoming_lasers.values()
	target_color = mix_lasers_hsv(laser_colors) 


# colors: массив объектов Color
# default_color: цвет по умолчанию, если нет активных лазеров
func mix_lasers_hsv(colors: Array) -> Color:
	if !colors.size():
		return default_color

	var sum_x = 0.0  # для усреднения Hue по кругу (cos)
	var sum_y = 0.0  # для усреднения Hue по кругу (sin)
	var sum_s = 0.0  # суммарная насыщенность
	var sum_v = 0.0  # суммарная яркость / value

	# проходим по всем цветам
	for c in colors:
		# Hue в Godot уже 0..1, умножаем на 2π чтобы получить угол в радианах
		var angle = c.h * 2.0 * PI
		sum_x += cos(angle)  # проекция на X
		sum_y += sin(angle)  # проекция на Y

		sum_s += c.s  # накапливаем Saturation
		sum_v += c.v  # накапливаем Value / Brightness

	var n = colors.size()

	# Усредняем проекции X и Y
	sum_x /= n
	sum_y /= n

	# Вычисляем средний угол обратно
	var avg_h = atan2(sum_y, sum_x) / (2.0 * PI)
	if avg_h < 0:
		avg_h += 1.0  # Hue в Godot должен быть 0..1

	# Усредняем Saturation и Value линейно
	var avg_s = sum_s / n
	var avg_v = sum_v / n

	# Возвращаем итоговый цвет
	return Color.from_hsv(avg_h, avg_s, avg_v)
