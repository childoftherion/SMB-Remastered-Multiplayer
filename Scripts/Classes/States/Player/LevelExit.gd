extends PlayerState

func enter(_msg := {}) -> void:
	player.has_jumped = false
	player.crouching = false
	player.get_node("CameraCenterJoint/RightWall").set_collision_layer_value(1, false)

func physics_update(delta: float) -> void:
	player.input_direction = 1
	player.can_run = false
	player.normal_state.handle_movement(delta)
	player.normal_state.handle_animations()
