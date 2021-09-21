extends Spatial


export var switch_position = false


# Called when the node enters the scene tree for the first time.
func _ready():
	set_animation()
	$AnimationPlayer.seek(0.5, true)


func toggle_switch(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		switch_position = !switch_position
		set_animation()
		$AnimationPlayer.play()


func set_animation():
		if switch_position:
			$AnimationPlayer.assigned_animation = "switch_on"
		else:
			$AnimationPlayer.assigned_animation = "switch_off"
