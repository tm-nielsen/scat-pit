extends Area2D

@export var minimum_radius: float = 20
@export var maximum_radius: float = 60
@export var edge_threshold: float = 10
@export var grow_speed: float = 20

@onready var circle: Circle = $Circle
@onready var collider_shape: CircleShape2D = $Collider.shape
@onready var radius := circle.radius


func _process(delta: float) -> void:
    radius += delta * grow_speed * (
        PitchAnalyser.average_magnitude
        * 0.5 * (
            1 - PitchAnalyser.low_range_share.x
            - PitchAnalyser.low_range_share.y
        )
    )
    radius = clampf(radius, minimum_radius, maximum_radius)
    circle.radius = radius
    collider_shape.radius = radius - edge_threshold