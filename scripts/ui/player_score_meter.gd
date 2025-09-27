extends Control

enum TargetPitch { NONE, LOW, HIGH }
const NONE := TargetPitch.NONE
const LOW := TargetPitch.LOW
const HIGH := TargetPitch.HIGH

@export_range(0, 1) var player_index: int = 0
@export var minimum_stretch_ratio: float = 0.5
@export var maximum_stretch_ratio: float = 2

@export var fill: ColorRect
@export var fill_threshold: float = 500

var target_pitch: TargetPitch
var target_stretch_ratio: float

var full_height: float = 0
var fill_amount: float = 0


func _ready():
    GlobalSignalBus.monkey_sizes_changed.connect(
        _update_target_pitch
    )
    _initialize_fill.call_deferred()

func _process(_delta):
    var target_range_weight = _get_target_range_weight()
    _add_fill(target_range_weight)
    _update_target_stretch_ratio(target_range_weight)
    size_flags_stretch_ratio = lerpf(
        size_flags_stretch_ratio,
        target_stretch_ratio, 0.1
    )


func _initialize_fill():
    full_height = fill.size.y
    fill.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func _add_fill(amount: float):
    fill_amount = clampf(
        fill_amount + amount,
        0, fill_threshold
    )
    var fill_ratio = fill_amount / fill_threshold
    fill.custom_minimum_size.y = full_height * fill_ratio


func _update_target_stretch_ratio(weight: float):
    target_stretch_ratio = remap(
        clampf(weight, -1, 1)
        , -1, 1
        , minimum_stretch_ratio
        , maximum_stretch_ratio
    )

func _get_target_range_weight() -> float:
    if target_pitch == NONE: return 0
    return (
        PitchAnalyser.range_weight *
        (1 if target_pitch == HIGH else -1)
    )


func _update_target_pitch(new_sizes: Array[float]):
    if new_sizes[0] == new_sizes[1]: target_pitch = NONE
    else: target_pitch = (
        LOW
        if new_sizes[player_index] == new_sizes.max()
        else HIGH
    )
