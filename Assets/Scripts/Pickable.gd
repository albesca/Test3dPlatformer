extends "res://Assets/Scripts/Interactable.gd"


func interact():
	emit_signal("interact", self)
	queue_free()
