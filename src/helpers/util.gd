extends Node

# Reusable Functions

func freeze_frame(timescale: float, duration: float ) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true , false , true).timeout
	Engine.time_scale = 1.0

func flash_blinking(sprite: Sprite2D, duration := 0.5, blink_rate := 0.1):
	var elapsed_time = 0.0
	while elapsed_time < duration:
		await get_tree().create_timer(blink_rate).timeout
		sprite.visible = not sprite.visible
		elapsed_time += blink_rate
	sprite.visible = true
