extends Spatial

var counter = 500
var cameras
var destination_marker_scene
var destination_marker
var level_state
var level_goal
var music
export (Array, Vector3) var pickable_positions = []
var pickables


func _ready():
	build_pickables()
	music = true
	build_level_goal()
	level_state = Global.get_level_state()
	cameras = [$Player/BackCamera, $Player/LeftCamera, $Player/FrontCamera, \
			$Player/RightCamera]
	reset_camera()
	destination_marker_scene = load("res://Assets/Scenes/DestinationMarker.tscn")


func _process(_delta):
	if music and !$MusicBackground.playing:
		$MusicBackground.play()
	elif !music and $MusicBackground.playing:
		$MusicBackground.stop()

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
			camera.make_current()
			next = false
			break
		else:
			if camera.current_camera:
				next = true

			camera.make_not_current()
	
	if next:
		reset_camera()


func reset_camera():
	cameras[0].make_current()


func toggle_music(toggle):
	music = toggle


func reset_level():
	level_state = Global.get_level_state()
	build_pickables()
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


func check_pickable(object, pickable):
	if pickable:
		if $Player.destination == object.transform.origin:
			object.pick()


func picked_object(object):
	level_state[Global.OBJECT_PICKED] += 1
	var index = pickables.find(object)
	if index > -1:
		pickables.remove(index)

	check_level_state()
	

func build_level_goal():
	level_goal = {}
	level_goal[Global.OBJECT_PICKED] = 2


func check_level_state():
	var level_goals_reached = false
	for key in level_goal.keys():
		if key in level_state.keys() and level_state[key] >= level_goal[key]:
			level_goals_reached = true
		else:
			level_goals_reached = false
	
	if level_goals_reached:
		$Flag.enable_goal()


func build_pickables():
	pickables = []
	var pickable_scene = load("res://Assets/Scenes/Pickable.tscn")
	for pickable_position in pickable_positions:
		var pickable = pickable_scene.instance()
		pickable.transform.origin = pickable_position
		pickable.connect("picked", self, "picked_object")
		pickable.connect("pickable", self, "check_pickable")
		pickable.connect("set_destination", self, "set_destination")
		add_child(pickable)
		pickables.append(pickable)
