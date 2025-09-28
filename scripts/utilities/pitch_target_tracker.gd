class_name PitchTargetTracker

signal target_cleared
signal target_changed(new_target: TargetPitch)

enum TargetPitch { NONE = -1, LOW = 0, HIGH = 1 }
const NONE := TargetPitch.NONE
const LOW := TargetPitch.LOW
const HIGH := TargetPitch.HIGH

var target_ratio: float: get = _get_target_ratio
var target_weight: float: get = _get_target_range_weight
var target_magnitude: float: get = _get_target_range_scalar_magnitude

var player_index: int = 0
var target_pitch: TargetPitch


func _init(index: int) -> void:
    player_index = index
    GlobalSignalBus.monkey_sizes_changed.connect(
        _update_target_pitch
    )
    _update_target_pitch([1,1])


func _update_target_pitch(new_sizes: Array[float]):
    if new_sizes[0] == new_sizes[1]: target_pitch = NONE
    else: target_pitch = (
        LOW
        if new_sizes[player_index] == new_sizes.max()
        else HIGH
    )
    target_changed.emit(int(target_pitch))
    if target_pitch == NONE: target_cleared.emit()


func _get_target_ratio() -> float:
    match target_pitch:
        LOW: return to_mono(PitchAnalyser.low_range_ratio)
        HIGH: return to_mono(PitchAnalyser.high_range_ratio)
    return 0.5

func _get_target_range_scalar_magnitude() -> float:
    var stereo_magnitude
    match target_pitch:
        NONE: stereo_magnitude = PitchAnalyser.total_magnitude / 2
        LOW: stereo_magnitude = PitchAnalyser.low_range_magnitude
        HIGH: stereo_magnitude = PitchAnalyser.high_range_magnitude
    return to_mono(stereo_magnitude)

func _get_target_range_weight() -> float:
    if target_pitch == NONE: return 0
    return (
        PitchAnalyser.range_weight *
        (1 if target_pitch == HIGH else -1)
    )


static func to_mono(stereo_value: Vector2) -> float:
    return (stereo_value.x + stereo_value.y) / 2