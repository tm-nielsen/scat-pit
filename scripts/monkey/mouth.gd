@tool
class_name Mouth
extends Ellipsis

enum StereoSide { LEFT, RIGHT }

@export var side: StereoSide
@export var normal_radius: float = 4
@export var normal_offset: float = 2
@export var radius_curve_gain: float = 1
@export var offset_curve_gain: float = 1
@export var low_range_ratio: float = 0.6
@export var high_range_ratio: float = 1.2

@onready var base_position: Vector2 = position


func _process(_delta: float) -> void:
    if Engine.is_editor_hint(): return

    var low_range_magnitude := select_stereo_channel(
        PitchAnalyser.low_range_magnitude
    )
    var high_range_magnitude = select_stereo_channel(
        PitchAnalyser.high_range_magnitude
    )
    var total_magnitude = (
        low_range_magnitude + high_range_magnitude
    )

    ratio = remap(
        select_stereo_channel(PitchAnalyser.low_range_ratio),
        0, 1, high_range_ratio, low_range_ratio,
    )
    var radius_scale = _curve_value(
        total_magnitude / 2, radius_curve_gain
    )
    radius = radius_scale * normal_radius / ratio

    var offset = _curve_value(
        total_magnitude / 2, offset_curve_gain
    ) * normal_offset
    position = base_position + Vector2.UP * offset


func set_side_from_player_number(player_number: int):
    side = (
        StereoSide.LEFT
        if player_number < 2 else
        StereoSide.RIGHT
    )


func _curve_value(t: float, gain: float = 1):
    return log(9 * t * t * gain + 1)


func select_stereo_channel(value: Vector2) -> float:
    return value.x if side == StereoSide.LEFT else value.y