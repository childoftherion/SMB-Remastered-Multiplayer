@tool
@icon("res://Assets/Sprites/Editor/Pipe.png")
class_name PipeArea
extends Node2D

signal pipe_entered
signal pipe_exited

@onready var arrow_joint: Node2D = $ArrowJoint
@onready var arrow: Sprite2D = $ArrowJoint/Arrow
@onready var hitbox: Area2D = $Hitbox

@export_enum("Down", "Up", "Left", "Right") var enter_direction := 0:
	set(value):
		enter_direction = value
		update_visuals()

@export_range(0, 99) var pipe_id := 0:
	set(value):
		pipe_id = value
		update_visuals()

@export_enum("0", "1", "2", "3", "4") var target_sub_level := 0

@export_file("*.tscn") var target_level := ""

@export var exit_only := false:
	set(value):
		exit_only = value
		update_visuals()

var can_enter := true

static var exiting_pipe_id := -1

func _ready() -> void:
	update_visuals()
	if Engine.is_editor_hint() == false and Global.current_game_mode != Global.GameMode.LEVEL_EDITOR:
		run_pipe_check()

func run_pipe_check() -> void:
	if exiting_pipe_id == pipe_id and exit_only:
		exit_pipe()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() == false:
		in_game()
		update_visuals()

func update_visuals() -> void:
	if Engine.is_editor_hint() or (Global.current_game_mode == Global.GameMode.LEVEL_EDITOR and LevelEditor.playing_level == false):
		show()
		$ArrowJoint.show()
		$ArrowJoint.rotation = get_vector(enter_direction).angle() - deg_to_rad(90)
		$ArrowJoint/Arrow.flip_v = exit_only
		var id := pipe_id
		$Node2D/CenterContainer/Label.text = str(id)
	else:
		hide()

func exit_pipe() -> void:
	pipe_exited.emit()
	await get_tree().physics_frame
	for i in get_tree().get_nodes_in_group("Players"):
		i.go_to_exit_pipe(self)
	for i in get_tree().get_nodes_in_group("Players"):
		await get_tree().create_timer(0.5, false).timeout
		await i.exit_pipe(self)
	exiting_pipe_id = -1

func get_vector(direction := 0) -> Vector2:
	match direction:
		0:
			return Vector2.DOWN
		1:
			return Vector2.UP
		2:
			return Vector2.LEFT
		3:
			return Vector2.RIGHT
		_:
			return Vector2.ZERO

func get_input_direction(direction := 0) -> String:
	match direction:
		0:
			return "move_down"
		1:
			return "move_up"
		2:
			return "move_left"
		3:
			return "move_right"
		_:
			return ""

func in_game() -> void:
	if exit_only:
		return
	for i in hitbox.get_overlapping_areas():
		if i.owner is Player:
			run_player_check(i.owner)

func run_player_check(player: Player) -> void:
	if Global.player_action_pressed(get_input_direction(enter_direction), player.player_id) and can_enter and (player.is_on_floor() or enter_direction == 1 or player.gravity_vector != Vector2.DOWN) and player.state_machine.state.name == "Normal":
		can_enter = false
		pipe_entered.emit()
		DiscoLevel.can_meter_tick = false
		Level.in_vine_level = false

		# temporal flex tape solution, sorry if this does bad things
		# - leanycat
		if (Global.current_game_mode == Global.GameMode.CAMPAIGN and Global.current_campaign == "SMBLL") and Global.world_num == 9 and Global.level_num == 3:
			Level.vine_return_level = Global.current_level.scene_file_path
			Level.in_vine_level = true

		player.enter_pipe(self)
