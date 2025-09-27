extends Area2D

@export var minimum_radius: float = 20
@export var maximum_radius: float = 60
@export var edge_threshold: float = 10

@export var record_bus_name := "Record"
@export var spectrum_analyser_effect_index: int = 1

@onready var circle: Circle = $Circle
@onready var collider_shape: CircleShape2D = $Collider.shape
@onready var radius = circle.radius

var spectrum_analyser: AudioEffectSpectrumAnalyzerInstance
var count: int = 0

func _ready() -> void:
    var record_bus_index = AudioServer.get_bus_index(record_bus_name)
    spectrum_analyser = AudioServer.get_bus_effect_instance(
        record_bus_index, spectrum_analyser_effect_index
    )

func _process(_delta: float) -> void:
    count += 1
    if count == 10:
        count = 0
        for i in range(300, 3300, 900):
            var m = spectrum_analyser.get_magnitude_for_frequency_range(i, i+ 900)
            print(("%d - %d: " % [i, i + 900]) + str(m))
