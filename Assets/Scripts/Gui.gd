extends Control


signal switch_camera
signal toggle_music(toggled)


func switch_camera():
	emit_signal("switch_camera")
	

func toggle_music(toggled):
	emit_signal("toggle_music", toggled)
