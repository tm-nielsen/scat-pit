@tool
class_name Arc
extends Circle

@export_range(0, TAU) var start_angle: float = 0: set = _set_start_angle
@export_range(0, TAU) var end_angle: float = TAU: set = _set_end_angle
@export var point_count: int = 12: set = _set_point_count


func _draw():
    var points = generate_arc()
    draw_colored_polygon(points, fill_colour)
    draw_polyline(points, stroke_colour, stroke_width)


func generate_arc() -> PackedVector2Array:
    var points = PackedVector2Array()

    for i in range(point_count + 1):
        var angle = lerp(start_angle, end_angle, float(i) / point_count)
        points.push_back(Vector2(cos(angle), sin(angle)) * radius)

    return points


func _set_start_angle(value: float):
    start_angle = value
    queue_redraw()

func _set_end_angle(value: float):
    end_angle = value
    queue_redraw()

func _set_point_count(value: int):
    point_count = value
    queue_redraw()