extends Node

@export var input_bus_name := "Input"
@export var spectrum_analyser_effect_index: int = 2

@export_subgroup("parameters")
@export_subgroup("parameters/low range", "low_range")
@export var low_range_normalizing_factor: float = 20
@export var low_range_minimum_frequency: float = 100
@export var low_range_maximum_frequency: float = 300
@export_subgroup("parameters/high range", "high_range")
@export var high_range_normalizing_factor: float = 40
@export var high_range_minimum_frequency: float = 300
@export var high_range_maximum_frequency: float = 600

var spectrum_analyser: AudioEffectSpectrumAnalyzerInstance

var low_range_magnitude: Vector2
var high_range_magnitude: Vector2
var average_magnitude: float
var low_range_share: Vector2


func _ready() -> void:
    spectrum_analyser = AudioServer.get_bus_effect_instance(
        AudioServer.get_bus_index(input_bus_name),
        spectrum_analyser_effect_index
    )

func _process(_delta: float) -> void:
    low_range_magnitude = get_range(
        spectrum_analyser,
        low_range_minimum_frequency,
        low_range_maximum_frequency
    )
    high_range_magnitude = get_range(
        spectrum_analyser,
        high_range_minimum_frequency,
        high_range_maximum_frequency
    )

    # account for low range resonance
    high_range_magnitude -= low_range_magnitude
    high_range_magnitude = high_range_magnitude.clamp(Vector2.ZERO, Vector2.INF)

    low_range_magnitude *= low_range_normalizing_factor
    high_range_magnitude *= high_range_normalizing_factor

    var total_magnitude := low_range_magnitude + high_range_magnitude
    if total_magnitude.x != 0 && total_magnitude.y != 0:
        low_range_share = low_range_magnitude / total_magnitude
    else:
        low_range_share = Vector2(0.5, 0.5)
    average_magnitude = (total_magnitude.x + total_magnitude.y) / 2


func get_range(
    analyser: AudioEffectSpectrumAnalyzerInstance,
    range_min: float, range_max: float
) -> Vector2:
    return analyser.get_magnitude_for_frequency_range(
        range_min, range_max,
        AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE
    )
