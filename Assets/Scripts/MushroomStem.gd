extends "res://Assets/Scripts/Platform.gd"


func _ready():
	base_albedo = $Mesh.mesh.surface_get_material(0).albedo_color


func _physics_process(_delta):
	if check_obstruction:
		if see_through:
			$Mesh.mesh.surface_get_material(0).flags_transparent = true
			$Mesh.mesh.surface_get_material(0).albedo_color.a = \
					base_albedo.a / 2.0
		else:
			$Mesh.mesh.surface_get_material(0).flags_transparent = false
			$Mesh.mesh.surface_get_material(0).albedo_color.a = base_albedo.a
