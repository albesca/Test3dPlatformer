extends Spatial


signal set_destination(destination)


func set_destination(_camera, event, click_position, click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if Global.round_vector3(click_normal).angle_to(Vector3.UP) < Global.MAX_SLOPE:
			emit_signal("set_destination", click_position)
		else:
			print("I've been clicked from the sides or the bottom...")


func init():
	var rotation_angle = Global.rn_generator.randf_range(0, 2 * PI)
	var cap_shape = Global.rn_generator.randi_range(0, 1)
	var cap
	if cap_shape == 0:
		cap = load("res://Assets/Scenes/Mushroom/CapFlat.tscn").instance()
	else:
		cap = load("res://Assets/Scenes/Mushroom/CapDroop.tscn").instance()
		
	cap.connect("input_event", self, "set_destination")
	cap.transform = cap.transform.rotated(Vector3.UP, rotation_angle)
	add_child(cap)
	var stem_shape = Global.rn_generator.randi_range(0, 1)
	var stem
	if stem_shape == 0:
		stem = load("res://Assets/Scenes/Mushroom/StemLean.tscn").instance()
	else:
		stem = load("res://Assets/Scenes/Mushroom/StemFat.tscn").instance()

	stem.transform = stem.transform.rotated(Vector3.UP, rotation_angle)
	add_child(stem)
	$Placeholder.visible = false
