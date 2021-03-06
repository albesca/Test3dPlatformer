extends StaticBody


signal set_destination(destination_position)
export var see_through = false
var check_obstruction
var base_albedo


func set_destination(_camera, event, click_position, click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if Global.round_vector3(click_normal).angle_to(Vector3.UP) < Global.MAX_SLOPE:
			emit_signal("set_destination", click_position)
		else:
			print("I've been clicked from the sides or the bottom...")
