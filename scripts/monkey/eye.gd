class_name Eye
extends Area2D


@export var push_force: float = 50
@export var jab_distance: float = 30
@export var jab_period: float = 0.2
@export var jab_recovery_period: float = 0.5
@export var elastic_position: ElasticVector2
@export var parent_velocity_effect: float = 0.05

@export_subgroup("scaling references")
@export var collider: CollisionShape2D
@export var circle: Circle

@onready var parent: Monkey = get_parent()
@onready var base_position: Vector2 = position

var recovery_scale: float = 1
var is_recovering: bool: get = _get_is_recovering

var jab_offset: float
var jab_tween: Tween


func _ready():
    body_entered.connect(_on_body_entered)
    monitoring = false

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
    monitoring = true
    jab_tween.tween_property(
        self, "jab_offset", jab_distance, jab_period
    )
    jab_tween.tween_callback(_disable_monitoring)
    jab_tween.tween_property(
        self, "jab_offset", 0,
        jab_recovery_period * recovery_scale
    )


func _on_body_entered(body: PhysicsBody2D):
    if body == parent: return
    if body is Monkey:
        parent.add_size(body.steal_size())
        body.apply_impulse(
            global_position,
            Vector2.UP.rotated(global_rotation)
            * push_force
        )
        GlobalSignalBus.notify_jab_landed(parent, body)
        _disable_monitoring()

func _disable_monitoring():
    set_deferred("monitoring", false)


func _get_is_recovering() -> bool:
    if !jab_tween: return false
    return jab_tween.is_running()
