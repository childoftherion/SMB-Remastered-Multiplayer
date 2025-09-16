extends AnimatableBody2D

var active := false

@onready var starting_position := global_position

func _physics_process(delta: float) -> void:
	if active:
		global_position.x += 48 * delta

func on_player_entered(player: Player) -> void:
	if player.velocity.y > -player.FALL_GRAVITY:
		active = true

func reset() -> void:
	global_position = starting_position
	reset_physics_interpolation()
	active = false
