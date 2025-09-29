class_name PlayerScoreMeter
extends Control

@export_range(0, 1) var player_index: int = 0
@export var minimum_stretch_ratio: float = 0.5
@export var maximum_stretch_ratio: float = 2

@export var fill: ColorRect
@export var fill_threshold: float = 500
@export var fill_acceleration_slowdown: float = 20

@export_subgroup("prompt labels")
@export var low_pitch_prompt_texture: Texture2D
@export var high_pitch_prompt_texture: Texture2D
@export var prompt_display_nodes: Array[TextureRect]

var pitch_target_tracker: PitchTargetTracker

var target_stretch_ratio: float
var full_height: float = 0
var fill_amount: float = 0

var is_full: bool: get = _get_is_full
var is_empty: bool: get = _get_is_empty

var game_timer: float = 0


func _ready():
    pitch_target_tracker = PitchTargetTracker.new(player_index)
    pitch_target_tracker.target_changed.connect(_update_prompt_texture)
    modulate = Monkey.PLAYER_COLOURS[player_index]
    _initialize_fill.call_deferred()
    _update_prompt_texture(PitchTargetTracker.NONE)

func _process(delta):
    game_timer += delta
    var target_range_weight = pitch_target_tracker.target_weight
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
    var t := game_timer / fill_acceleration_slowdown
    fill_amount = clampf(
        fill_amount + amount * (1 + t * t),
        0, fill_threshold
    )
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

func _update_prompt_texture(target_pitch: PitchTargetTracker.TargetPitch):
    var prompt_texture: Texture2D
    match target_pitch:
        PitchTargetTracker.NONE: prompt_texture = null
        PitchTargetTracker.LOW: prompt_texture = low_pitch_prompt_texture
        PitchTargetTracker.HIGH: prompt_texture = high_pitch_prompt_texture
    for texture_rect in prompt_display_nodes:
        texture_rect.texture = prompt_texture


func _get_is_full() -> bool:
    return fill_amount == fill_threshold

func _get_is_empty() -> bool:
    return fill_amount == 0