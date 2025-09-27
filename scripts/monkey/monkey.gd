class_name Monkey
extends RigidBody2D


@export_range(1, 2) var player_number: int = 1
@export var face_toward: Node2D
@export var move_force: float = 100
@export var turn_force: float = 100


func _physics_process(_delta):
    var input_direction = get_numbered_input_direction()
    apply_central_force(input_direction * move_force)

    var a = Vector2.DOWN.rotated(rotation).angle_to(
        face_toward.position - position
    )
    apply_torque(-a * turn_force)




func get_numbered_input_direction() -> Vector2:
  var vertical_input_direction = _get_numbered_input_axis("up", "down")
  var horizontal_input_direction = _get_numbered_input_axis("left", "right")
  return Vector2(horizontal_input_direction, vertical_input_direction).normalized()

func is_numbered_action_just_pressed(simple_name: String) -> bool:
  return Input.is_action_just_pressed(_get_input_name(simple_name))

func is_numbered_action_pressed(simple_name: String) -> bool:
  return Input.is_action_pressed(_get_input_name(simple_name))

func _get_numbered_input_axis(negative_action: String, positive_action: String) -> float:
  var negative_action_name = _get_input_name(negative_action)
  var positive_action_name = _get_input_name(positive_action)
  return Input.get_axis(negative_action_name, positive_action_name)

func _get_input_name(simple_name: String) -> String:
  return ("p%d_" % player_number) + simple_name