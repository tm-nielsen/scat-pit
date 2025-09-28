extends Node

@export_range(0, 1) var volume_threshold: float = 0.1
@export var bus_name: StringName = "SFX"
@export var bounce_clip: AudioStream
@export var normal_bounce_momentum: float = 5
@export var punch_clip: AudioStream
@export var punch_volume_exponent: float = 4
@export var punch_landed_clip: AudioStream


func _ready():
    GlobalSignalBus.monkey_bounced.connect(_on_monkey_bounced)
    GlobalSignalBus.jab_thrown.connect(_on_jab_thrown)
    GlobalSignalBus.jab_landed.connect(_on_jab_landed)


func _on_monkey_bounced(collision_momentum: Vector2):
    var t = collision_momentum.length() / normal_bounce_momentum
    _play_clip(bounce_clip, log(9 * t * t + 1))

func _on_jab_thrown(attacker_size: float):
    _play_clip(punch_clip, pow(attacker_size, punch_volume_exponent))

func _on_jab_landed(_d, attacker_size: float):
    _play_clip(punch_landed_clip, pow(attacker_size, punch_volume_exponent))


func _play_clip(clip: AudioStream, linear_volume: float):
    if linear_volume < volume_threshold || !clip: return
    var clip_source := AudioStreamPlayer.new();
    add_child(clip_source)
    clip_source.finished.connect(clip_source.queue_free)
    clip_source.clip = clip
    clip_source.volume_linear = linear_volume
    clip_source.bus = bus_name
    clip_source.play()