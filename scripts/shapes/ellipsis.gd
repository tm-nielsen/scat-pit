@tool
class_name Ellipsis
extends Circle

@export var ratio: float = 2: set = _set_ratio
@export var point_count: int = 12: set = _set_point_count


func _draw():
    var points := generate_ellipsis()
    draw_colored_polygon(points, fill_colour)
    points.push_back(points[0])
    draw_polyline(points, stroke_colour, stroke_width)


func generate_ellipsis() -> PackedVector2Array:
    var points = PackedVector2Array()
    var tangent = radius * Vector2.RIGHT
    var normal = radius * ratio * Vector2.UP

    for i in point_count:
        var angle = TAU * i / point_count
        points.push_back(tangent * cos(angle) + normal * sin(angle))

    return points


func _set_ratio(value: float):
    ratio = value
    queue_redraw()

func _set_point_count(value: int):
    point_count = value
    queue_redraw()