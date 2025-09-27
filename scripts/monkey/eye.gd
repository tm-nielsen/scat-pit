class_name Eye
extends Area2D


@export var jab_distance: float = 30
@export var jab_period: float = 0.2
@export var jab_recovery_period: float = 0.5
@export var elastic_position: ElasticVector2
@export var parent_velocity_effect: float = 0.05

@onready var parent: RigidBody2D = get_parent()
@onready var base_position: Vector2 = position

var recovery_scale: float = 1
var is_recovering: bool: get = _get_is_recovering

var jab_offset: float
var jab_tween: Tween


func _physics_process(delta):
    elastic_position.update_value(
        - parent.linear_velocity
        * parent_velocity_effect,
        delta
    )
    global_position = (
        parent.global_position +
        (
            base_position
            + Vector2.UP * jab_offset
        ).rotated(parent.rotation)
        + elastic_position.value
    )


func trigger_jab():
    jab_tween = TweenHelpers.build_tween(self)
    jab_tween.tween_property(
        self, "jab_offset", jab_distance, jab_period
    )
    jab_tween.tween_callback(
        func(): monitoring = false
    )
    jab_tween.tween_property(
        self, "jab_offset", 0,
        jab_recovery_period * recovery_scale
    )

func _get_is_recovering() -> bool:
    if !jab_tween: return false
    return jab_tween.is_running()
