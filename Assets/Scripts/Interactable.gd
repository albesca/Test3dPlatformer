extends Spatial


signal interactable(object, interactable)
signal interact(object)
signal set_destination(destination_position)
signal update_interactable(interactable_name, interactable_value)

export var interactable_name = ""

var interactable


func body_entered_interact_area(_body):
	interactable = true
	emit_signal("interactable", self, interactable)


func body_exited_interact_area(_body):
	interactable = false
	emit_signal("interactable", self, interactable)


func interact_or_reach(_camera, event, _click_position, _click_normal, \
		_shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if interactable:
			interact()
		else:
			emit_signal("set_destination", transform.origin)


func interact():
	emit_signal("interact", self)
