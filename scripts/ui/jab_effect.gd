extends SubViewportContainer

@export var duration: float = 2 / 12.0
@onready var effect_material: ShaderMaterial = material

var effect_tween: Tween


# func _ready():
#     GlobalSignalBus.jab_landed.connect(_trigger_effect)

func _trigger_effect(source: Monkey):
    effect_material.set_shader_parameter(
        "colour_a", source.modulate
    )
    set_effect_enabled(true)
    if effect_tween: effect_tween.kill()
    effect_tween = TweenHelpers.call_delayed(
        self,
        set_effect_enabled.bind(false),
        duration
    )

func set_effect_enabled(value: bool):
    effect_material.set_shader_parameter(
        "amount", 1.0 if value else 0.0
    )