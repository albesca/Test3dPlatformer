extends StaticBody


signal set_destination(destination_position)
export var see_through = false
var check_obstruction
var base_albedo


func _ready():
	base_albedo = $CSGBox.material.albedo_color


func set_destination(_camera, event, click_position, click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if Global.round_vector3(click_normal).angle_to(Vector3.UP) < Global.MAX_SLOPE:
			emit_signal("set_destination", click_position)
		else:
			print("I've been clicked from the sides or the bottom...")


func _physics_process(_delta):
	if check_obstruction:
		#$CSGBox.material.albedo_color.b = 1.0
		if see_through:
			$CSGBox.material.flags_transparent = true
			$CSGBox.material.albedo_color.a = base_albedo.a / 2.0
			input_ray_pickable = false
			#see_through = false
		else:
			$CSGBox.material.flags_transparent = false
			$CSGBox.material.albedo_color.a = base_albedo.a
			input_ray_pickable = true
	#else:
	#	$CSGBox.material.albedo_color.b = base_albedo.b
