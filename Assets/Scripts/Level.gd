extends Spatial

var counter = 500
var cameras


func _ready():
	cameras = [$Player/BackCamera, $Player/LeftCamera, $Player/FrontCamera, \
			$Player/RightCamera]


func _process(_delta):
	if counter > 15:
		counter = 0
		$DebugData/Label.text = str($Player.transform)
		$DebugData/Label2.text = str(round($Player.velocity.x * 100.0) / \
				100.0) + " - " + str(round($Player.velocity.y * 100.0) / \
				100.0) + " - " + str(round($Player.velocity.x * 100.0) / 100.0) 
	else:
		counter += 1


func set_destination(destination_position):
	print("destination: ", destination_position)
	$Player.set_destination(destination_position)


func switch_camera():
	var next = false
	for camera in cameras:
		if next:
			camera.current = true
			next = false
			break
		if camera.current:
			next = true
	
	if next:
		reset_camera()


func reset_camera():
	cameras[0].current = true


func reset_level():
	reset_camera()
