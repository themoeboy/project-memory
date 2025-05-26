extends Node2D

@export var speed: float = 400
@export var deceleration_rate: float = 2000
@export var recoil_acceleration: float = 1000
@export var recoil_pierce_duration: float = 0.1   # Piercing time after hit
@export var recoil_pause_duration: float = 0.2    # Hang time after piercing
@export var turn_speed: float = 5.0               # Smooth turning
@export var arc_weight: float = 0.5  # 0 = straight to player, 1 = full upward
@export var shrink_peak = 0.25
@export var shrink_rate = 25.0
@export var grow_rate = 25.0

var shrinking = true  
var direction: Vector2
var damage: int = 0
var current_speed: float = 0
var hit: bool = false
var recoiling: bool = false
var recoil_timer: float = 0.0
var recoil_phase = ENUMS.polearm_state.PIERCING
var arc_blend_factor: float = 1.0

@export var blend_decay_rate: float = 1.5  

@onready var collision = $hitbox/collision
@onready var hitbox = $hitbox

func _ready():
	current_speed = speed

func _physics_process(delta):
	UTIL.polearm_pos = position
	
	if hit:
		recoil_timer -= delta

		match recoil_phase:
			ENUMS.polearm_state.PIERCING:  # Piercing Phase
				if recoil_timer <= 0:
					recoil_phase = ENUMS.polearm_state.PAUSE
					recoil_timer = recoil_pause_duration
					current_speed = 0
				else:
					# Continue moving forward briefly after hit
					position += direction * current_speed * delta

			ENUMS.polearm_state.PAUSE:  #  Hang Phase
				UTIL.polearm_paused_pos = position
				UTIL.can_dash = true
				if recoil_timer <= 0:
					recoil_phase = ENUMS.polearm_state.RETURN
					recoiling = true
					UTIL.can_dash = false
					current_speed = 0
				# No movement during hang

			ENUMS.polearm_state.RETURN:  #  Arc Return Phase
				var to_player = (UTIL.player_pos - position)
				var distance_to_player = to_player.length()
				var player_direction = to_player.normalized()

				# Blend arc more strongly at the start
				arc_blend_factor = max(arc_blend_factor - blend_decay_rate * delta, 0.0)

				# Compute a curved direction: blend of upward and player
				var curved_direction = (Vector2(0, -1) * arc_blend_factor + player_direction * (1.0 - arc_blend_factor)).normalized()

				# Smoothly turn toward the curved direction
				direction = direction.slerp(curved_direction, turn_speed * delta).normalized()
				
				if shrinking:
					scale = scale.lerp(Vector2(shrink_peak, shrink_peak), shrink_rate * delta)
					
					if scale.distance_to(Vector2(shrink_peak, shrink_peak)) < 0.01:
						scale = Vector2(shrink_peak, shrink_peak)  # Snap to target
						shrinking = false
				else:
					scale = scale.lerp(Vector2(1, 1), shrink_rate * delta)
					
				# Rotate visual toward direction
				rotation = direction.angle()

				# Accelerate and move
				current_speed = min(current_speed + recoil_acceleration * delta, speed)
				position += direction * current_speed * delta

	else:
		# Normal forward movement
		current_speed = speed
		position += direction * current_speed * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if  enemy.has_method("take_damage") and enemy.is_in_group('enemy') and not hit:
		enemy.take_damage(damage)
		hit = true
		recoil_phase = 0
		recoil_timer = recoil_pierce_duration
		# Disable collision during return if needed
		$hitbox.monitoring = false
 

func _on_retrievebox_body_entered(body: Node2D) -> void:
	if (body.name == "player" and hit):
		queue_free()
	pass # Replace with function body.
