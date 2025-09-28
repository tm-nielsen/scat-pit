extends Node

@export_range(0, 1) var volume_threshold: float = 0.1
@export var bus_name: StringName = "SFX"

@export_subgroup("bounces", "bounce")
@export var bounce_boing_clips: Array[AudioStream]
@export var bounce_noise_clips: Array[AudioStream]
@export var bounce_normal_momentum: float = 50

@export_subgroup("punches", "punch")
@export var punch_thrown_clips: Array[AudioStream]
@export var punch_volume_exponent: float = 4
@export var punch_landed_ouch_clips: Array[AudioStream]
@export var punch_landed_smash_clips: Array[AudioStream]


func _ready():
    GlobalSignalBus.monkey_bounced.connect(_on_monkey_bounced)
    GlobalSignalBus.jab_thrown.connect(_on_jab_thrown)
    GlobalSignalBus.jab_landed.connect(_on_jab_landed)


func _on_monkey_bounced(collision_momentum: Vector2):
    var t = collision_momentum.length() / bounce_normal_momentum
    var volume = log(9 * t * t + 1)
    _play_clip(bounce_boing_clips, volume)
    _play_clip(bounce_noise_clips, volume)

func _on_jab_thrown(attacker_size: float):
    _play_clip(punch_thrown_clips, attacker_size)

func _on_jab_landed(_d, attacker_size: float):
    _play_clip(punch_landed_ouch_clips, attacker_size * 2)
    _play_clip(punch_landed_smash_clips, attacker_size * 2)


func _play_clip(clips: Array[AudioStream], linear_volume: float):
    if linear_volume < volume_threshold || !clips: return
    var clip_source := AudioStreamPlayer.new();
    add_child(clip_source)
    clip_source.finished.connect(clip_source.queue_free)
    clip_source.stream = clips.pick_random()
    clip_source.volume_linear = linear_volume
    clip_source.bus = bus_name
    clip_source.play()