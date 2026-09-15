extends CPUParticles2D

func burst(particle_color: Color) -> void:
	color = particle_color
	restart()
	await get_tree().create_timer(lifetime + 0.15).timeout
	queue_free()
