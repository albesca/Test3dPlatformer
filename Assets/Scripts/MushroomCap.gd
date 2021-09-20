extends "res://Assets/Scripts/Platform.gd"


func _ready():
	base_albedo = $Mesh.mesh.surface_get_material(1).albedo_color


func _physics_process(_delta):
	if check_obstruction:
		if see_through:
			$Mesh.mesh.surface_get_material(0).flags_transparent = true
			$Mesh.mesh.surface_get_material(0).albedo_color.a = \
					base_albedo.a / 2.0
			$Mesh.mesh.surface_get_material(1).flags_transparent = true
			$Mesh.mesh.surface_get_material(1).albedo_color.a = \
					base_albedo.a / 2.0
			input_ray_pickable = false
		else:
			$Mesh.mesh.surface_get_material(0).flags_transparent = false
			$Mesh.mesh.surface_get_material(0).albedo_color.a = base_albedo.a
			$Mesh.mesh.surface_get_material(1).flags_transparent = false
			$Mesh.mesh.surface_get_material(1).albedo_color.a = base_albedo.a
			input_ray_pickable = true
