extends Control

enum TargetPitch { NONE, LOW, HIGH }
const NONE := TargetPitch.NONE
const LOW := TargetPitch.LOW
const HIGH := TargetPitch.HIGH

@export_range(0, 1) var player_index: int = 0
@export var minimum_stretch_ratio: float = 0.5
@export var maximum_stretch_ratio: float = 2

var target_pitch: TargetPitch
var target_stretch_ratio: float


func _ready():
    GlobalSignalBus.monkey_sizes_changed.connect(
        _update_target_pitch
    )


func _process(_delta):
    _update_target_stretch_ratio()
    size_flags_stretch_ratio = lerpf(
        size_flags_stretch_ratio,
        target_stretch_ratio, 0.1
    )


func _update_target_stretch_ratio():
    target_stretch_ratio = (
        1.0 if target_pitch == NONE
        else remap(
            _get_target_range_weight()
            , -1, 1
            , minimum_stretch_ratio
            , maximum_stretch_ratio
        )
    )

func _get_target_range_weight() -> float:
    return clampf(
        PitchAnalyser.range_weight *
        (1 if target_pitch == HIGH else -1)
        , -1, 1
    )


func _update_target_pitch(new_sizes: Array[float]):
    if new_sizes[0] == new_sizes[1]: target_pitch = NONE
    else: target_pitch = (
        LOW
        if new_sizes[player_index] == new_sizes.max()
        else HIGH
    )