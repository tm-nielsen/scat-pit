@tool
extends Ellipsis

enum StereoSide { LEFT, RIGHT }

@export var side: StereoSide
@export var normal_radius: float = 12
@export var low_range_ratio: float = 1.5
@export var high_range_ratio: float = 0.25


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
    ratio = lerp(
        high_range_ratio, low_range_ratio,
        select_stereo_channel(PitchAnalyser.low_range_share)
    )
    radius = total_magnitude * normal_radius / ratio


func select_stereo_channel(value: Vector2) -> float:
    return value.x if side == StereoSide.LEFT else value.y