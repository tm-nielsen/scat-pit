class_name WaveDisplay
extends Sprite2D

@export_range(0, 1) var player_index: int
@export var maximum_height : float = 0.6
@export_range(0,1) var minimum_thickness: float = 0.0
@export_range(0,1) var maximum_thickness: float = 0.4
@export var minimum_frequency: float = 1
@export var maximum_frequency: float = 4
@export var offset_velocity: float = 4

@onready var effect_material: ShaderMaterial = material
@onready var pitch_target_tracker := PitchTargetTracker.new(player_index)

var dynamic_frequency_enabled: bool

var display_frequency: float = 1
var wave_offset: float = 0
var level: float
var target_level: float


func _ready():
    modulate = Monkey.PLAYER_COLOURS[player_index]
    pitch_target_tracker.target_changed.connect(
        _set_display_frequency_from_target
    )
    pitch_target_tracker.target_cleared.connect(
        _enable_dynamic_frequency
    )
    _enable_dynamic_frequency()

func _process(delta):
    target_level = pitch_target_tracker.target_magnitude
    level = lerp(level, target_level, 0.2)
    _display_level(level)

    wave_offset += (
        offset_velocity * target_level *
        delta * sqrt(1 / display_frequency)
    )
    _set_parameter("offset", wave_offset)
    if dynamic_frequency_enabled: _update_dynamic_display_frequency()


func _display_level(normalized_value: float):
    _set_parameter("height", normalized_value * maximum_height)
    _set_parameter("thickness",
        remap(
            normalized_value, 0, 1,
            minimum_thickness, maximum_thickness
        ) * sqrt(minimum_frequency / display_frequency)
    )

func _enable_dynamic_frequency():
    dynamic_frequency_enabled = true

func _update_dynamic_display_frequency():
    _set_display_frequency(
        remap(
            PitchTargetTracker.to_mono(PitchAnalyser.low_range_ratio),
            0, 1, maximum_frequency, minimum_frequency
        )
    )

func _set_display_frequency_from_target(target_pitch):
    if target_pitch == PitchTargetTracker.LOW:
        get_parent().move_child(self, 0)
    dynamic_frequency_enabled = false
    var frequency := lerpf(minimum_frequency, maximum_frequency, 0.5)
    match target_pitch:
        PitchTargetTracker.LOW: frequency = minimum_frequency
        PitchTargetTracker.HIGH: frequency = maximum_frequency
    _set_display_frequency(frequency)

func _set_display_frequency(value: float):
    display_frequency = value
    _set_parameter("frequency", value)

func _set_parameter(parameter_name: String, value: float):
    effect_material.set_shader_parameter(parameter_name, value)