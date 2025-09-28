extends Node

signal monkey_sizes_changed(new_sizes: Array[float])
signal jab_thrown(attacker_size: float)
signal jab_landed(direction: Vector2, attacker_size: float)
signal monkey_bounced(collision_momentum: Vector2)


func notify_jab_thrown(attacker: Monkey):
    jab_thrown.emit(attacker.size)

func notify_jab_landed(attacker: Monkey, target: Monkey):
    jab_landed.emit(Vector2.UP.rotated(attacker.rotation), attacker.size)
    var new_sizes: Array[float] = [1, 1]
    new_sizes[attacker.player_number - 1] = attacker.size
    new_sizes[target.player_number - 1] = target.size
    monkey_sizes_changed.emit(new_sizes)

func notify_monkey_bounced(m: Monkey):
    monkey_bounced.emit(-m.linear_velocity * m.mass)