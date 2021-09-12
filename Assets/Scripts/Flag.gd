extends StaticBody


signal level_done
signal set_destination(destination_position)

var goal_enabled
var player_in_reach
export (Color) var goal_enabled_flag
export (Color) var goal_disabled_flag


func _ready():
	disable_goal()


func _process(_delta):
	if player_in_reach and goal_enabled and !$VictoryParticles.emitting:
		$VictoryParticles.emitting = true
		$VictoryTimer.start()
		emit_signal("level_done")


func player_entered(_body):
	print("the player reached the flag!")
	player_in_reach = true


func player_exited(_body):
	player_in_reach = false


func reset():
	disable_goal()
	player_in_reach = false
	$VictoryTimer.stop()
	stop_particles()


func stop_particles():
	$VictoryParticles.emitting = false
	

func enable_goal():
	goal_enabled = true
	$Flag.material.albedo_color = goal_enabled_flag
	
	
func disable_goal():
	goal_enabled = false
	$Flag.material.albedo_color = goal_disabled_flag


func set_destination(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		emit_signal("set_destination", transform.origin)
