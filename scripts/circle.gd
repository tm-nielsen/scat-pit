@tool
class_name Circle
extends Node2D

@export var radius: float = 10: set = _set_radius;
@export var fill_colour := Color.WHITE: set = _set_fill_colour
@export var stroke_colour := Color.BLACK: set = _set_stroke_colour
@export var stroke_width: float = 4: set = _set_stroke_width


func _draw():
    draw_circle(Vector2.ZERO, radius, fill_colour)
    draw_circle(Vector2.ZERO, radius, stroke_colour, false, stroke_width)


func _set_radius(value: float):
    radius = value
    queue_redraw()

func _set_fill_colour(value: Color):
    fill_colour = value
    queue_redraw()

func _set_stroke_colour(value: Color):
    stroke_colour = value
    queue_redraw()

func _set_stroke_width(value: float):
    stroke_width = value
    queue_redraw()