class_name TweenHelpers
extends Node


static func build_tween(
    bound_node: Node,
    delay: float = 0,
    easing := Tween.EASE_OUT,
    transition := Tween.TRANS_BACK
) -> Tween: 
    var tween := bound_node.create_tween()
    tween.set_ease(easing)
    tween.set_trans(transition)
    tween.tween_interval(delay)
    return tween


static func call_delayed(
    bound_node: Node,
    callback: Callable,
    delay: float
) -> Tween:
    var delay_tween = bound_node.create_tween()
    delay_tween.tween_interval(delay)
    delay_tween.tween_callback(callback)
    return delay_tween

static func call_delayed_realtime(
    bound_node: Node,
    callback: Callable,
    delay: float
) -> Tween:
    var delay_tween = bound_node.call_delayed(callback, delay)
    delay_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    return delay_tween