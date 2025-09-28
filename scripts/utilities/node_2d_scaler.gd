class_name Node2DScaler

var target: Node2D
var base_position: Vector2

func _init(node: Node2D):
    target = node
    base_position = target.position

func scale(value: float):
    target.position = base_position * value