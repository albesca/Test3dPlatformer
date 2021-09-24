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
var switches_base_state = {}


func _ready():
	Global.init_rng(150)
	build_pickables()
	build_level_goal()
	get_switches_base_state()
	build_level_state()
	init_mushrooms()
	music = true
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
#		$Gui/DebugData/Label.text = str($Player.transform)
#		$Gui/DebugData/Label2.text = str(round($Player.velocity.x * 100.0) / \
#				100.0) + " - " + str(round($Player.velocity.y * 100.0) / \
#				100.0) + " - " + str(round($Player.velocity.x * 100.0) / 100.0) 
		$Gui/DebugData/Label.text = str($Player.velocity)
		$Gui/DebugData/Label2.text = str($Player.last_angle_to_destination) 
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
	reset_switches()
	build_level_state()
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


func check_interactable(object, interactable):
	if interactable:
		if $Player.destination == object.transform.origin:
			object.interact()


func picked_object(object):
	var object_name = object.interactable_name
	var objects_list = level_state[Global.OBJECT_PICKED][Global.OBJECTS_LIST]
	if !object_name in objects_list.keys():
		objects_list[object_name] = 1
	else:
		objects_list[object_name] += 1

	var index = pickables.find(object)
	if index > -1:
		pickables.remove(index)

	check_level_state()
	

func build_level_goal():
	level_goal = Global.get_level_state()
	level_goal[Global.OBJECT_PICKED][Global.OBJECTS_LIST] = {
		"test pickable": 2
	}
	level_goal[Global.SWITCHES_STATE][Global.SWITCHES_LIST] = {
		$Switch.interactable_name: false,
		$Switch2.interactable_name: false
	}


func build_level_state():
	level_state = Global.get_level_state()
	level_state[Global.SWITCHES_STATE][Global.SWITCHES_LIST] = {}
	var switches = get_tree().get_nodes_in_group("switches")
	for switch in switches:
		level_state[Global.SWITCHES_STATE][Global.SWITCHES_LIST][\
				switch.interactable_name] = switch.switch_position


func check_level_state():
	var level_goals_reached = false
	for key in level_goal.keys():
		var found_unreached_goal = false
		if key in level_state.keys():
			var current_goal = level_goal[key]
			var current_state = level_state[key]
			if current_goal[Global.OBJECTIVE_TYPE] == Global.SWITCHES_STATE:
				var switch_goals = current_goal[Global.SWITCHES_LIST]
				var switch_states = current_state[Global.SWITCHES_LIST]
				for switch_name in switch_goals.keys():
					if switch_name in switch_states.keys() and \
							switch_goals[switch_name] == \
							switch_states[switch_name]:
						level_goals_reached = true
					else:
						level_goals_reached = false
						found_unreached_goal = true
						break
						
				if found_unreached_goal:
					break
			elif current_goal[Global.OBJECTIVE_TYPE] == \
					Global.OBJECT_MIN_QUANTITY:
				var object_goals = current_goal[Global.OBJECTS_LIST]
				var object_states = current_state[Global.OBJECTS_LIST]
				for object_name in object_goals.keys():
					if object_name in object_states.keys() and \
							object_goals[object_name] <= \
							object_states[object_name]:
						level_goals_reached = true
					else:
						level_goals_reached = false
						found_unreached_goal = true
						break
						
				if found_unreached_goal:
					break
		else:
			level_goals_reached = false
	
	if level_goals_reached:
		$Flag.enable_goal()
	else:
		$Flag.disable_goal()


func build_pickables():
	pickables = []
	var pickable_scene = load("res://Assets/Scenes/Pickable.tscn")
	for pickable_position in pickable_positions:
		var pickable = pickable_scene.instance()
		pickable.transform.origin = pickable_position
		pickable.connect("interact", self, "picked_object")
		pickable.connect("interactable", self, "check_interactable")
		pickable.connect("set_destination", self, "set_destination")
		pickable.interactable_name = "test pickable"
		add_child(pickable)
		pickables.append(pickable)


func update_switch(switch_name, position):
	var switches_list = level_state[Global.SWITCHES_STATE][Global.SWITCHES_LIST]
	switches_list[switch_name] = position
	check_level_state()


func init_mushrooms():
	var mushrooms = get_tree().get_nodes_in_group("mushrooms")
	for mushroom in mushrooms:
		mushroom.init()


func reset_switches():
	var switches = get_tree().get_nodes_in_group("switches")
	for switch in switches:
		switch.switch_position = switches_base_state[switch.interactable_name]
		switch.init()


func get_switches_base_state():
	var switches = get_tree().get_nodes_in_group("switches")
	for switch in switches:
		switches_base_state[switch.interactable_name] = switch.switch_position
