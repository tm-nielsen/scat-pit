class_name MonkeyScaler
extends Node2D

var size: float = 1: set = _set_size

@export var colliders: Array[CollisionShape2D]
@export var circles: Array[Circle]
@export var eyes: Array[Eye]
@export var mouth: Mouth

var scalers: Array[Node2DScaler]


func _ready():
    scalers = []
    for target in colliders: scalers.push_back(
        CollisionCircleScaler.new(target)
    )
    for target in circles: scalers.push_back(
        CircleScaler.new(target)
    )
    for target in eyes: scalers.push_back(
        EyeScaler.new(target)
    )
    scalers.push_back(MouthScaler.new(mouth))


func _set_size(value: float):
    size = value
    for target in scalers: target.scale(value)


class EyeScaler extends Node2DScaler:
    var collider_scaler: CollisionCircleScaler
    var circle_scaler: CircleScaler

    func _init(eye_node: Eye):
        super(eye_node)
        collider_scaler = CollisionCircleScaler.new(eye_node.collider)
        circle_scaler = CircleScaler.new(eye_node.circle)

    func scale(value: float):
        target.base_position = base_position * value
        collider_scaler.scale(value)
        circle_scaler.scale(value)


class MouthScaler extends Node2DScaler:
    var base_normal_radius: float

    func _init(mouth_node: Mouth):
        super(mouth_node)
        base_normal_radius = mouth_node.normal_radius

    func scale(value: float):
        super(value)
        target.normal_radius = base_normal_radius * value


class CollisionCircleScaler extends Node2DScaler:
    var target_shape: CircleShape2D
    var base_radius: float

    func _init(shape_node: CollisionShape2D):
        super(shape_node)
        target_shape = shape_node.shape
        base_radius = target_shape.radius

    func scale(value: float):
        super(value)
        target_shape.radius = base_radius * value


class CircleScaler extends Node2DScaler:
    var base_radius: float

    func _init(circle_node: Circle):
        super(circle_node)
        base_radius = target.radius

    func scale(value: float):
        super(value)
        target.radius = base_radius * value
