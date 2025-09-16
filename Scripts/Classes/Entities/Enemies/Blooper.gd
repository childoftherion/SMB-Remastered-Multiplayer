extends Enemy

var falling := true
var target_player: Player = null
var can_rise := true

func _physics_process(delta: float) -> void:
	target_player = get_tree().get_first_node_in_group("Players")
	if falling:
		global_position.y += 32 * delta
		if global_position.y >= target_player.global_position.y - 24 and can_rise:
			rise_tween()
		$Sprite.play("Fall")
	else:
		$Sprite.play("Rise")

func rise_tween() -> void:
	falling = false
	can_rise = false
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var dir = sign(target_player.global_position.x - global_position.x)
	var target_position := Vector2(32 * dir, -32)
	var final_position = global_position + target_position
	final_position.y = clamp(final_position.y, -176, 64)
	tween.tween_property(self, "global_position", final_position, 0.75)
	await tween.finished
	falling = true
	await get_tree().create_timer(0.25, false).timeout
	can_rise = true
