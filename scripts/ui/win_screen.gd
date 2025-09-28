extends Control

@export var score_meters: Array[PlayerScoreMeter]
@export var gameplay_root: Node
@export var monkey_colour_node: Node2D
@export var replay_delay: float = 3

var replay_enabled: bool = false


func _ready():
    visible = false

func _process(_delta):
    if !visible:
        for i in 2: if (
            score_meters[i].is_full &&
            score_meters[(i + 1) % 2].is_empty
        ): trigger(i)
    elif replay_enabled && Input.is_anything_pressed():
        get_tree().reload_current_scene()


func trigger(player_index: int):
    monkey_colour_node.modulate = Monkey.PLAYER_COLOURS[player_index]
    show()
    gameplay_root.queue_free()
    TweenHelpers.call_delayed(
        self, enable_replay, replay_delay
    )

func enable_replay():
    replay_enabled = true