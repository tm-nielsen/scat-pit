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

var total_magnitude: Vector2
var average_magnitude: float

var low_range_ratio: Vector2
var high_range_ratio: Vector2
var range_weight: float


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

    total_magnitude = low_range_magnitude + high_range_magnitude
    average_magnitude = (total_magnitude.x + total_magnitude.y) / 2

    low_range_ratio = get_ratio(low_range_magnitude, total_magnitude)
    high_range_ratio = get_ratio(high_range_magnitude, total_magnitude)

    var ratio_offset = high_range_ratio - low_range_ratio
    range_weight = (
        (ratio_offset.x + ratio_offset.y)
        * average_magnitude
    )


func get_ratio(band: Vector2, total: Vector2) -> Vector2:
    return Vector2(
        safe_remap(band.x, total.x),
        safe_remap(band.y, total.y)
    )

func safe_remap(a: float, b: float) -> float:
    return 0.5 if b == 0 else remap(a, 0, b, 0, 1)


func get_range(
    analyser: AudioEffectSpectrumAnalyzerInstance,
    range_min: float, range_max: float
) -> Vector2:
    return analyser.get_magnitude_for_frequency_range(
        range_min, range_max,
        AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE
    )
