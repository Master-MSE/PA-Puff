extends Resource
class_name TweenSettings

@export var property : String = ""
@export var duration : float = 1
@export var ease : Tween.EaseType = Tween.EASE_OUT
@export var transition : Tween.TransitionType = Tween.TRANS_LINEAR

func apply_settings(tween : Tween):
	tween.set_ease(ease)
	tween.set_trans(transition)

func tween_property(tween : Tween, object : Object, goal : Variant, new_duration : float = 0):
	apply_settings(tween)
	tween.tween_property(object, property, goal, new_duration if new_duration != 0 else duration)
