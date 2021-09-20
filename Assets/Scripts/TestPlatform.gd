extends "res://Assets/Scripts/Platform.gd"


func _ready():
	base_albedo = $CSGBox.material.albedo_color


func _physics_process(_delta):
	if check_obstruction:
		if see_through:
			$CSGBox.material.flags_transparent = true
			$CSGBox.material.albedo_color.a = base_albedo.a / 2.0
			input_ray_pickable = false
		else:
			$CSGBox.material.flags_transparent = false
			$CSGBox.material.albedo_color.a = base_albedo.a
			input_ray_pickable = true
