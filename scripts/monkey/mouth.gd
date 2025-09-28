@tool
class_name Mouth
extends Ellipsis

@export var monkey_parent: Monkey
@export var normal_radius: float = 4
@export var normal_offset: float = 2
@export var radius_curve_gain: float = 1
@export var offset_curve_gain: float = 1
@export var low_range_ratio: float = 0.6
@export var high_range_ratio: float = 1.2

@onready var base_position: Vector2 = position

var pitch_target_tracker: PitchTargetTracker
var ignore_target


func initialize_pitch_target(player_index: int):
    pitch_target_tracker = PitchTargetTracker.new(player_index)    

func _process(_delta: float) -> void:
    if Engine.is_editor_hint(): return

    ratio = remap(
        PitchTargetTracker.to_mono(PitchAnalyser.low_range_ratio),
        0, 1, high_range_ratio, low_range_ratio,
    )
    var radius_scale = _curve_value(
        pitch_target_tracker.target_magnitude,
        radius_curve_gain
    )
    radius = radius_scale * normal_radius / ratio

    var offset = _curve_value(
        pitch_target_tracker.target_magnitude,
        offset_curve_gain
    ) * normal_offset
    position = base_position + Vector2.UP * offset


func _curve_value(t: float, gain: float = 1):
    return log(9 * t * t * gain + 1)