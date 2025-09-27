extends Node

@export var record_bus_name := "Record"
@export var spectrum_analyser_effect_index: int = 1

@export_subgroup("parameters")
@export_subgroup("parameters/low range", "low_range")
@export var low_range_minimum_frequency: float = 100
@export var low_range_maximum_frequency: float = 300
@export_subgroup("parameters/high range", "high_range")
@export var high_range_minimum_frequency: float = 300
@export var high_range_maximum_frequency: float = 600

var spectrum_analyser: AudioEffectSpectrumAnalyzerInstance

var low_range_magnitude: Vector2
var high_range_magnitude: Vector2


func _ready() -> void:
    var record_bus_index = AudioServer.get_bus_index(record_bus_name)
    spectrum_analyser = AudioServer.get_bus_effect_instance(
        record_bus_index, spectrum_analyser_effect_index
    )

func _process(_delta: float) -> void:
    low_range_magnitude = get_range(
        low_range_minimum_frequency,
        low_range_maximum_frequency
    )
    high_range_magnitude = get_range(
        high_range_minimum_frequency,
        high_range_maximum_frequency
    )


func get_range(range_min: float, range_max: float) -> Vector2:
    return spectrum_analyser \
    .get_magnitude_for_frequency_range(range_min, range_max)