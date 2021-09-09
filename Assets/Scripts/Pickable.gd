extends KinematicBody


signal pickable(object, pickable)
signal picked(object)
signal set_destination(destination_position)
var pickable


func body_entered_pick_area(_body):
	pickable = true
	emit_signal("pickable", self, pickable)


func body_exited_pick_area(_body):
	pickable = false
	emit_signal("pickable", self, pickable)


func pick_or_reach(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if pickable:
			pick()
		else:
			emit_signal("set_destination", transform.origin)


func pick():
	emit_signal("picked", self)
	queue_free()
