class_name FrequencyRange

var minimum: float
var maximum: float

func _init(a: float, b: float):
    minimum = min(a, b)
    maximum = max(a, b)


func get_range(
    analyser: AudioEffectSpectrumAnalyzerInstance,
    mode := AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE
) -> Vector2:
    return analyser.get_magnitude_for_frequency_range(
        minimum, maximum, mode
    )


func parse(value) -> void:
    if value is String:
        var parts: Array[String] = value.split(",")
        if parts.size() == 2:
            _init(float(parts[0].strip_edges()), float(parts[1].strip_edges()))
        else:
            printerr("Expected 2 parts of frequency range setting")
    elif value is Array:
        _init(value[0], value[1])
        

func load(
    config_file: ConfigFile, field_prefix: String, default_sensitivity: float,
    default_minimum := minimum, default_maximum := maximum,
    config_category := "MICROPHONE"
) -> float:
    _init(
        config_file.get_value(config_category, field_prefix + "_range_min_hz", default_minimum),
        config_file.get_value(config_category, field_prefix +"_range_max_hz", default_maximum)
    )
    return config_file.get_value(config_category, field_prefix + "_range_sensitivity", default_sensitivity)

func save(
    config_file: ConfigFile, field_prefix: String,
    sensitivity: float, config_category := "MICROPHONE"
) -> void:
    config_file.set_value(config_category, field_prefix + "_range_min_hz", minimum)
    config_file.set_value(config_category, field_prefix + "_range_max_hz", maximum)
    config_file.set_value(config_category, field_prefix + "_range_sensitivity", sensitivity)