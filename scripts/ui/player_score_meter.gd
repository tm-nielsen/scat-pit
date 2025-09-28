class_name PlayerScoreMeter
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

@export_subgroup("prompt labels")
@export var low_pitch_prompt_texture: Texture2D
@export var high_pitch_prompt_texture: Texture2D
@export var prompt_display_nodes: Array[TextureRect]

var target_pitch: TargetPitch
var target_stretch_ratio: float

var full_height: float = 0
var fill_amount: float = 0

var is_full: bool: get = _get_is_full
var is_empty: bool: get = _get_is_empty


func _ready():
    GlobalSignalBus.monkey_sizes_changed.connect(
        _update_target_pitch
    )
    modulate = Monkey.PLAYER_COLOURS[player_index]
    _initialize_fill.call_deferred()
    _update_target_pitch([1,1])

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
    _update_prompt_texture()

func _update_prompt_texture():
    var prompt_texture: Texture2D
    match target_pitch:
        NONE: prompt_texture = null
        LOW: prompt_texture = low_pitch_prompt_texture
        HIGH: prompt_texture = high_pitch_prompt_texture
    for texture_rect in prompt_display_nodes:
        texture_rect.texture = prompt_texture


func _get_is_full() -> bool:
    return fill_amount == fill_threshold

func _get_is_empty() -> bool:
    return fill_amount == 0