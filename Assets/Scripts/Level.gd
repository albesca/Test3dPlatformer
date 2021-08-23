extends Spatial

var counter = 500

func set_destination(destination_position):
	print("destination: ", destination_position)
	$Player.set_destination(destination_position)


func _process(_delta):
	if counter > 15:
		counter = 0
		$Label.text = str($Player.transform)
		$Label2.text = str(round($Player.velocity.x * 100.0) / 100.0) + " - " + \
				str(round($Player.velocity.y * 100.0) / 100.0) + " - " + \
				str(round($Player.velocity.x * 100.0) / 100.0) 
	else:
		counter += 1


func switch_camera():
	if $Player/Camera.current:
		$Camera.current = true
	else:
		$Player/Camera.current = true
