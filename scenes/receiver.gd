extends Node2D

signal laser_entered(color: Color)
signal laser_exited()

@export var expected_color: Color = Color.RED
var active := false
var default_color := Color.GRAY


func on_laser_hit(laser_color: Color):
	if laser_color == expected_color:
		if not active:
			active = true
			$Polygon2D.color = laser_color
			emit_signal("laser_entered", laser_color)
