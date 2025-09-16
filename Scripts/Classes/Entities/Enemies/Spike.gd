extends Enemy
const SPIKE_BALL = preload("uid://c7il83r4ab05d")

@export var can_move := false

func _ready() -> void:
	$ThrowTimer.start()
	if can_move:
		$TurnTimer.start()

func _physics_process(delta: float) -> void:
	if can_move:
		$Movement.handle_movement(delta)
	else:
		$StaticMovement.handle_movement(delta)
		var target_player = get_tree().get_first_node_in_group("Players")
		var target_direction = sign(target_player.global_position.x - global_position.x)
		if target_direction != 0:
			direction = target_direction

func throw_ball() -> void:
	$Movement.can_move = false
	%Animations.play("BallSpawn")
	await %Animations.animation_finished
	summon_ball()
	%Animations.play("Idle")
	$Movement.can_move = true

func summon_ball() -> void:
	var ball = SPIKE_BALL.instantiate()
	ball.global_position = %Ball.global_position
	add_sibling(ball)
	ball.velocity.x = 100 * direction


func on_timeout() -> void:
	if not $Movement.can_move: return
	var target_player = get_tree().get_first_node_in_group("Players")
	direction = sign(target_player.global_position.x - global_position.x)
