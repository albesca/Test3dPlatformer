extends "res://Assets/Scripts/Interactable.gd"


export var switch_position = false


func _ready():
	init()


func set_animation():
		if switch_position:
			$AnimationPlayer.assigned_animation = "switch_on"
		else:
			$AnimationPlayer.assigned_animation = "switch_off"


func interact():
	switch_position = !switch_position
	set_animation()
	$AnimationPlayer.play()
	emit_signal("update_interactable", interactable_name, switch_position)


func init():
	interactable = false
	set_animation()
	$AnimationPlayer.seek(0.5, true)
