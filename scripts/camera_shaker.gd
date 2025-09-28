extends Camera2D

@export var elastic_position: ElasticVector2
@export var jab_effect: float = 2
@export var bounce_effect: float = 0.01
@export var bounce_effect_limit: float = 00.5

@export_subgroup("pitch zoom")
@export var pitch_zoom_minimum: float = 0.8
@export var pitch_zoom_maximum: float = 1.2
@export var walls_node: Node2D

var wall_scalers: Array[Node2DScaler]


func _ready():
    GlobalSignalBus.jab_landed.connect(
        func(direction: Vector2, attacker_size: float):
            elastic_position.value_velocity += \
            direction * attacker_size * jab_effect
    )
    GlobalSignalBus.monkey_bounced.connect(
        func(collision_velocity: Vector2):
            elastic_position.value_velocity += (
                collision_velocity * bounce_effect
            ).clampf(-bounce_effect_limit, bounce_effect_limit)
    )
    for child in walls_node.get_children():
        wall_scalers.push_back(Node2DScaler.new(child))

func _process(delta):
    elastic_position.update_value(Vector2.ZERO, delta)
    position = elastic_position.value

    var target_zoom = remap(
        clampf(PitchAnalyser.range_weight, -1, 1),
        -1, 1, pitch_zoom_minimum, pitch_zoom_maximum
    )
    var interpolated_zoom = lerpf(zoom.x, target_zoom, 0.1)
    zoom = Vector2.ONE * interpolated_zoom
    for scaler in wall_scalers:
        scaler.scale(1 / interpolated_zoom)
