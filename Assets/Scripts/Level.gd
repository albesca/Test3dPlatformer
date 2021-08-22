extends Spatial


func set_destination(destination_position):
	print("destination: ", destination_position)
	$Player.set_destination(destination_position)


func _process(_delta):
	$Label.text = str($Player.global_transform)
	$Label2.text = str($Player.transform)


func switch_camera():
	if $Player/Camera.current:
		$Camera.current = true
	else:
		$Player/Camera.current = true
