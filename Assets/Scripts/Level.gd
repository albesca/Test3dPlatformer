extends Spatial

var counter = 500
var cameras
var destination_marker_scene
var destination_marker


func _ready():
	cameras = [$Player/BackCamera, $Player/LeftCamera, $Player/FrontCamera, \
			$Player/RightCamera]
	destination_marker_scene = load("res://Assets/Scenes/DestinationMarker.tscn")


func _process(_delta):
	if counter > 15:
		counter = 0
		$Gui/DebugData/Label.text = str($Player.transform)
		$Gui/DebugData/Label2.text = str(round($Player.velocity.x * 100.0) / \
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
	$Flag.reset()


func level_done():
	print("level done!")
	yield(get_tree().create_timer(2), "timeout")
	print("now we should get back to the menu or on to the next level")
	$Player.reset_player()


func spawn_destination_marker(destination):
	destination_marker = destination_marker_scene.instance()
	destination_marker.transform.origin = destination
	add_child(destination_marker)
	
	
func despawn_destination_marker():
	if destination_marker:
		destination_marker.queue_free()
