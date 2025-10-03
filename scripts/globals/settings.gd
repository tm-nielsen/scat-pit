extends Node

const FILE_NAME := "settings.ini"

var timeout_enabled: bool
var timeout_period: int

var master_sensitivity: float
var low_frequency_range := FrequencyRange.new(100, 300)
var high_frequency_range := FrequencyRange.new(300, 600)
var low_range_sensitivity: float
var high_range_sensitivity: float
var harmonic_compensation_ratio: float

var master_volume: float
var music_volume: float
var sfx_volume: float

var last_input_timestamp: int = 0

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    var config = ConfigFile.new()
    load_settings(config)
    save_settings(config)
    apply_volume_settings()

func _input(_event):
    last_input_timestamp = Time.get_ticks_msec()

func _process(_delta):
    var time_delta = Time.get_ticks_msec() - last_input_timestamp
    var seconds_since_last_input = time_delta / 1000.0
    if Input.is_action_just_pressed('quit') || \
      seconds_since_last_input > timeout_period:
        get_tree().quit()


func load_settings(config: ConfigFile):
    config.load(get_file_path())

    var arcade_mode_enabled = OS.get_cmdline_args().has("--arcade")
    timeout_enabled = config.get_value("SYSTEM", "timeout_enabled", arcade_mode_enabled)
    timeout_period = config.get_value("SYSTEM", "timeout_period_seconds", 180)

    master_sensitivity = config.get_value("MICROPHONE", "sensitivity", 1.0)
    low_range_sensitivity = low_frequency_range.load(config, "low", 10)
    high_range_sensitivity = high_frequency_range.load(config, "high", 20)
    harmonic_compensation_ratio = config.get_value("MICROPHONE", "harmonic_compensation_ratio", 0.5)

    master_volume = config.get_value("VOLUME", "master_volume", 1.0)
    music_volume = config.get_value("VOLUME", "music_volume", 1.0)
    sfx_volume = config.get_value("VOLUME", "sfx_volume", 1.0)


func save_settings(config: ConfigFile):
    config.set_value("SYSTEM", "timeout_enabled", timeout_enabled)
    config.set_value("SYSTEM", "timeout_period_seconds", timeout_period)

    config.set_value("MICROPHONE", "sensitivity", master_sensitivity)
    low_frequency_range.save(config, "low", low_range_sensitivity)
    high_frequency_range.save(config, "high", high_range_sensitivity)
    config.set_value("MICROPHONE", "harmonic_compensation_ratio", harmonic_compensation_ratio)

    config.set_value("VOLUME", "master_volume", master_volume)
    config.set_value("VOLUME", "music_volume", music_volume)
    config.set_value("VOLUME", "sfx_volume", sfx_volume)

    config.save(get_file_path())


func apply_volume_settings():
    var master_bus_index = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume))
    var music_bus_index = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume))
    var sfx_bus_index = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))


func get_file_path() -> String:
    if OS.has_feature("editor"):
        return "res://".path_join(FILE_NAME)
    return OS.get_executable_path().get_base_dir().path_join(FILE_NAME)