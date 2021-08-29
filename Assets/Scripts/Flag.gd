extends StaticBody


signal level_done


func player_entered(body):
	print("the player reached the flag!")
	$VictoryParticles.emitting = true
	$VictoryTimer.start()
	emit_signal("level_done")


func reset():
	$VictoryTimer.stop()
	stop_particles()


func stop_particles():
	$VictoryParticles.emitting = false
	
